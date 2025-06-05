import 'package:flutter/material.dart';
import '../services/message_service.dart';
import '../services/user_service.dart';

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

  factory _ChatPreview.fromMap(Map<String, dynamic> map) => _ChatPreview(
        chatId: map['chatId'] ?? '',
        otherUserId: map['otherUserId'] ?? '',
        otherUserName: map['otherUserName'] ?? 'Usuario',
        lastMessage: map['lastMessage'] ?? '',
        lastMessageTime: map['lastMessageTime'] ?? '',
      );
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
    final user = UserService.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _error = 'Debes iniciar sesión para ver tus chats.';
      });
      return;
    }
    try {
      final chatPreviews = await MessageService.getUserChatPreviews(user.id) as List<Map<String, dynamic>>;
      setState(() {
        _chats = chatPreviews
            .map((map) => _ChatPreview.fromMap(map))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar chats: $e';
      });
    }
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
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(chat.lastMessage,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Text(
                              chat.lastMessageTime,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
