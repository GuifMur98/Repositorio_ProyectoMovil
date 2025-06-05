import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/message.dart';

class MessageService {
  static Future<List<Message>> getMessagesByChat(String chatId) async {
    final docs =
        await DatabaseConfig.messages.find({'chatId': chatId}).toList();
    return docs.map((doc) => Message.fromJson(doc)).toList();
  }

  static Future<void> addMessage(Message message) async {
    await DatabaseConfig.messages.insert(message.toJson());
  }

  static Future<void> deleteMessage(String id) async {
    await DatabaseConfig.messages.remove({'_id': ObjectId.parse(id)});
  }

  /// Obtiene la lista de chats del usuario con el último mensaje y el nombre del otro usuario
  static Future<List<Map<String, dynamic>>> getUserChatPreviews(String userId) async {
    // Buscar todos los mensajes donde el usuario es participante
    final messages = await DatabaseConfig.messages.find({
      '\$or': [
        {'senderId': userId},
        {'chatId': {'\$regex': userId}}
      ]
    }).toList();
    // Agrupar por chatId y obtener el último mensaje de cada chat
    final Map<String, Map<String, dynamic>> lastMessages = {};
    for (final msg in messages) {
      final chatId = msg['chatId'];
      if (!lastMessages.containsKey(chatId) ||
          DateTime.parse(msg['timestamp']).isAfter(
              DateTime.parse(lastMessages[chatId]!['timestamp']))) {
        lastMessages[chatId] = msg;
      }
    }
    // Para cada chat, obtener el otro usuario y armar el preview
    List<Map<String, dynamic>> previews = [];
    for (final entry in lastMessages.entries) {
      final chatId = entry.key;
      final msg = entry.value;
      // Determinar el otro usuario
      final ids = chatId.split('_');
      String otherUserId = ids.firstWhere((id) => id != userId, orElse: () => ids[0]);
      final userDoc = await DatabaseConfig.users.findOne({'_id': otherUserId});
      final otherUserName = userDoc != null ? userDoc['name'] ?? 'Usuario' : 'Usuario';
      previews.add({
        'chatId': chatId,
        'otherUserId': otherUserId,
        'otherUserName': otherUserName,
        'lastMessage': msg['content'] ?? '',
        'lastMessageTime': msg['timestamp'] != null ? _formatTime(msg['timestamp']) : '',
      });
    }
    // Ordenar por fecha descendente
    previews.sort((a, b) => b['lastMessageTime'].compareTo(a['lastMessageTime']));
    return previews;
  }

  static String _formatTime(String isoString) {
    final date = DateTime.parse(isoString);
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
          ;
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}
