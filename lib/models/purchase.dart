import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Purchase.fromJson(Map<String, dynamic> json, {String? id}) =>
      Purchase(
        id: id ?? json['id'] ?? '',
        userId: json['userId'] ?? '',
        products: (json['products'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [],
        total: (json['total'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] is DateTime
            ? json['date']
            : json['date'] is Timestamp
                ? (json['date'] as Timestamp).toDate()
                : DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      );

  factory Purchase.fromFirestore(Map<String, dynamic> json, String id) {
    return Purchase.fromJson(json, id: id);
  }

  Map<String, dynamic> toFirestore() => toJson();
}
