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
        print('Error al inicializar SharedPreferences: $e');
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
      // Puedes agregar aquí lógica propia si necesitas mantener el usuario en memoria
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

      final userJson = _prefs?.getString(_userKey);

      if (userJson != null) {
        // Convertir el JSON guardado de vuelta a objeto User
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;

        final user = User(
          id: userMap['id'] as String,
          name: userMap['name'] as String,
          email: userMap['email'] as String,
          password: '', // No hay password en el almacenamiento local
          avatarUrl: userMap['avatarUrl'] as String?,
          addresses: List<String>.from(userMap['addresses'] ?? []),
          favoriteProducts:
              List<String>.from(userMap['favoriteProducts'] ?? []),
          publishedProducts:
              List<String>.from(userMap['publishedProducts'] ?? []),
          purchaseHistory: List<String>.from(userMap['purchaseHistory'] ?? []),
        );
        // Puedes guardar el usuario en memoria aquí si lo necesitas
        print('Sesión cargada para usuario: ${user.email}');
        return true;
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
      // Cerrar sesión en FirebaseAuth
      await fb_auth.FirebaseAuth.instance.signOut();
      // Si tienes lógica para limpiar usuario en memoria, agrégala aquí
      print('Sesión cerrada.');
    } catch (e) {
      print('Error al cerrar sesión: $e');
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
        // Puedes crear tu modelo User aquí si necesitas más datos
        final user = User(
          id: fbUser.uid,
          name: fbUser.displayName ?? '',
          email: fbUser.email ?? '',
          password: '',
        );
        // Firebase no da un token JWT por defecto, pero puedes usar el idToken si lo necesitas
        final token = await fbUser.getIdToken();
        return {'user': user, 'token': token};
      }
      return null;
    } catch (e) {
      print('Error en loginWithEmailPassword: $e');
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
      print('Error en registerWithEmailPassword: $e');
      rethrow;
    }
  }
}
