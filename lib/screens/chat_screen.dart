import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/message.dart';
import '../models/user.dart' as app_model;
import '../services/notification_service.dart';
import '../widgets/custom_image_spinner.dart';

class ChatScreen extends StatefulWidget {
  final String? sellerId;
  final String? chatId;
  const ChatScreen({super.key, this.sellerId, this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _chatId;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  app_model.User? _otherUser;
  Stream<List<Message>>? _messagesStream;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String? chatId = widget.chatId;
    String? otherUserId = widget.sellerId;
    if (chatId == null && otherUserId != null) {
      // Generar chatId si no viene por argumento
      final ids = [user.uid, otherUserId];
      ids.sort();
      chatId = ids.join('_');
    }
    if (chatId == null) return;
    setState(() {
      _chatId = chatId;
      _isLoading = true;
    });
    // Obtener info del otro usuario si no está
    if (otherUserId == null) {
      // Buscar el otro usuario en la colección de chats
      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get();
      final users = List<String>.from(chatDoc.data()?['users'] ?? []);
      otherUserId = users.firstWhere((id) => id != user.uid, orElse: () => '');
    }
    if (otherUserId == null || otherUserId.isEmpty) return;
    final otherUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .get();
    app_model.User? otherUser;
    if (otherUserDoc.exists) {
      final data = otherUserDoc.data();
      otherUser = app_model.User(
        id: otherUserId,
        name: data?['name'] ?? 'Usuario',
        email: data?['email'] ?? '',
        password: '',
        avatarUrl: data?['avatarUrl'],
      );
    }
    _messagesStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Message(
                id: doc.id,
                chatId: chatId!,
                senderId: data['senderId'],
                content: data['content'],
                timestamp: (data['timestamp'] as Timestamp).toDate(),
              );
            }).toList());
    setState(() {
      _otherUser = otherUser;
      _isLoading = false;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatId == null) return;
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final content = _messageController.text.trim();
    final now = DateTime.now();
    final messageData = {
      'senderId': user.uid,
      'content': content,
      'timestamp': Timestamp.fromDate(now),
    };
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(_chatId);
    await chatRef.collection('messages').add(messageData);
    // Actualizar info del chat (último mensaje)
    await chatRef.set({
      'users': [user.uid, widget.sellerId],
      'lastMessage': content,
      'lastMessageTime': Timestamp.fromDate(now),
    }, SetOptions(merge: true));

    // Crear notificación para el receptor si no soy yo
    if (widget.sellerId != null && widget.sellerId != user.uid) {
      await NotificationService.createNotificationForUser(
        userId: widget.sellerId!,
        title: 'Nuevo mensaje',
        body: 'Has recibido un nuevo mensaje: "$content"',
        chatId: _chatId,
        senderId: user.uid,
      );
    }
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessageBubble(Message message) {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    final isMe = user != null && message.senderId == user.uid;
    final time = message.timestamp;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF5C3D2E) : const Color(0xFFE1D4C2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF5C3D2E),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              // Ajustar a zona central (UTC-6) y formato 12h
              () {
                final central = time.toUtc().subtract(const Duration(hours: 6));
                int hour = central.hour % 12 == 0 ? 12 : central.hour % 12;
                final minute = central.minute.toString().padLeft(2, '0');
                final ampm = central.hour < 12 ? 'a.m.' : 'p.m.';
                return '$hour:$minute $ampm';
              }(),
              style: TextStyle(
                color: isMe
                    ? Colors.white70
                    : const Color(0xFF5C3D2E).withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        title: Row(
          children: [
            _otherUser?.avatarUrl != null && _otherUser!.avatarUrl!.isNotEmpty
                ? (() {
                    final avatar = _otherUser!.avatarUrl!;
                    if ((avatar.startsWith('/9j') ||
                            avatar.startsWith('iVBOR')) &&
                        avatar.length > 100) {
                      try {
                        return CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF5C3D2E),
                          backgroundImage: MemoryImage(base64Decode(avatar)),
                        );
                      } catch (_) {}
                    }
                    // Si no es base64, intentar como URL
                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF5C3D2E),
                      backgroundImage: NetworkImage(avatar),
                    );
                  })()
                : const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF5C3D2E),
                    child: Icon(Icons.person, size: 20, color: Colors.white),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherUser?.name ?? 'Usuario',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'En línea',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CustomImageSpinner(size: 40))
                : _messagesStream == null
                    ? const SizedBox.shrink()
                    : StreamBuilder<List<Message>>(
                        stream: _messagesStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CustomImageSpinner(size: 40));
                          }
                          final messages = snapshot.data ?? [];
                          if (messages.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay mensajes aún',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '¡Sé el primero en escribir!',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessageBubble(messages[index]);
                            },
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                      color: Color(0xFF5C3D2E),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Función de adjuntar archivos no disponible',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF5C3D2E),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
