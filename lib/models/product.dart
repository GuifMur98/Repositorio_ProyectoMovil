class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls; // Lista de URLs de imágenes
  final String category;
  final String sellerId; // ID del vendedor
  final int stock; // Cantidad disponible

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

  // Método para crear un Product desde un mapa (por ejemplo, de MongoDB)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'].toString(), // Asumiendo que el ID se llama _id en MongoDB
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as double,
      imageUrls: List<String>.from(
          json['imageUrls'] ?? []), // Manejar null o lista vacía
      category: json['category'] as String,
      sellerId: json['sellerId']
          as String, // Asumiendo que el ID del vendedor se llama sellerId
      stock: json['stock'] as int, // Asumiendo que el stock se llama stock
    );
  }

  // Método para convertir un Product a un mapa (por ejemplo, para enviar a MongoDB)
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Si necesitas incluir el ID al actualizar/eliminar
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'category': category,
      'sellerId': sellerId,
      'stock': stock,
    };
  }

  // Método para convertir un Product a un mapa sin el ID (por ejemplo, para insertar)
  Map<String, dynamic> toNewDocumentJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'category': category,
      'sellerId': sellerId,
      'stock': stock,
    };
  }
}
