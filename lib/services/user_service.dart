import '../models/user.dart';

class UserService {
  static User? _currentUser;

  // Obtener el usuario actual
  static User? get currentUser => _currentUser;

  // Iniciar sesión con el usuario de prueba
  static void login() {
    _currentUser = User.testUser;
  }

  // Cerrar sesión
  static void logout() {
    _currentUser = null;
  }

  // Verificar si hay un usuario iniciado sesión
  static bool get isLoggedIn => _currentUser != null;

  // Agregar un producto a favoritos
  static void addToFavorites(String productId) {
    if (_currentUser != null) {
      final updatedFavorites = List<String>.from(_currentUser!.favoriteProducts)
        ..add(productId);
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        profileImage: _currentUser!.profileImage,
        addresses: _currentUser!.addresses,
        favoriteProducts: updatedFavorites,
        publishedProducts: _currentUser!.publishedProducts,
        purchaseHistory: _currentUser!.purchaseHistory,
      );
    }
  }

  // Remover un producto de favoritos
  static void removeFromFavorites(String productId) {
    if (_currentUser != null) {
      final updatedFavorites = List<String>.from(_currentUser!.favoriteProducts)
        ..remove(productId);
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        profileImage: _currentUser!.profileImage,
        addresses: _currentUser!.addresses,
        favoriteProducts: updatedFavorites,
        publishedProducts: _currentUser!.publishedProducts,
        purchaseHistory: _currentUser!.purchaseHistory,
      );
    }
  }

  // Verificar si un producto está en favoritos
  static bool isProductInFavorites(String productId) {
    return _currentUser?.favoriteProducts.contains(productId) ?? false;
  }

  // Agregar una dirección
  static void addAddress(String address) {
    if (_currentUser != null) {
      final updatedAddresses = List<String>.from(_currentUser!.addresses)
        ..add(address);
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        profileImage: _currentUser!.profileImage,
        addresses: updatedAddresses,
        favoriteProducts: _currentUser!.favoriteProducts,
        publishedProducts: _currentUser!.publishedProducts,
        purchaseHistory: _currentUser!.purchaseHistory,
      );
    }
  }

  // Remover una dirección
  static void removeAddress(String address) {
    if (_currentUser != null) {
      final updatedAddresses = List<String>.from(_currentUser!.addresses)
        ..remove(address);
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        profileImage: _currentUser!.profileImage,
        addresses: updatedAddresses,
        favoriteProducts: _currentUser!.favoriteProducts,
        publishedProducts: _currentUser!.publishedProducts,
        purchaseHistory: _currentUser!.purchaseHistory,
      );
    }
  }

  // Agregar una compra al historial
  static void addPurchase(String purchaseId) {
    if (_currentUser != null) {
      final updatedHistory = List<String>.from(_currentUser!.purchaseHistory)
        ..add(purchaseId);
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        profileImage: _currentUser!.profileImage,
        addresses: _currentUser!.addresses,
        favoriteProducts: _currentUser!.favoriteProducts,
        publishedProducts: _currentUser!.publishedProducts,
        purchaseHistory: updatedHistory,
      );
    }
  }

  // Agregar un producto publicado
  static void addPublishedProduct(String productId) {
    if (_currentUser != null) {
      final updatedProducts = List<String>.from(_currentUser!.publishedProducts)
        ..add(productId);
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        profileImage: _currentUser!.profileImage,
        addresses: _currentUser!.addresses,
        favoriteProducts: _currentUser!.favoriteProducts,
        publishedProducts: updatedProducts,
        purchaseHistory: _currentUser!.purchaseHistory,
      );
    }
  }
}
