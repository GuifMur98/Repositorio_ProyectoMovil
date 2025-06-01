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
}
