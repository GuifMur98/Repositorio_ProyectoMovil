import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class JwtService {
  static const String _secret =
      'tu_clave_secreta_muy_segura'; // TODO: Mover a variables de entorno

  // Generar token JWT
  static String generateToken(String userId) {
    final now = DateTime.now();
    final expiresAt =
        now.add(const Duration(days: 7)); // Token válido por 7 días

    final header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    final payload = {
      'sub': userId,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
    };

    final encodedHeader = base64Url.encode(utf8.encode(json.encode(header)));
    final encodedPayload = base64Url.encode(utf8.encode(json.encode(payload)));

    final signature = Hmac(sha256, utf8.encode(_secret))
        .convert(utf8.encode('$encodedHeader.$encodedPayload'))
        .bytes;
    final encodedSignature = base64Url.encode(signature);

    return '$encodedHeader.$encodedPayload.$encodedSignature';
  }

  // Verificar token JWT
  static bool verifyToken(String token) {
    try {
      return JwtDecoder.isExpired(token) == false;
    } catch (e) {
      return false;
    }
  }

  // Decodificar token JWT
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  // Obtener ID de usuario del token
  static String? getUserIdFromToken(String token) {
    try {
      final decoded = JwtDecoder.decode(token);
      return decoded['sub'] as String?;
    } catch (e) {
      return null;
    }
  }
}
