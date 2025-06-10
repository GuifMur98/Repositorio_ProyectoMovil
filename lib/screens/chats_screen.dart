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
    // Simulación: chats en memoria. Implementa tu lógica real aquí si lo deseas
    setState(() {
      _isLoading = false;
      _chats = [
        _ChatPreview(
          chatId: '1_2',
          otherUserId: '2',
          otherUserName: 'Usuario Ejemplo',
          lastMessage: '¡Hola! ¿Cómo estás?',
          lastMessageTime: '10:30',
        ),
        // Agrega más chats simulados si lo deseas
      ];
      _error = null;
    });
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
