class Favorite {
  final String id;
  final String userId;
  final String productId;

  Favorite({
    required this.id,
    required this.userId,
    required this.productId,
  });

  factory Favorite.fromJson(Map<String, dynamic> json, {String? id}) =>
      Favorite(
        id: id ?? json['id'] ?? '',
        userId: json['userId'] ?? '',
        productId: json['productId'] ?? '',
      );

  factory Favorite.fromFirestore(Map<String, dynamic> json, String id) {
    return Favorite.fromJson(json, id: id);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'productId': productId,
      };

  Map<String, dynamic> toFirestore() => toJson();
}
