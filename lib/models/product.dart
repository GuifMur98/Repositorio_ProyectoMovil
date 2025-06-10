class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String category;
  final String sellerId;
  final int stock;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.category,
    required this.sellerId,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json, {String? id}) {
    return Product(
      id: id ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      category: json['category'] ?? '',
      sellerId: json['sellerId'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }

  factory Product.fromFirestore(Map<String, dynamic> json, String id) {
    return Product.fromJson(json, id: id);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'imageUrls': imageUrls,
        'category': category,
        'sellerId': sellerId,
        'stock': stock,
      };

  Map<String, dynamic> toFirestore() => toJson();
}
