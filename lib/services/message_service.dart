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
}
