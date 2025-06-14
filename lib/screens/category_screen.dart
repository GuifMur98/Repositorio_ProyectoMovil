import 'package:flutter/material.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/widgets/product_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_image_spinner.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProductsByCategory();
  }

  Future<void> _fetchProductsByCategory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final query = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: widget.category)
          .orderBy('createdAt', descending: true)
          .get();
      final products = query.docs
          .map((doc) => Product.fromJson(doc.data(), id: doc.id))
          .toList();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar productos: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF5C3D2E),
      ),
      body: _isLoading
          ? const Center(child: CustomImageSpinner(size: 40))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _products.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay productos en esta categoría.',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount;
                        double childAspectRatio;
                        double padding;

                        if (constraints.maxWidth < 400) {
                          crossAxisCount = 1;
                          childAspectRatio = 0.60;
                          padding = 4.0;
                        } else if (constraints.maxWidth < 600) {
                          crossAxisCount = 2;
                          childAspectRatio = 0.65;
                          padding = 8.0;
                        } else if (constraints.maxWidth < 900) {
                          crossAxisCount = 3;
                          childAspectRatio = 0.75;
                          padding = 16.0;
                        } else {
                          crossAxisCount = 4;
                          childAspectRatio = 0.85;
                          padding = 24.0;
                        }

                        return GridView.builder(
                          padding: EdgeInsets.all(padding),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: childAspectRatio,
                            crossAxisSpacing: padding,
                            mainAxisSpacing: padding,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ProductCard(product: product);
                          },
                        );
                      },
                    ),
    );
  }
}
