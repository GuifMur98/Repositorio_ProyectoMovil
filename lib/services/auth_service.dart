import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class AuthService {
  static const String _userKey = 'current_user';
  static SharedPreferences? _prefs;

  // Inicializar SharedPreferences
  static Future<void> _initPrefs() async {
    if (_prefs == null) {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (e) {
        rethrow;
      }
    }
  }

  // Guardar sesión
  static Future<void> saveSession(User user) async {
    try {
      await _initPrefs();

      // Usar el método toJson del modelo User para obtener el mapa JSON
      final userJsonMap = user.toJson();
      // No guardar campos sensibles como password en almacenamiento local
      userJsonMap.remove('password');

      await _prefs?.setString(_userKey, jsonEncode(userJsonMap));

      // Establecer el usuario actual en memoria si es necesario
    } catch (e) {
      await logout(); // Limpiar sesión en caso de error
      rethrow;
    }
  }

  // Cargar sesión
  static Future<bool> loadSession() async {
    try {
      await _initPrefs();

      final userJson = _prefs?.getString(_userKey);

      if (userJson != null) {
        // Convertir el JSON guardado de vuelta a objeto User
        jsonDecode(userJson);

        return true;
      }

      return false;
    } catch (e) {
      await logout(); // Limpiar sesión en caso de error
      return false;
    }
  }

  // Cerrar sesión
  static Future<void> logout() async {
    try {
      await _initPrefs();
      await _prefs?.remove(_userKey);
      // Cerrar sesión en FirebaseAuth
      await fb_auth.FirebaseAuth.instance.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Cargar usuario actual
  static Future<User?> getCurrentUser() async {
    await _initPrefs();
    final userJson = _prefs?.getString(_userKey);
    if (userJson == null) return null;
    final userMap = jsonDecode(userJson);
    return User.fromJson(userMap);
  }

  // Login con FirebaseAuth
  static Future<Map<String, dynamic>?> loginWithEmailPassword(
      String email, String password) async {
    try {
      final credential = await fb_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final fbUser = credential.user;
      if (fbUser != null) {
        final user = User(
          id: fbUser.uid,
          name: fbUser.displayName ?? '',
          email: fbUser.email ?? '',
          password: '',
        );
        final token = await fbUser.getIdToken();
        return {'user': user, 'token': token};
      }
      return null;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Errores comunes de login
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw Exception('Credenciales incorrectas');
      } else if (e.code == 'invalid-email') {
        throw Exception('Correo electrónico inválido');
      } else if (e.code == 'user-disabled') {
        throw Exception('La cuenta está deshabilitada');
      } else {
        throw Exception('Error de autenticación');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Registro con FirebaseAuth
  static Future<Map<String, dynamic>?> registerWithEmailPassword(
      String name, String email, String password) async {
    try {
      final credential = await fb_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final fbUser = credential.user;
      if (fbUser != null) {
        // Actualizar el displayName
        await fbUser.updateDisplayName(name);
        final user = User(
          id: fbUser.uid,
          name: name,
          email: fbUser.email ?? '',
          password: '',
        );
        final token = await fbUser.getIdToken();
        return {'user': user, 'token': token};
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
