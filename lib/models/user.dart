class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? avatarUrl;
  final List<String> addresses;
  final List<String> favoriteProducts;
  final List<String> publishedProducts;
  final List<String> purchaseHistory;
  final List<String> favoriteProductIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.avatarUrl,
    this.addresses = const [],
    this.favoriteProducts = const [],
    this.publishedProducts = const [],
    this.purchaseHistory = const [],
    this.favoriteProductIds = const [],
  });

  // Método para convertir un objeto User a un mapa JSON (por ejemplo, para guardar en SharedPreferences o enviar al backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      // No incluir password aquí por seguridad si es para almacenamiento local o tokens
      'avatarUrl': avatarUrl,
      'addresses': addresses,
      'favoriteProducts': favoriteProducts,
      'publishedProducts': publishedProducts,
      'purchaseHistory': purchaseHistory,
      'favoriteProductIds': favoriteProductIds,
    };
  }

  // Constructor de fábrica para crear un objeto User desde un mapa JSON (de MongoDB)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'].toString(), // MongoDB usa '_id'
      name: json['name'],
      email: json['email'],
      password: json['password'] as String? ?? '', // Manejar password opcional
      avatarUrl:
          json['avatarUrl'] as String?, // Manejar avatarUrl opcional y tipo
      addresses: List<String>.from(
          json['addresses'] ?? []), // Manejar listas opcionales
      favoriteProducts: List<String>.from(
          json['favoriteProducts'] ?? []), // Manejar listas opcionales
      publishedProducts: List<String>.from(
          json['publishedProducts'] ?? []), // Manejar listas opcionales
      purchaseHistory: List<String>.from(
          json['purchaseHistory'] ?? []), // Manejar listas opcionales
      favoriteProductIds: List<String>.from(
          json['favoriteProductIds'] ?? []), // Manejar listas opcionales
    );
  }
}
