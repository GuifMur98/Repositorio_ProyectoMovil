import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto/services/database_service.dart';
import 'package:proyecto/models/user.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Método para iniciar sesión usando la base de datos
  static Future<bool> login(String email, String password) async {
    final user = await DatabaseService.getUserByEmail(email);
    if (user != null && user.password == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userKey, user.name);
      await prefs.setString('user_email', user.email);
      return true;
    }
    return false;
  }

  // Método para cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userKey);
    await prefs.remove('user_email');
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

  // Método para obtener el email del usuario
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  // Método para obtener credenciales de prueba (solo para desarrollo)
  static Map<String, String> getTestCredentials() {
    return {'email': 'test@example.com', 'password': 'test1234'};
  }
}
