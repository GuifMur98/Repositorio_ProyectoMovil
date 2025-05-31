import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Datos de ejemplo para productos
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'title': 'Camiseta Básica',
      'description': 'Camiseta de algodón 100%',
      'price': 19.99,
      'image': 'assets/images/placeholder.png',
      'category': 'Ropa',
    },
    {
      'id': '2',
      'title': 'Pantalón Vaquero',
      'description': 'Pantalón vaquero clásico',
      'price': 39.99,
      'image': 'assets/images/placeholder.png',
      'category': 'Ropa',
    },
    {
      'id': '3',
      'title': 'Zapatillas Deportivas',
      'description': 'Zapatillas para running',
      'price': 79.99,
      'image': 'assets/images/placeholder.png',
      'category': 'Ropa',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final category = args is Map && args['category'] != null
        ? args['category'] as String
        : widget.category;

    // Filtrar productos por categoría
    final filteredProducts = _products
        .where((p) => p['category'] == category)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: filteredProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 80,
                    color: Color(0xFF5C3D2E),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay productos en la categoría $category',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF5C3D2E),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Sé el primero en publicar un producto en esta categoría!',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/product-detail',
                      arguments: {'productId': product['id']},
                    );
                  },
                  child: Card(
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE1D4C2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              child: Image.asset(
                                product['image'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${product['price'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF5C3D2E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
