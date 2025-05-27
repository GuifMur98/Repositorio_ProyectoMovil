import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'dart:convert';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<void> _createCartAndFavoritesTables(Database db) async {
    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT
      )
    ''');
  }

  static Future<void> _createPurchasesTable(Database db) async {
    await db.execute('''
      CREATE TABLE purchases(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        products TEXT, -- JSON
        total REAL,
        date TEXT
      )
    ''');
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    return await openDatabase(
      path,
      version: 3, // subir versión para migración
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            description TEXT,
            price REAL,
            imageUrl TEXT,
            category TEXT,
            address TEXT
          )
        ''');
        await _createCartAndFavoritesTables(db);
        await _createPurchasesTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createCartAndFavoritesTables(db);
        }
        if (oldVersion < 3) {
          await _createPurchasesTable(db);
        }
      },
    );
  }

  // CRUD para productos
  static Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  static Future<List<Product>> getProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  static Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  static Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD para usuarios
  static Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  static Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return maps.map((e) => User.fromMap(e)).toList();
  }

  static Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  static Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Métodos para carrito
  static Future<void> addToCart(String productId) async {
    final db = await database;
    await db.insert('cart', {'productId': productId});
  }

  static Future<void> removeFromCart(String productId) async {
    final db = await database;
    await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
  }

  static Future<List<String>> getCartProductIds() async {
    final db = await database;
    final result = await db.query('cart');
    return result.map((e) => e['productId'] as String).toList();
  }

  static Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  // Métodos para favoritos
  static Future<void> addToFavorites(String productId) async {
    final db = await database;
    await db.insert('favorites', {'productId': productId});
  }

  static Future<void> removeFromFavorites(String productId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  static Future<List<String>> getFavoriteProductIds() async {
    final db = await database;
    final result = await db.query('favorites');
    return result.map((e) => e['productId'] as String).toList();
  }

  // Métodos para historial de compras
  static Future<void> insertPurchase({
    required int userId,
    required List<Map<String, dynamic>> products,
    required double total,
  }) async {
    final db = await database;
    final date = DateTime.now().toIso8601String();
    await db.insert('purchases', {
      'userId': userId,
      'products': jsonEncode(products), // Guardar como string JSON
      'total': total,
      'date': date,
    });
  }

  static Future<List<Map<String, dynamic>>> getPurchasesByUser(
    int userId,
  ) async {
    final db = await database;
    final result = await db.query(
      'purchases',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return result
        .map(
          (row) => {
            'id': row['id'],
            'products': row['products'],
            'total': row['total'],
            'date': row['date'],
          },
        )
        .toList();
  }
}
