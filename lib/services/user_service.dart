import '../models/user.dart';
import '../config/database.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserService {
  static User? _currentUser;

  // Obtener el usuario actual
  static User? get currentUser => _currentUser;

  // Establecer usuario actual
  static void setCurrentUser(User user) {
    _currentUser = user;
  }

  // Iniciar sesión
  static Future<User?> login(String email, String password) async {
    try {
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      final user = await DatabaseConfig.users.findOne(
        where.eq('email', email).eq('password', hashedPassword),
      );

      if (user != null) {
        final userObj = User(
          id: user['_id'].toString(),
          name: user['name'],
          email: user['email'],
          profileImage: user['profileImage'],
          addresses: List<String>.from(user['addresses'] ?? []),
          favoriteProducts: List<String>.from(user['favoriteProducts'] ?? []),
          publishedProducts: List<String>.from(user['publishedProducts'] ?? []),
          purchaseHistory: List<String>.from(user['purchaseHistory'] ?? []),
        );
        _currentUser = userObj;
        return userObj;
      }
      return null;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }

  // Registrar usuario
  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Verificar si el email ya existe
      final existingUser = await DatabaseConfig.users.findOne(
        where.eq('email', email),
      );
      if (existingUser != null) {
        return false;
      }

      // Crear nuevo usuario
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      final result = await DatabaseConfig.users.insertOne({
        'name': name,
        'email': email,
        'password': hashedPassword,
        'profileImage': null,
        'addresses': [],
        'favoriteProducts': [],
        'publishedProducts': [],
        'purchaseHistory': [],
        'createdAt': DateTime.now(),
      });

      if (result.isSuccess) {
        _currentUser = User(id: result.id.toString(), name: name, email: email);
        return true;
      }
      return false;
    } catch (e) {
      print('Error al registrar usuario: $e');
      return false;
    }
  }

  // Recuperar contraseña
  static Future<bool> resetPassword(String email) async {
    try {
      final user = await DatabaseConfig.users.findOne(where.eq('email', email));
      if (user != null) {
        // Aquí deberías implementar el envío de email con el código de recuperación
        // Por ahora solo retornamos true para simular el envío
        return true;
      }
      return false;
    } catch (e) {
      print('Error al recuperar contraseña: $e');
      return false;
    }
  }

  // Cerrar sesión
  static void logout() {
    _currentUser = null;
  }

  // Verificar si hay un usuario iniciado sesión
  static bool get isLoggedIn => _currentUser != null;

  // Agregar un producto a favoritos
  static Future<void> addToFavorites(String productId) async {
    if (_currentUser != null) {
      try {
        await DatabaseConfig.users.updateOne(
          where.id(ObjectId.fromHexString(_currentUser!.id)),
          modify.addToSet('favoriteProducts', productId),
        );

        final updatedFavorites = List<String>.from(
          _currentUser!.favoriteProducts,
        )..add(productId);
        _currentUser = User(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          profileImage: _currentUser!.profileImage,
          addresses: _currentUser!.addresses,
          favoriteProducts: updatedFavorites,
          publishedProducts: _currentUser!.publishedProducts,
          purchaseHistory: _currentUser!.purchaseHistory,
        );
      } catch (e) {
        print('Error al agregar a favoritos: $e');
      }
    }
  }

  // Remover un producto de favoritos
  static Future<void> removeFromFavorites(String productId) async {
    if (_currentUser != null) {
      try {
        await DatabaseConfig.users.updateOne(
          where.id(ObjectId.fromHexString(_currentUser!.id)),
          modify.pull('favoriteProducts', productId),
        );

        final updatedFavorites = List<String>.from(
          _currentUser!.favoriteProducts,
        )..remove(productId);
        _currentUser = User(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          profileImage: _currentUser!.profileImage,
          addresses: _currentUser!.addresses,
          favoriteProducts: updatedFavorites,
          publishedProducts: _currentUser!.publishedProducts,
          purchaseHistory: _currentUser!.purchaseHistory,
        );
      } catch (e) {
        print('Error al remover de favoritos: $e');
      }
    }
  }

  // Verificar si un producto está en favoritos
  static bool isProductInFavorites(String productId) {
    return _currentUser?.favoriteProducts.contains(productId) ?? false;
  }

  // Agregar una dirección
  static void addAddress(String address) {
    if (_currentUser != null) {
      final updatedAddresses = List<String>.from(_currentUser!.addresses)
        ..add(address);
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        profileImage: _currentUser!.profileImage,
        addresses: updatedAddresses,
        favoriteProducts: _currentUser!.favoriteProducts,
        publishedProducts: _currentUser!.publishedProducts,
        purchaseHistory: _currentUser!.purchaseHistory,
      );
    }
  }

  // Remover una dirección
  static void removeAddress(String address) {
    if (_currentUser != null) {
      final updatedAddresses = List<String>.from(_currentUser!.addresses)
        ..remove(address);
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        profileImage: _currentUser!.profileImage,
        addresses: updatedAddresses,
        favoriteProducts: _currentUser!.favoriteProducts,
        publishedProducts: _currentUser!.publishedProducts,
        purchaseHistory: _currentUser!.purchaseHistory,
      );
    }
  }

  // Agregar una compra al historial
  static void addPurchase(String purchaseId) {
    if (_currentUser != null) {
      final updatedHistory = List<String>.from(_currentUser!.purchaseHistory)
        ..add(purchaseId);
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        profileImage: _currentUser!.profileImage,
        addresses: _currentUser!.addresses,
        favoriteProducts: _currentUser!.favoriteProducts,
        publishedProducts: _currentUser!.publishedProducts,
        purchaseHistory: updatedHistory,
      );
    }
  }

  // Agregar un producto publicado
  static void addPublishedProduct(String productId) {
    if (_currentUser != null) {
      final updatedProducts = List<String>.from(_currentUser!.publishedProducts)
        ..add(productId);
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        profileImage: _currentUser!.profileImage,
        addresses: _currentUser!.addresses,
        favoriteProducts: _currentUser!.favoriteProducts,
        publishedProducts: updatedProducts,
        purchaseHistory: _currentUser!.purchaseHistory,
      );
    }
  }
}
