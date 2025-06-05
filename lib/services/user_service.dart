import '../models/user.dart';
import '../config/database.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'auth_service.dart';
import 'jwt_service.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

class UserService {
  static User? _currentUser;

  // Obtener el usuario currentUser
  static User? get currentUser => _currentUser;

  // Establecer usuario currentUser
  static void setCurrentUser(User user) {
    _currentUser = user;
  }

  // Iniciar sesión
  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    try {
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      final user = await DatabaseConfig.users.findOne(
        where.eq('email', email).eq('password', hashedPassword),
      );

      if (user != null) {
        // Unifica favoritos de ambos campos
        final userObj = User.fromJson(user);

        // Generar token JWT
        final token = JwtService.generateToken(userObj);

        // Establecer el usuario currentUser (AuthService.saveSession también lo hace, pero lo hacemos aquí por si acaso)
        _currentUser = userObj;

        return {'user': userObj, 'token': token};
      }
      return null;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }

  // Registrar usuario
  static Future<Map<String, dynamic>?> register(
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
        print('Error: El email ya está registrado.');
        return null;
      }

      // Crear nuevo usuario
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      final result = await DatabaseConfig.users.insertOne({
        'name': name,
        'email': email,
        'password': hashedPassword,
        'avatarUrl': null,
        'addresses': [],
        'favoriteProducts': [],
        'publishedProducts': [],
        'purchaseHistory': [],
        'createdAt': DateTime.now(),
      });

