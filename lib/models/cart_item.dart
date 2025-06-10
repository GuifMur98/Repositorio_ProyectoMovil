class CartItem {
  final String id;
  final String userId;
  final String productId;
  final int quantity;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json, {String? id}) =>
      CartItem(
        id: id ?? json['id']?.toString() ?? '',
        userId: json['userId'] ?? '',
        productId: json['productId'] ?? '',
        quantity: json['quantity'] ?? 1,
      );

  factory CartItem.fromFirestore(Map<String, dynamic> json, String id) {
    return CartItem.fromJson(json, id: id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
    };
  }

  Map<String, dynamic> toFirestore() => toJson();
}
