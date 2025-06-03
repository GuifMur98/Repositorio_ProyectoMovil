class Favorite {
  final String id;
  final String userId;
  final String productId;

  Favorite({
    required this.id,
    required this.userId,
    required this.productId,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json['_id'] ?? '',
        userId: json['userId'] ?? '',
        productId: json['productId'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'productId': productId,
      };
}