      if (result.isSuccess) {
        final insertedId = result.id;
        print('Usuario registrado con éxito. ID: $insertedId');

        // Crear objeto User para el usuario registrado (sin la contraseña hasheada para la sesión)
        final createdUser = User(
          id: insertedId.toString(),
          name: name,
          email: email,
          password: '',
          avatarUrl: null,
          addresses: [],
          favoriteProducts: [],
          publishedProducts: [],
          purchaseHistory: [],
        );

        // Generar token JWT
        final token = JwtService.generateToken(createdUser);

        // Establecer el usuario currentUser (AuthService.saveSession también lo hace, pero lo hacemos aquí por si acaso)
        setCurrentUser(createdUser);

        return {'user': createdUser, 'token': token};
      }
      print('Error al registrar usuario.');
      return null;
    } catch (e) {
      print('Error al registrar usuario: $e');
      return null;
    }
  }

  // Recuperar contraseña REAL: genera contraseña temporal, la guarda y envía por email
  static Future<bool> resetPassword(String email) async {
    try {
      final user = await DatabaseConfig.users.findOne(where.eq('email', email));
      if (user != null) {
        // 1. Generar una contraseña temporal segura
        final tempPassword = _generateResetToken(length: 10);
        final hashedTempPassword =
            sha256.convert(utf8.encode(tempPassword)).toString();
        // 2. Guardar la contraseña temporal (hasheada) en el usuario
        await DatabaseConfig.users.updateOne(
          where.eq('email', email),
          modify.set('password', hashedTempPassword),
        );
        // 3. Enviar email real con la contraseña temporal
        final smtpServer = SmtpServer(
          'smtp.gmail.com',
          username: 'webcart837@gmail.com',
          password: 'qlnq anxp pxya lfbf',
          port: 587,
          ignoreBadCertificate: true,
        );
        final message = Message()
          ..from = Address('no-reply@tradenest.com', 'TradeNest')
          ..recipients.add(email)
          ..subject = 'Recuperación de contraseña'
          ..text =
              'Tu nueva contraseña temporal es: $tempPassword\n\nPor favor inicia sesión y cámbiala lo antes posible desde tu perfil.';
        try {
          final sendReport = await send(message, smtpServer);
          print('Correo de recuperación enviado: \\${sendReport.toString()}');
          return true;
        } catch (e) {
          print('Error al enviar correo de recuperación: \\${e}');
          return false;
        }
      }
      print('Recuperación de contraseña: Email no encontrado.');
      return false;
    } catch (e) {
      print('Error al recuperar contraseña: \\${e}');
      return false;
    }
  }

  // Generar un token seguro para recuperación de contraseña
  static String _generateResetToken({int length = 32}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)])
        .join();
  }

  // Cerrar sesión
  static void logout() {
    _currentUser = null;
    AuthService().clearToken();
    print('Sesión de usuario cerrada.');
  }

  // Verificar si hay un usuario iniciado sesión
  static bool get isLoggedIn => _currentUser != null;

  // Agregar un producto a favoritos
  static Future<bool> addToFavorites(String productId) async {
    if (_currentUser != null) {
      try {
        // Actualizar la base de datos
        await DatabaseConfig.users.updateOne(
          where.id(ObjectId.fromHexString(_currentUser!.id)),
          modify.addToSet('favoriteProducts', productId),
        );

        // Obtener el usuario actualizado de la base de datos
        final updatedUserJson = await DatabaseConfig.users.findOne(
          where.id(ObjectId.fromHexString(_currentUser!.id)),
        );

        if (updatedUserJson != null) {
          // Recrear el objeto _currentUser con los datos actualizados
          _currentUser = User.fromJson(updatedUserJson);
          print(
              'Producto $productId agregado a favoritos. Usuario en memoria actualizado.');
          return true; // Indica éxito
        } else {
          print(
              'Error: No se pudo recuperar el usuario actualizado después de agregar favorito.');
          return false; // Indica fallo al actualizar el usuario en memoria
        }
      } catch (e) {
        print('Error al agregar a favoritos: $e');
        return false; // Indica fallo en la operación de base de datos
      }
    }
    return false; // Indica que no hay usuario logueado
  }

  // Remover un producto de favoritos
  static Future<bool> removeFromFavorites(String productId) async {
    if (_currentUser != null) {
      try {
        // Actualizar la base de datos
        await DatabaseConfig.users.updateOne(
          where.id(ObjectId.fromHexString(_currentUser!.id)),
          modify.pull('favoriteProducts', productId),
        );

        // Obtener el usuario actualizado de la base de datos
        final updatedUserJson = await DatabaseConfig.users.findOne(
          where.id(ObjectId.fromHexString(_currentUser!.id)),
        );

        if (updatedUserJson != null) {
          // Recrear el objeto _currentUser con los datos actualizados
          _currentUser = User.fromJson(updatedUserJson);
          print(
              'Producto $productId removido de favoritos. Usuario en memoria actualizado.');
          return true; // Indica éxito
        } else {
          print(
              'Error: No se pudo recuperar el usuario actualizado después de remover favorito.');
          return false; // Indica fallo al actualizar el usuario en memoria
        }
      } catch (e) {
        print('Error al remover de favoritos: $e');
        return false; // Indica fallo en la operación de base de datos
      }
    }
    return false; // Indica que no hay usuario logueado
  }

  // Verificar si un producto está en favoritos
  static bool isProductInFavorites(String productId) {
    return _currentUser?.favoriteProducts.contains(productId) ?? false;
  }

  // Agregar una dirección
  static Future<void> addAddress(String address) async {
    if (_currentUser != null) {
      try {
        await DatabaseConfig.users.updateOne(
          where.id(ObjectId.fromHexString(_currentUser!.id)),
          modify.addToSet('addresses', address),
        );
        final updatedAddresses = List<String>.from(_currentUser!.addresses)
          ..add(address);
        _currentUser = User(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          password: _currentUser!.password,
          avatarUrl: _currentUser!.avatarUrl,
          addresses: updatedAddresses,
          favoriteProducts: _currentUser!.favoriteProducts,
          publishedProducts: _currentUser!.publishedProducts,
          purchaseHistory: _currentUser!.purchaseHistory,
        );
        print('Dirección \'$address\' agregada en memoria y BD.');
      } catch (e) {
        print('Error al agregar dirección: $e');
      }
    }
  }

  // Remover una dirección
  static Future<void> removeAddress(String address) async {
    if (_currentUser != null) {
      try {
        await DatabaseConfig.users.updateOne(
          where.id(ObjectId.fromHexString(_currentUser!.id)),
          modify.pull('addresses', address),
        );
        final updatedAddresses = List<String>.from(_currentUser!.addresses)
          ..remove(address);
        _currentUser = User(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          password: _currentUser!.password,
          avatarUrl: _currentUser!.avatarUrl,
          addresses: updatedAddresses,
          favoriteProducts: _currentUser!.favoriteProducts,
          publishedProducts: _currentUser!.publishedProducts,
          purchaseHistory: _currentUser!.purchaseHistory,
        );
        print('Dirección \'$address\' removida en memoria y BD.');
      } catch (e) {
        print('Error al remover dirección: $e');
      }
    }
  }

  // Agregar una compra al historial
  static Future<void> addPurchase(String purchaseId) async {
    if (_currentUser != null) {
      try {
        await DatabaseConfig.users.updateOne(
          where.id(ObjectId.fromHexString(_currentUser!.id)),
          modify.addToSet('purchaseHistory', purchaseId),
        );
        final updatedHistory = List<String>.from(_currentUser!.purchaseHistory)
          ..add(purchaseId);
        _currentUser = User(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          password: _currentUser!.password,
          avatarUrl: _currentUser!.avatarUrl,
          addresses: _currentUser!.addresses,
          favoriteProducts: _currentUser!.favoriteProducts,
          publishedProducts: _currentUser!.publishedProducts,
          purchaseHistory: updatedHistory,
        );
        print('Compra $purchaseId agregada al historial en memoria y BD.');
      } catch (e) {
        print('Error al agregar compra al historial: $e');
      }
    }
  }

  // Agregar un producto publicado
  static Future<void> addPublishedProduct(String productId) async {
    if (_currentUser != null) {
      try {
        await DatabaseConfig.users.updateOne(
          where.id(ObjectId.fromHexString(_currentUser!.id)),
          modify.addToSet('publishedProducts', productId),
        );
        final updatedProducts =
            List<String>.from(_currentUser!.publishedProducts)..add(productId);
        _currentUser = User(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          password: _currentUser!.password,
          avatarUrl: _currentUser!.avatarUrl,
          addresses: _currentUser!.addresses,
          favoriteProducts: _currentUser!.favoriteProducts,
          publishedProducts: updatedProducts,
          purchaseHistory: _currentUser!.purchaseHistory,
        );
        print('Producto publicado $productId agregado en memoria y BD.');
      } catch (e) {
        print('Error al agregar producto publicado: $e');
      }
    }
  }

  // Método para obtener el ID del usuario actual
  static String? getCurrentUserId() {
    return _currentUser?.id;
  }

  // Método para limpiar el usuario actual (cerrar sesión)
  static void clearCurrentUser() {
    _currentUser = null;
    print('Usuario actual limpiado.');
  }

  // Método para actualizar un campo específico del usuario en la BD
  static Future<void> updateUserField(
      String userId, Map<String, dynamic> updates) async {
    try {
      final usersCollection = DatabaseConfig.users;

      // Asegurarse de que userId es un ObjectId si tu BD usa ObjectId como _id
      final objectId = ObjectId.fromHexString(userId);

      // Aplicar las actualizaciones usando modify.set para cada campo
      final updateModifiers = modify; // Usar el objeto modify
      updates.forEach((field, value) {
        updateModifiers.set(field, value); // Aplicar set para cada campo/valor
      });

      final result = await usersCollection.updateOne(
        where.id(objectId), // Buscar por el ID
        updateModifiers, // Aplicar los modificadores de actualización
      );

      if (result.isSuccess) {
        print('Usuario actualizado con éxito en MongoDB.');

        // Si el usuario actualizado es el usuario actual, actualizar también la instancia en memoria
        if (_currentUser != null && _currentUser!.id == userId) {
          if (updates.containsKey('favoriteProducts')) {
            _currentUser!.favoriteProducts.clear();
            _currentUser!.favoriteProducts
                .addAll(List<String>.from(updates['favoriteProducts']));
          }
        }
      } else {
        print('Error al actualizar usuario en MongoDB: ${result.writeError}');
        // TODO: Manejar errores de escritura de MongoDB de forma más específica
      }
    } catch (e) {
      print('Excepción al actualizar usuario en MongoDB: $e');
      // TODO: Manejar otras excepciones
    }
  }

  // Método para actualizar la lista completa de favoritos del usuario actual en la BD
  static Future<bool> updateFavoriteProducts(
      List<String> favoriteProductIds) async {
    final currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      print('Error: No hay usuario logueado para actualizar favoritos.');
      return false;
    }
    try {
      await updateUserField(
          currentUserId, {'favoriteProducts': favoriteProductIds});
      if (_currentUser != null) {
        _currentUser!.favoriteProducts.clear();
        _currentUser!.favoriteProducts.addAll(favoriteProductIds);
      }
      return true;
    } catch (e) {
      print('Error al actualizar favoritos en UserService: $e');
      return false;
    }
  }

  // Método para convertir un mapa (de MongoDB) a un objeto User
  static User fromJson(Map<String, dynamic> json) {
    // Sincroniza ambos campos si existen en la base
    final List<String> favs = List<String>.from(json['favoriteProducts'] ?? []);
    final List<String> favIds =
        List<String>.from(json['favoriteProductIds'] ?? []);
    final Set<String> allFavs = {...favs, ...favIds};
    return User(
      id: json['_id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      addresses: List<String>.from(json['addresses'] ?? []),
      favoriteProducts: allFavs.toList(),
      publishedProducts: List<String>.from(json['publishedProducts'] ?? []),
      purchaseHistory: List<String>.from(json['purchaseHistory'] ?? []),
    );
  }

  // Actualizar datos del usuario
  static Future<bool> updateProfile(
      {required String userId,
      required String name,
      required String email,
      String? password}) async {
    try {
      String hexId = userId;
      if (userId.startsWith('ObjectId(')) {
        hexId = userId.substring(9, userId.length - 1).replaceAll('"', '');
      }
      final updateData = <String, dynamic>{
        'name': name,
        'email': email,
      };
      if (password != null && password.isNotEmpty) {
        updateData['password'] =
            sha256.convert(utf8.encode(password)).toString();
      }
      var mod = modify;
      updateData.forEach((key, value) {
        mod = mod.set(key, value);
      });
      await DatabaseConfig.users.updateOne(
        where.id(ObjectId.fromHexString(hexId)),
        mod,
      );
      // Refrescar usuario en memoria
      final updatedUserJson = await DatabaseConfig.users
          .findOne(where.id(ObjectId.fromHexString(hexId)));
      if (updatedUserJson != null) {
        setCurrentUser(User.fromJson(updatedUserJson));
        return true;
      }
      return false;
    } catch (e) {
      print('Error al actualizar perfil: $e');
      return false;
    }
  }
}
