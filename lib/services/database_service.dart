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

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'marketplace.db');
    return await openDatabase(
      path,
      version: 8,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            phone TEXT,
            address TEXT,
            imageUrl TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE products(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            price REAL NOT NULL,
            imageUrl TEXT NOT NULL,
            category TEXT NOT NULL,
            address TEXT NOT NULL,
            sellerId TEXT NOT NULL,
            FOREIGN KEY (sellerId) REFERENCES users (id)
          )
        ''');
        await db.execute('''
          CREATE TABLE cart(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId TEXT NOT NULL,
            userId TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES users (id),
            UNIQUE(productId, userId)
          )
        ''');
        await db.execute('''
          CREATE TABLE favorites(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId TEXT NOT NULL,
            userId TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES users (id),
            UNIQUE(productId, userId)
          )
        ''');
        await db.execute('''
          CREATE TABLE purchases(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT,
            products TEXT,
            total REAL,
            date TEXT
          )
        ''');
        // Nueva tabla para direcciones
        await db.execute('''
          CREATE TABLE addresses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL,
            street TEXT NOT NULL,
            city TEXT NOT NULL,
            state TEXT,
            zipCode TEXT,
            country TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN imageUrl TEXT');
        }
        if (oldVersion < 7) {
          // Eliminar y recrear las tablas cart y favorites
          await db.execute('DROP TABLE IF EXISTS cart');
          await db.execute('DROP TABLE IF EXISTS favorites');

          await db.execute('''
            CREATE TABLE cart(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              productId TEXT NOT NULL,
              userId TEXT NOT NULL,
              FOREIGN KEY (userId) REFERENCES users (id),
              UNIQUE(productId, userId)
            )
          ''');

          await db.execute('''
            CREATE TABLE favorites(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              productId TEXT NOT NULL,
              userId TEXT NOT NULL,
              FOREIGN KEY (userId) REFERENCES users (id),
              UNIQUE(productId, userId)
            )
          ''');
        }
        if (oldVersion < 8) {
          // Crear tabla addresses si no existe
          await db.execute('''
            CREATE TABLE IF NOT EXISTS addresses(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              userId TEXT NOT NULL,
              street TEXT NOT NULL,
              city TEXT NOT NULL,
              state TEXT,
              zipCode TEXT,
              country TEXT NOT NULL,
              FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
            )
          ''');
        }
      },
    );
  }

  static Future<void> initDatabase() async {
    _db = await _initDB();
  }

  // CRUD para productos
  static Future<String> insertProduct(Product product) async {
    final db = await database;
    print('Insertando producto: ${product.toMap()}'); // Para debugging
    await db.insert('products', product.toMap());
    return product.id;
  }

  static Future<List<Product>> getProducts() async {
    final db = await database;
    final maps = await db.query('products');
    print('Productos en la base de datos: $maps'); // Para debugging
    return maps.map((e) {
      try {
        return Product.fromMap(e);
      } catch (error) {
        print('Error al convertir producto: $error');
        print('Datos del producto: $e');
        rethrow;
      }
    }).toList();
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
  static Future<String> insertUser(User user) async {
    final db = await database;
    print('Insertando usuario: ${user.toMap()}'); // Para debugging

    try {
      final result = await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Resultado de inserción: $result'); // Para debugging

      // Verificar que el usuario se insertó correctamente
      final insertedUser = await getUserByEmail(user.email);
      print(
        'Usuario insertado verificado: ${insertedUser?.toMap()}',
      ); // Para debugging

      return user.id;
    } catch (e) {
      print('Error al insertar usuario: $e'); // Para debugging
      rethrow;
    }
  }

  static Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
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
  static Future<void> addToCart(String productId, String userId) async {
    final db = await database;
    await db.insert('cart', {
      'productId': productId,
      'userId': userId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> removeFromCart(String productId, String userId) async {
    final db = await database;
    await db.delete(
      'cart',
      where: 'productId = ? AND userId = ?',
      whereArgs: [productId, userId],
    );
  }

  static Future<List<String>> getCartProductIds(String userId) async {
    final db = await database;
    final result = await db.query(
      'cart',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((e) => e['productId'] as String).toList();
  }

  static Future<void> clearCart(String userId) async {
    final db = await database;
    await db.delete('cart', where: 'userId = ?', whereArgs: [userId]);
  }

  // Métodos para favoritos
  static Future<void> addToFavorites(String productId, String userId) async {
    final db = await database;
    print('Agregando producto $productId a favoritos del usuario $userId');
    await db.insert('favorites', {
      'productId': productId,
      'userId': userId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    print('Producto agregado a favoritos exitosamente');
  }

  static Future<void> removeFromFavorites(
    String productId,
    String userId,
  ) async {
    final db = await database;
    print('Removiendo producto $productId de favoritos del usuario $userId');
    await db.delete(
      'favorites',
      where: 'productId = ? AND userId = ?',
      whereArgs: [productId, userId],
    );
    print('Producto removido de favoritos exitosamente');
  }

  static Future<bool> isProductInFavorites(
    String productId,
    String userId,
  ) async {
    final db = await database;
    print(
      'Verificando si el producto $productId está en favoritos del usuario $userId',
    );
    final result = await db.query(
      'favorites',
      where: 'productId = ? AND userId = ?',
      whereArgs: [productId, userId],
    );
    print('Resultado de la consulta de favoritos: ${result.isNotEmpty}');
    return result.isNotEmpty;
  }

  static Future<List<String>> getFavoriteProductIds(String userId) async {
    final db = await database;
    print('Obteniendo lista de IDs de productos favoritos del usuario $userId');
    final result = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    final ids = result.map((row) => row['productId'] as String).toList();
    print('IDs de productos favoritos: $ids');
    return ids;
  }

  // Métodos para historial de compras
  static Future<void> insertPurchase({
    required String userId,
    required List<Map<String, dynamic>> products,
    required double total,
  }) async {
    final db = await database;
    final date = DateTime.now().toIso8601String();
    await db.insert('purchases', {
      'userId': userId,
      'products': jsonEncode(products),
      'total': total,
      'date': date,
    });
  }

  static Future<List<Map<String, dynamic>>> getPurchasesByUser(
    String userId,
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

  static Future<User?> getUserById(String id) async {
    final db = await database;
    print('Buscando usuario con ID: $id'); // Debug log
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    print('Resultado de la búsqueda: $result'); // Debug log
    if (result.isEmpty) {
      print('No se encontró usuario con ID: $id'); // Debug log
      return null;
    }
    try {
      final user = User.fromMap(result.first);
      print('Usuario encontrado: ${user.toMap()}'); // Debug log
      return user;
    } catch (e) {
      print('Error al convertir usuario: $e'); // Debug log
      print('Datos del usuario: ${result.first}'); // Debug log
      return null;
    }
  }

  static Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // Métodos para direcciones
  static Future<int> insertAddress(Map<String, dynamic> address) async {
    final db = await database;
    return await db.insert('addresses', address);
  }

  static Future<List<Map<String, dynamic>>> getAddressesByUserId(
    String userId,
  ) async {
    final db = await database;
    final maps = await db.query(
      'addresses',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps;
  }

  static Future<Map<String, dynamic>?> getAddressById(int addressId) async {
    final db = await database;
    final maps = await db.query(
      'addresses',
      where: 'id = ?',
      whereArgs: [addressId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  static Future<int> updateAddress(int id, Map<String, dynamic> address) async {
    final db = await database;
    return await db.update(
      'addresses',
      address,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteAddress(int id) async {
    final db = await database;
    return await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
  }

  // Método para vaciar todas las tablas (solo para desarrollo)
  // static Future<void> clearDatabase() async {
  //   final db = await database;
  //   await db.delete('users');
  //   await db.delete('products');
  //   await db.delete('cart');
  //   await db.delete('favorites');
  //   await db.delete('purchases');
  //   await db.delete('addresses');
  // }
}
