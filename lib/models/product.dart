class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String sellerId;
  final String address;

  // Para la base de datos local, id puede ser int (autoincremental)
  int? dbId;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.sellerId,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': dbId,
      'name': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'address': address,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      title: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      address: map['address'] ?? '',
      sellerId: '',
    )..dbId = map['id'];
  }
}
