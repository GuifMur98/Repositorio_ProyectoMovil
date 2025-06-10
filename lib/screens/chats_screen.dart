import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatPreview {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String lastMessage;
  final String lastMessageTime;
  _ChatPreview({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageTime,
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
        // Obtener nombre del otro usuario
        if (otherUserId.isNotEmpty) {
          final otherUserDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(otherUserId)
              .get();
          otherUserName = otherUserDoc.data()?['name'] ?? 'Usuario';
        }
        chats.add(_ChatPreview(
          chatId: doc.id,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
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
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
          ? const Center(child: CircularProgressIndicator())
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
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF5C3D2E),
                              child: Icon(Icons.person, color: Colors.white),
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
