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
  });

  // Método para convertir un objeto User a un mapa JSON (por ejemplo, para guardar en SharedPreferences o enviar al backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'avatarUrl': avatarUrl,
      'addresses': addresses,
      'favoriteProducts': favoriteProducts,
      'publishedProducts': publishedProducts,
      'purchaseHistory': purchaseHistory,
    };
  }

  // Constructor de fábrica para crear un objeto User desde un mapa JSON (de MongoDB)
  factory User.fromJson(Map<String, dynamic> json, {String? id}) {
    return User(
      id: id ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      avatarUrl: json['avatarUrl'],
      addresses: List<String>.from(json['addresses'] ?? []),
      favoriteProducts: List<String>.from(json['favoriteProducts'] ?? []),
      publishedProducts: List<String>.from(json['publishedProducts'] ?? []),
      purchaseHistory: List<String>.from(json['purchaseHistory'] ?? []),
    );
  }

  // Para usar con Firestore snapshots
  factory User.fromFirestore(Map<String, dynamic> json, String id) {
    return User.fromJson(json, id: id);
  }

  Map<String, dynamic> toFirestore() => toJson();
}
