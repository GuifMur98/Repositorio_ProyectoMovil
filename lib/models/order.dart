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

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['_id'] ?? '',
        userId: json['userId'] ?? '',
        productIds: List<String>.from(json['productIds'] ?? []),
        total: (json['total'] ?? 0).toDouble(),
        date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
        status: json['status'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'productIds': productIds,
        'total': total,
        'date': date.toIso8601String(),
        'status': status,
      };
}
