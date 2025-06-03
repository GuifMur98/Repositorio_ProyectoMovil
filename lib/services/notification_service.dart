import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/notification.dart';

class NotificationService {
  static Future<List<AppNotification>> getNotificationsByUser(
      String userId) async {
    final docs =
        await DatabaseConfig.notifications.find({'userId': userId}).toList();
    return docs.map((doc) => AppNotification.fromJson(doc)).toList();
  }

  static Future<void> addNotification(AppNotification notification) async {
    await DatabaseConfig.notifications.insert(notification.toJson());
  }

  static Future<void> markAsRead(String id) async {
    await DatabaseConfig.notifications.update(
      {'_id': ObjectId.parse(id)},
      {
        '\$set': {'read': true}
      },
    );
  }

  static Future<void> deleteNotification(String id) async {
    await DatabaseConfig.notifications.remove({'_id': ObjectId.parse(id)});
  }
}
