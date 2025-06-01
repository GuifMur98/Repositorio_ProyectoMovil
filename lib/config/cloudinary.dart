import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryConfig {
  static late CloudinaryPublic cloudinary;

  static void initialize() {
    cloudinary = CloudinaryPublic(
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '',
      'auto',
    );
  }

  static Future<String> uploadImage(String filePath) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          filePath,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Error al subir imagen a Cloudinary: $e');
      rethrow;
    }
  }
}
