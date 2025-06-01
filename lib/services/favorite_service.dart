import 'package:proyecto/models/user.dart';
import 'package:proyecto/services/user_service.dart'; // Asumo que UserService tiene una forma de actualizar el usuario en la BD
// import 'package:proyecto/config/database.dart'; // Podríamos necesitar esto para interactuar directamente con MongoDB

class FavoriteService {
  // Método para añadir un producto a la lista de favoritos del usuario actual
  static Future<bool> addFavoriteProduct(String productId) async {
    final currentUser = UserService.currentUser; // Obtener el usuario actual
    if (currentUser == null) {
      print('Error: No hay usuario logueado.');
      return false; // No hay usuario logueado
    }

    // Evitar duplicados
    if (currentUser.favoriteProducts.contains(productId)) {
      print('Producto ya está en favoritos.');
      return true; // Ya está en favoritos, consideramos la operación exitosa
    }

    // Crear una nueva lista de favoritos con el nuevo producto
    final updatedFavorites = List<String>.from(currentUser.favoriteProducts);
    updatedFavorites.add(productId);

    // Crear un nuevo objeto User con la lista de favoritos actualizada
    final updatedUser = User(
      id: currentUser.id,
      name: currentUser.name,
      email: currentUser.email,
      password: currentUser.password,
      avatarUrl: currentUser.avatarUrl,
      addresses: currentUser.addresses,
      favoriteProducts: updatedFavorites,
      publishedProducts: currentUser.publishedProducts,
      purchaseHistory: currentUser.purchaseHistory,
    );

    try {
      // Aquí deberías tener la lógica para actualizar el usuario en la base de datos
      // Por ahora, solo actualizaremos el currentUser en UserService (simulación de éxito)
      // En una aplicación real, harías algo como:
      // final success = await DatabaseConfig.updateUser(updatedUser.id, {'favoriteProducts': updatedFavorites});
      // if (success) { UserService.setCurrentUser(updatedUser); return true; }
      // return false;

      // **Simulación de actualización exitosa:**
      UserService.setCurrentUser(
          updatedUser); // Actualiza la instancia en memoria
      print('Producto $productId añadido a favoritos.');
      return true;
    } catch (e) {
      print('Error al añadir producto a favoritos: $e');
      return false; // Error al actualizar en la base de datos
    }
  }

  // Método para eliminar un producto de la lista de favoritos del usuario actual
  static Future<bool> removeFavoriteProduct(String productId) async {
    final currentUser = UserService.currentUser; // Obtener el usuario actual
    if (currentUser == null) {
      print('Error: No hay usuario logueado.');
      return false; // No hay usuario logueado
    }

    // Si el producto no está en favoritos, no hay nada que eliminar
    if (!currentUser.favoriteProducts.contains(productId)) {
      print('Producto no está en favoritos.');
      return true; // No está en favoritos, consideramos la operación exitosa
    }

    // Crear una nueva lista de favoritos sin el producto a eliminar
    final updatedFavorites = List<String>.from(currentUser.favoriteProducts);
    updatedFavorites.remove(productId);

    // Crear un nuevo objeto User con la lista de favoritos actualizada
    final updatedUser = User(
      id: currentUser.id,
      name: currentUser.name,
      email: currentUser.email,
      password: currentUser.password,
      avatarUrl: currentUser.avatarUrl,
      addresses: currentUser.addresses,
      favoriteProducts: updatedFavorites,
      publishedProducts: currentUser.publishedProducts,
      purchaseHistory: currentUser.purchaseHistory,
    );

    try {
      // Aquí deberías tener la lógica para actualizar el usuario en la base de datos
      // Por ahora, solo actualizaremos el currentUser en UserService (simulación de éxito)
      // En una aplicación real, harías algo como:
      // final success = await DatabaseConfig.updateUser(updatedUser.id, {'favoriteProducts': updatedFavorites});
      // if (success) { UserService.setCurrentUser(updatedUser); return true; }
      // return false;

      // **Simulación de actualización exitosa:**
      UserService.setCurrentUser(
          updatedUser); // Actualiza la instancia en memoria
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
}
