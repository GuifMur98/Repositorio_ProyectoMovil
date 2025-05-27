import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Usuario de prueba
  static final Map<String, String> _testUser = {
    'email': 'test@example.com',
    'password': 'password123',
    'name': 'Usuario de Prueba',
  };

  // Método para iniciar sesión
  static Future<bool> login(String email, String password) async {
    if (email == _testUser['email'] && password == _testUser['password']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userKey, _testUser['name']!);
      return true;
    }
    return false;
  }

  // Método para cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userKey);
  }

  // Método para verificar si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Método para obtener el nombre del usuario
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  // Método para obtener las credenciales de prueba
  static Map<String, String> getTestCredentials() {
    return {
      'email': _testUser['email']!,
      'password': _testUser['password']!,
    };
  }
}