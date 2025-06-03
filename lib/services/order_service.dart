import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/order.dart';

class OrderService {
  static Future<List<Order>> getOrdersByUser(String userId) async {
    final docs = await DatabaseConfig.orders.find({'userId': userId}).toList();
    return docs.map((doc) => Order.fromJson(doc)).toList();
  }

  static Future<Order?> getOrderById(String id) async {
    final doc =
        await DatabaseConfig.orders.findOne({'_id': ObjectId.parse(id)});
    return doc != null ? Order.fromJson(doc) : null;
  }

  static Future<void> addOrder(Order order) async {
    await DatabaseConfig.orders.insert(order.toJson());
  }

  static Future<void> updateOrder(Order order) async {
    await DatabaseConfig.orders.update(
      {'_id': ObjectId.parse(order.id)},
      order.toJson(),
    );
  }

  static Future<void> deleteOrder(String id) async {
    await DatabaseConfig.orders.remove({'_id': ObjectId.parse(id)});
  }
}
