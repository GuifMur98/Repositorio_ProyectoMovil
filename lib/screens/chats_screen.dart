import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_image_spinner.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatPreview {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String lastMessage;
  final String lastMessageTime;
  _ChatPreview({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.otherUserAvatar,
  });
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<_ChatPreview> _chats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _error = 'No has iniciado sesión.';
        });
        return;
      }
      final chatQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: user.uid)
          .orderBy('lastMessageTime', descending: true)
          .get();
      final chats = <_ChatPreview>[];
      for (final doc in chatQuery.docs) {
        final data = doc.data();
        final users = List<String>.from(data['users'] ?? []);
        final otherUserId =
            users.firstWhere((id) => id != user.uid, orElse: () => '');
        String otherUserName = 'Usuario';
        String? otherUserAvatar;
        // Obtener nombre y avatar del otro usuario
        if (otherUserId.isNotEmpty) {
          final otherUserDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(otherUserId)
              .get();
          otherUserName = otherUserDoc.data()?['name'] ?? 'Usuario';
          otherUserAvatar = otherUserDoc.data()?['avatarUrl'];
        }
        chats.add(_ChatPreview(
          chatId: doc.id,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          otherUserAvatar: otherUserAvatar,
          lastMessage: data['lastMessage'] ?? '',
          lastMessageTime: data['lastMessageTime'] != null
              ? _formatTime((data['lastMessageTime'] as Timestamp).toDate())
              : '',
        ));
      }
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar chats: $e';
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    // Convertir a zona central (UTC-6, America/Tegucigalpa)
    final central = dateTime.toUtc().subtract(const Duration(hours: 6));
    int hour = central.hour % 12 == 0 ? 12 : central.hour % 12;
    final minute = central.minute.toString().padLeft(2, '0');
    final ampm = central.hour < 12 ? 'a.m.' : 'p.m.';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CustomImageSpinner(size: 40))
          : _error != null
              ? Center(child: Text(_error!))
              : _chats.isEmpty
                  ? const Center(child: Text('No tienes chats.'))
                  : RefreshIndicator(
                      onRefresh: _fetchChats,
                      child: ListView.builder(
                        itemCount: _chats.length,
                        itemBuilder: (context, index) {
                          final chat = _chats[index];
                          return ListTile(
                            onLongPress: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar chat'),
                                  content: const Text(
                                      '¿Seguro que deseas eliminar este chat? Esta acción no se puede deshacer.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Eliminar',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('chats')
                                      .doc(chat.chatId)
                                      .delete();
                                  setState(() {
                                    _chats.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Chat eliminado')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error al eliminar chat: $e')),
                                  );
                                }
                              }
                            },
                            leading: chat.otherUserAvatar != null &&
                                    chat.otherUserAvatar!.isNotEmpty
                                ? (() {
                                    final avatar = chat.otherUserAvatar!;
                                    if ((avatar.startsWith('/9j') ||
                                            avatar.startsWith('iVBOR')) &&
                                        avatar.length > 100) {
                                      try {
                                        return CircleAvatar(
                                          backgroundColor:
                                              const Color(0xFF5C3D2E),
                                          backgroundImage:
                                              MemoryImage(base64Decode(avatar)),
                                        );
                                      } catch (_) {}
                                    }
                                    // Si no es base64, intentar como URL
                                    return CircleAvatar(
                                      backgroundColor: const Color(0xFF5C3D2E),
                                      backgroundImage: NetworkImage(avatar),
                                    );
                                  })()
                                : const CircleAvatar(
                                    backgroundColor: Color(0xFF5C3D2E),
                                    child:
                                        Icon(Icons.person, color: Colors.white),
                                  ),
                            title: Text(chat.otherUserName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(chat.lastMessage,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Text(
                              chat.lastMessageTime,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/chat',
                                arguments: {'sellerId': chat.otherUserId},
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

// NOTA: Debes implementar el método getUserChatPreviews en MessageService para obtener los chats del usuario con la info necesaria.
