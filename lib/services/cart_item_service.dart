import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/cart_item.dart';

class CartItemService {
  static Future<List<CartItem>> getCartItemsByUser(String userId) async {
    final docs =
        await DatabaseConfig.cartItems.find({'userId': userId}).toList();
    return docs.map((doc) => CartItem.fromJson(doc)).toList();
  }

  static Future<void> addCartItem(CartItem item) async {
    await DatabaseConfig.cartItems.insert(item.toJson());
  }

  static Future<void> updateCartItem(CartItem item) async {
    await DatabaseConfig.cartItems.update(
      {'_id': ObjectId.parse(item.id)},
      item.toJson(),
    );
  }

  static Future<void> deleteCartItem(String id) async {
    await DatabaseConfig.cartItems.remove({'_id': ObjectId.parse(id)});
  }

  static Future<void> clearCart(String userId) async {
    await DatabaseConfig.cartItems.remove({'userId': userId});
  }
}
