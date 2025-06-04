class Purchase {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> products;
  final double total;
  final DateTime date;

  Purchase({
    required this.id,
    required this.userId,
    required this.products,
    required this.total,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'products': products,
        'total': total,
        'date': date.toIso8601String(),
      };

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json['id'],
        userId: json['userId'],
        products: List<Map<String, dynamic>>.from(json['products']),
        total: (json['total'] as num).toDouble(),
        date: DateTime.parse(json['date']),
      );
}
