import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConfig {
  static late Db _db;
  static late DbCollection _users;
  static late DbCollection _products;
  static late DbCollection _addresses;
  static late DbCollection _cartItems;
  static late DbCollection _favorites;
  static late DbCollection _orders;
  static late DbCollection _notifications;
  static late DbCollection _categories;
  static late DbCollection _messages;

  static Future<void> connect() async {
    try {
      _db = await Db.create(dotenv.env['MONGODB_URI'] ?? '');
      await _db.open();
      _users = _db.collection('users');
      _products = _db.collection('products');
      _addresses = _db.collection('addresses');
      _cartItems = _db.collection('cart_items');
      _favorites = _db.collection('favorites');
      _orders = _db.collection('orders');
      _notifications = _db.collection('notifications');
      _categories = _db.collection('categories');
      _messages = _db.collection('messages');
      print('Conexión a MongoDB establecida correctamente');
    } catch (e) {
      print('Error al conectar con MongoDB: $e');
      rethrow;
    }
  }

  static DbCollection get users => _users;
  static DbCollection get products => _products;
  static DbCollection get addresses => _addresses;
  static DbCollection get cartItems => _cartItems;
  static DbCollection get favorites => _favorites;
  static DbCollection get orders => _orders;
  static DbCollection get notifications => _notifications;
  static DbCollection get categories => _categories;
  static DbCollection get messages => _messages;

  static Future<void> close() async {
    await _db.close();
  }
}
