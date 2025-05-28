import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto/services/database_service.dart';
import 'package:proyecto/models/user.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Método para iniciar sesión usando la base de datos
  static Future<bool> login(String email, String password) async {
    final users = await DatabaseService.getUsers();
    final user = users.firstWhere(
      (u) => u.email == email && u.password == password,
      orElse: () => throw Exception('Credenciales inválidas'),
    );

    // Guardar el estado de la sesión
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_id', user.id.toString());

    return true;
  }

  // Método para cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
  }

  // Método para verificar si el usuario está autenticado
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
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
