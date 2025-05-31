class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final List<String> addresses;
  final List<String> favoriteProducts;
  final List<String> publishedProducts;
  final List<String> purchaseHistory;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.addresses = const [],
    this.favoriteProducts = const [],
    this.publishedProducts = const [],
    this.purchaseHistory = const [],
  });

  // Usuario de prueba
  static User get testUser => User(
    id: '1',
    name: 'Usuario de Prueba',
    email: 'usuario@prueba.com',
    profileImage: 'assets/images/placeholder.png',
    addresses: [
      'Calle Principal 123, Ciudad de Ejemplo',
      'Avenida Central 456, Ciudad de Ejemplo',
    ],
    favoriteProducts: ['1', '2', '3'],
    publishedProducts: ['1', '2', '3'],
    purchaseHistory: ['1', '2'],
  );
}
