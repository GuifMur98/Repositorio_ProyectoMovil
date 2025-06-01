import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConfig {
  static late Db _db;
  static late DbCollection _users;
  static late DbCollection _products;

  static Future<void> connect() async {
    try {
      _db = await Db.create(dotenv.env['MONGODB_URI'] ?? '');
      await _db.open();
      _users = _db.collection('users');
      _products = _db.collection('products');
      print('Conexión a MongoDB establecida correctamente');
    } catch (e) {
      print('Error al conectar con MongoDB: $e');
      rethrow;
    }
  }

  static DbCollection get users => _users;
  static DbCollection get products => _products;

  static Future<void> close() async {
    await _db.close();
  }
}
