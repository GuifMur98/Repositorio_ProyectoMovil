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
    // Buscar si ya existe un ítem de este producto para este usuario
    final existing = await DatabaseConfig.cartItems.findOne({
      'userId': item.userId,
      'productId': item.productId,
    });
    if (existing != null) {
      // Si existe, sumar la cantidad
      final newQty = (existing['quantity'] ?? 1) + item.quantity;
      await DatabaseConfig.cartItems.update(
        {'_id': existing['_id']},
        {
          '\$set': {'quantity': newQty}
        },
      );
    } else {
      // Si no existe, insertar normalmente
      await DatabaseConfig.cartItems.insert(item.toJson());
    }
  }

  static Future<void> updateCartItem(CartItem item) async {
    try {
      await DatabaseConfig.cartItems.update(
        {'_id': ObjectId.parse(item.id)},
        {
          '\$set': {'quantity': item.quantity}
        },
      );
    } catch (e) {
      await DatabaseConfig.cartItems.update(
        {'_id': item.id},
        {
          '\$set': {'quantity': item.quantity}
        },
      );
    }
  }

  static Future<void> deleteCartItem(String id) async {
    // Limpia el id si viene como ObjectId("...")
    String cleanId = id;
    if (id.startsWith('ObjectId(')) {
      final start = id.indexOf('"') >= 0 ? id.indexOf('"') : id.indexOf("'");
      final end = id.lastIndexOf('"') >= 0 ? id.lastIndexOf('"') : id.lastIndexOf("'");
      if (start >= 0 && end > start) {
        cleanId = id.substring(start + 1, end);
        print('[CartItemService] ID limpiado: $cleanId');
      }
    }
    try {
      await DatabaseConfig.cartItems.deleteOne({'_id': ObjectId.fromHexString(cleanId)});
      print('[CartItemService] Eliminado con ObjectId');
    } catch (e) {
      print('[CartItemService] Error con ObjectId: $e');
      await DatabaseConfig.cartItems.deleteOne({'_id': cleanId});
      print('[CartItemService] Eliminado con string plano');
    }
  }

  static Future<void> clearCart(String userId) async {
    await DatabaseConfig.cartItems.remove({'userId': userId});
  }
}
