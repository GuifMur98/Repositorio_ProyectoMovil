class Order {
  final String id;
  final String userId;
  final List<String> productIds;
  final double total;
  final DateTime date;
  final String status;

  Order({
    required this.id,
    required this.userId,
    required this.productIds,
    required this.total,
    required this.date,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json, {String? id}) => Order(
        id: id ?? json['id'] ?? '',
        userId: json['userId'] ?? '',
        productIds: List<String>.from(json['productIds'] ?? []),
        total: (json['total'] is int)
            ? (json['total'] as int).toDouble()
            : (json['total'] ?? 0.0).toDouble(),
        date: json['date'] != null
            ? DateTime.tryParse(json['date']) ?? DateTime.now()
            : DateTime.now(),
        status: json['status'] ?? '',
      );

  factory Order.fromFirestore(Map<String, dynamic> json, String id) {
    return Order.fromJson(json, id: id);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'productIds': productIds,
        'total': total,
        'date': date.toIso8601String(),
        'status': status,
      };

  Map<String, dynamic> toFirestore() => toJson();
}
