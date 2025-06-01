import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import 'user_service.dart';
import 'jwt_service.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';
  static SharedPreferences? _prefs;

  // Inicializar SharedPreferences
  static Future<void> _initPrefs() async {
    if (_prefs == null) {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (e) {
        print('Error al inicializar SharedPreferences: $e');
        rethrow;
      }
    }
  }

  // Guardar sesión
  static Future<void> saveSession(User user, String token) async {
    try {
      await _initPrefs();

      // Verificar que el token sea válido antes de guardar
      if (!JwtService.verifyToken(token)) {
        throw Exception('Token inválido o expirado');
      }

      // Usar el método toJson del modelo User para obtener el mapa JSON
      final userJsonMap = user.toJson();
      // No guardar campos sensibles como password en almacenamiento local
      userJsonMap.remove('password');

      await _prefs?.setString(_userKey, jsonEncode(userJsonMap));
      await _prefs?.setString(_tokenKey, token);

      // *** Verificación añadida: Confirmar que el token se guardó correctamente ***
      final savedToken = _prefs?.getString(_tokenKey);
      if (savedToken == token) {
        print('Token guardado y verificado exitosamente.');
      } else {
        print(
            'Error: El token guardado no coincide con el token proporcionado.');
        // Esto podría indicar un problema con shared_preferences
      }
      // *********************************************************************

      // Establecer el usuario actual
      UserService.setCurrentUser(user);

      print('Sesión guardada para usuario: ${user.email}');
    } catch (e) {
      print('Error al guardar sesión: $e');
      await logout(); // Limpiar sesión en caso de error
      rethrow;
    }
  }

  // Cargar sesión
  static Future<bool> loadSession() async {
    try {
      await _initPrefs();
      // final userJson = _prefs?.getString(_userKey); // Ya no necesitamos cargar el JSON directamente para la sesión
      final token = _prefs?.getString(_tokenKey);

      if (token != null) {
        // Verificar si el token es válido y no ha expirado
        if (!JwtService.verifyToken(token)) {
          print('Token inválido o expirado.');
          await logout(); // Cerrar sesión si el token no es válido
          return false;
        }

        // Obtener el usuario desde el token
        final decodedToken = JwtService.decodeToken(token);
        if (decodedToken != null) {
          final user = User(
            id: decodedToken['sub'] as String,
            name: decodedToken['name'] as String,
            email: decodedToken['email'] as String,
            password: '', // No hay password en el token
            avatarUrl: decodedToken['avatarUrl'] as String?,
            addresses: List<String>.from(decodedToken['addresses'] ?? []),
            favoriteProducts:
                List<String>.from(decodedToken['favoriteProducts'] ?? []),
            publishedProducts:
                List<String>.from(decodedToken['publishedProducts'] ?? []),
            purchaseHistory:
                List<String>.from(decodedToken['purchaseHistory'] ?? []),
            favoriteProductIds:
                List<String>.from(decodedToken['favoriteProductIds'] ?? []),
          );
          UserService.setCurrentUser(user);
          print('Sesión cargada desde token para usuario: ${user.email}');
          return true;
        }
      }

      print('No hay sesión válida para cargar.');
      return false;
    } catch (e) {
      print('Error al cargar sesión: $e');
      await logout(); // Limpiar sesión en caso de error
      return false;
    }
  }

  // Cerrar sesión
  static Future<void> logout() async {
    try {
      await _initPrefs();
      await _prefs?.remove(_userKey);
      await _prefs?.remove(_tokenKey);
      UserService
          .clearCurrentUser(); // Usar el método de UserService para limpiar
      print('Sesión cerrada.');
    } catch (e) {
      print('Error al cerrar sesión: $e');
      rethrow;
    }
  }

  // Limpiar solo el token (usado internamente o si es necesario)
  Future<void> clearToken() async {
    try {
      await _initPrefs();
      await _prefs?.remove(_tokenKey);
      print('Token de autenticación limpiado.');
    } catch (e) {
      print('Error al limpiar token: $e');
      rethrow;
    }
  }

  // Verificar si hay sesión activa (basado en token)
  static Future<bool> isLoggedIn() async {
    try {
      await _initPrefs();
      final token = _prefs?.getString(_tokenKey);
      // final userJson = _prefs?.getString(_userKey); // Ya no necesitamos verificar el JSON aquí

      if (token == null) {
        print('No hay token guardado.');
        return false;
      }

      // Verificar si el token es válido y no ha expirado
      if (!JwtService.verifyToken(token)) {
        print('Token inválido o expirado.');
        await logout(); // Cerrar sesión si el token no es válido
        return false;
      }

      // Si hay token y es válido, la sesión se considera activa
      // La carga de los datos del usuario se realiza en loadSession
      return true;
    } catch (e) {
      print('Error al verificar sesión: $e');
      await logout(); // Cerrar sesión en caso de error
      return false;
    }
  }

  // Generar token para un usuario (debería estar en JwtService, pero se mantiene aquí por referencia)
  // static String generateToken(User user) {
  //   return JwtService.generateToken(user.id);
  // }

  // Obtener token guardado
  Future<String?> getToken() async {
    await _initPrefs();
    return _prefs?.getString(_tokenKey);
  }

  // Decodificar token y crear objeto User
  Future<User?> getUserFromToken(String token) async {
    try {
      // Verificar y decodificar el token
      final decodedToken = JwtService.decodeToken(token);

      // Si el token es inválido o expirado, decodeToken puede retornar null o lanzar error
      // Ya verificamos la validez en loadSession/isLoggedIn, pero aquí manejamos el resultado
      if (decodedToken == null) {
        print('No se pudo decodificar el token o es inválido.');
        return null;
      }

      final userData = decodedToken; // decodedToken es Map<String, dynamic>

      // Reconstruir el objeto User desde el payload del token
      // Asegurarse de pasar el password (vacío) y usar avatarUrl
      final user = User(
        id: userData['id'] as String,
        name: userData['name'] as String,
        email: userData['email'] as String,
        password: '', // No hay password en el token
        avatarUrl: userData['avatarUrl'] as String?, // Usar avatarUrl
        addresses: List<String>.from(userData['addresses'] ?? []),
        favoriteProducts: List<String>.from(userData['favoriteProducts'] ?? []),
        publishedProducts:
            List<String>.from(userData['publishedProducts'] ?? []),
        purchaseHistory: List<String>.from(userData['purchaseHistory'] ?? []),
        favoriteProductIds:
            List<String>.from(userData['favoriteProductIds'] ?? []),
      );
      return user;
    } catch (e) {
      print('Error al obtener usuario desde token: $e');
      // Dependiendo del manejo de errores de JwtService.decodeToken, podrías relanzar
      // o retornar null. Aquí retornamos null en caso de error.
      return null;
    }
  }
}
