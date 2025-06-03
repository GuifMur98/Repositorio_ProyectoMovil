import 'package:proyecto/models/user.dart';
import 'package:proyecto/services/user_service.dart'; // Asumo que UserService tiene una forma de actualizar el usuario en la BD
import '../config/database.dart';
import 'package:mongo_dart/mongo_dart.dart';

class FavoriteService {
  // Método para añadir un producto a la lista de favoritos del usuario actual
  static Future<bool> addFavoriteProduct(String productId) async {
    final currentUser = UserService.currentUser;
    if (currentUser == null) {
      print('Error: No hay usuario logueado.');
      return false;
    }
    if (currentUser.favoriteProducts.contains(productId)) {
      print('Producto ya está en favoritos.');
      return true;
    }
    final updatedFavorites = List<String>.from(currentUser.favoriteProducts);
    updatedFavorites.add(productId);
    try {
      // Actualizar en la base de datos
      await DatabaseConfig.users.updateOne(
        where.id(ObjectId.fromHexString(_extractHexId(currentUser.id))),
        modify.set('favoriteProducts', updatedFavorites),
      );
      // Refrescar usuario en memoria
      final updatedUserJson = await DatabaseConfig.users.findOne(
          where.id(ObjectId.fromHexString(_extractHexId(currentUser.id))));
      if (updatedUserJson != null) {
        UserService.setCurrentUser(User.fromJson(updatedUserJson));
      }
      print('Producto $productId añadido a favoritos.');
      return true;
    } catch (e) {
      print('Error al añadir producto a favoritos: $e');
      return false;
    }
  }

  // Método para eliminar un producto de la lista de favoritos del usuario actual
  static Future<bool> removeFavoriteProduct(String productId) async {
    final currentUser = UserService.currentUser;
    if (currentUser == null) {
      print('Error: No hay usuario logueado.');
      return false;
    }
    if (!currentUser.favoriteProducts.contains(productId)) {
      print('Producto no está en favoritos.');
      return true; // No está en favoritos, consideramos la operación exitosa
    }
    final updatedFavorites = List<String>.from(currentUser.favoriteProducts);
    updatedFavorites.remove(productId);
    try {
      // Actualizar en la base de datos
      await DatabaseConfig.users.updateOne(
        where.id(ObjectId.fromHexString(_extractHexId(currentUser.id))),
        modify.set('favoriteProducts', updatedFavorites),
      );
      // Refrescar usuario en memoria
      final updatedUserJson = await DatabaseConfig.users.findOne(
          where.id(ObjectId.fromHexString(_extractHexId(currentUser.id))));
      if (updatedUserJson != null) {
        UserService.setCurrentUser(User.fromJson(updatedUserJson));
      }
      print('Producto $productId eliminado de favoritos.');
      return true;
    } catch (e) {
      print('Error al eliminar producto de favoritos: $e');
      return false; // Error al actualizar en la base de datos
    }
  }

  // Método para verificar si un producto está en la lista de favoritos del usuario actual
  static bool isFavoriteProduct(String productId) {
    final currentUser = UserService.currentUser; // Obtener el usuario actual
    if (currentUser == null) {
      return false; // No hay usuario logueado
    }
    return currentUser.favoriteProducts.contains(productId);
  }

  // Método para obtener la lista de productos favoritos del usuario actual (solo IDs)
  static List<String> getUserFavoriteProductIds() {
    final currentUser = UserService.currentUser; // Obtener el usuario actual
    if (currentUser == null) {
      return []; // No hay usuario logueado
    }
    return currentUser.favoriteProducts;
  }

  // Método para alternar el estado de favorito de un producto
  static Future<bool> toggleFavorite(String productId) async {
    final currentUser = UserService.currentUser; // Obtener el usuario actual
    if (currentUser == null) {
      print('Error: No hay usuario logueado para alternar favoritos.');
      return false;
    }

    if (isFavoriteProduct(productId)) {
      // Si ya es favorito, lo eliminamos
      return await removeFavoriteProduct(productId);
    } else {
      // Si no es favorito, lo añadimos
      return await addFavoriteProduct(productId);
    }
  }

  // TODO: Implementar método para obtener los objetos Product completos de los favoritos
  // Esto requeriría un método en ProductService para buscar productos por IDs
  /*
   static Future<List<Product>> getUserFavoriteProducts() async {
      final favoriteIds = getUserFavoriteProductIds();
      if (favoriteIds.isEmpty) return [];

      // Asumiendo que tienes un ProductService con un método getProductsByIds
      // return await ProductService.getProductsByIds(favoriteIds);
      return []; // Simulación
   }
   */

  static String _extractHexId(String id) {
    // Extrae el string hexadecimal de 24 caracteres de cualquier id tipo ObjectId("...") o similar
    final regex = RegExp(r'[a-fA-F0-9]{24}');
    final match = regex.firstMatch(id);
    if (match != null) {
      return match.group(0)!;
    }
    throw ArgumentError('ID inválido: $id');
  }
}
