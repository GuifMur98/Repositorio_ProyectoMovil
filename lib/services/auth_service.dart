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
      await _prefs?.setString(
        _userKey,
        jsonEncode({
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'profileImage': user.profileImage,
          'addresses': user.addresses,
          'favoriteProducts': user.favoriteProducts,
          'publishedProducts': user.publishedProducts,
          'purchaseHistory': user.purchaseHistory,
        }),
      );
      await _prefs?.setString(_tokenKey, token);
    } catch (e) {
      print('Error al guardar sesión: $e');
      rethrow;
    }
  }

  // Cargar sesión
  static Future<bool> loadSession() async {
    try {
      await _initPrefs();
      final userJson = _prefs?.getString(_userKey);
      final token = _prefs?.getString(_tokenKey);

      if (userJson != null && token != null) {
        // Verificar si el token es válido
        if (!JwtService.verifyToken(token)) {
          await logout();
          return false;
        }

        final userData = jsonDecode(userJson);
        UserService.setCurrentUser(
          User(
            id: userData['id'],
            name: userData['name'],
            email: userData['email'],
            profileImage: userData['profileImage'],
            addresses: List<String>.from(userData['addresses']),
            favoriteProducts: List<String>.from(userData['favoriteProducts']),
            publishedProducts: List<String>.from(userData['publishedProducts']),
            purchaseHistory: List<String>.from(userData['purchaseHistory']),
          ),
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error al cargar sesión: $e');
      return false;
    }
  }

  // Cerrar sesión
  static Future<void> logout() async {
    try {
      await _initPrefs();
      await _prefs?.remove(_userKey);
      await _prefs?.remove(_tokenKey);
      UserService.logout();
    } catch (e) {
      print('Error al cerrar sesión: $e');
      rethrow;
    }
  }

  // Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    try {
      await _initPrefs();
      final token = _prefs?.getString(_tokenKey);

      if (token == null) return false;

      return JwtService.verifyToken(token);
    } catch (e) {
      print('Error al verificar sesión: $e');
      return false;
    }
  }

  // Generar token para un usuario
  static String generateToken(User user) {
    return JwtService.generateToken(user.id);
  }
}
