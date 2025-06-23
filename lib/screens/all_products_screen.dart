import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/custom_image_spinner.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({Key? key}) : super(key: key);

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'Todas';
  String _sortBy = 'Nombre';
  final List<String> _categories = [
    'Todas',
    'Electrónica',
    'Ropa',
    'Hogar',
    'Deportes',
    'Libros',
    'Mascotas',
  ];
  final List<String> _sortOptions = ['Nombre', 'Precio'];
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final query = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();
      final fetched = query.docs
          .map((doc) => Product(
                id: doc.id,
                title: doc['title'] ?? '',
                description: doc['description'] ?? '',
                price: (doc['price'] is int)
                    ? (doc['price'] as int).toDouble()
                    : (doc['price'] ?? 0.0).toDouble(),
                imageUrls: List<String>.from(doc['imageUrls'] ?? []),
                category: doc['category'] ?? '',
                sellerId: doc['sellerId'] ?? '',
                stock: doc['stock'] ?? 0,
              ))
          .toList();
      setState(() {
        _products = fetched;
        _filteredProducts = fetched;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _products = [];
        _filteredProducts = [];
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    List<Product> filtered = List.from(_products);
    if (_selectedCategory != 'Todas') {
      filtered =
          filtered.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.title.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query))
          .toList();
    }
    if (_sortBy == 'Precio') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else {
      filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    setState(() {
      _filteredProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todos los productos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5C3D2E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.transparent, width: 0),
        ),
      ),
      body: _isLoading
          ? const Center(child: CustomImageSpinner(size: 40))
          : GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding:
                        const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7CCC8),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withAlpha((0.10 * 255).toInt()),
                                    spreadRadius: 0,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                focusNode: _searchFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'Buscar por nombre...',
                                  labelStyle:
                                      const TextStyle(color: Color(0xFF5C3D2E)),
                                  floatingLabelStyle:
                                      const TextStyle(color: Color(0xFF5C3D2E)),
                                  prefixIcon: const Icon(Icons.search,
                                      color: Color(0xFF5C3D2E)),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F0E8),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF5C3D2E), width: 2),
                                  ),
                                  hintText:
                                      null, // El hint desaparece completamente
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                                style:
                                    const TextStyle(color: Color(0xFF5C3D2E)),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                  _filterProducts();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 245, 239, 232),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DropdownButton<String>(
                                value: _selectedCategory,
                                dropdownColor: const Color(0xFFF5F0E8),
                                borderRadius: BorderRadius.circular(12),
                                items: _categories
                                    .map((cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat,
                                              style: const TextStyle(
                                                  color: Color(0xFF5C3D2E))),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCategory = val!;
                                  });
                                  _filterProducts();
                                },
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Color(0xFF5C3D2E)),
                              ),
                              const SizedBox(width: 24),
                              DropdownButton<String>(
                                value: _sortBy,
                                dropdownColor: const Color(0xFFF5F0E8),
                                borderRadius: BorderRadius.circular(12),
                                items: _sortOptions
                                    .map((opt) => DropdownMenuItem(
                                          value: opt,
                                          child: Text('Ordenar por $opt',
                                              style: const TextStyle(
                                                  color: Color(0xFF5C3D2E))),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _sortBy = val!;
                                  });
                                  _filterProducts();
                                },
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Color(0xFF5C3D2E)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _filteredProducts.isEmpty
                        ? const Center(child: Text('No hay productos'))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount =
                                  constraints.maxWidth < 600 ? 2 : 3;
                              final childAspectRatio =
                                  constraints.maxWidth < 400
                                      ? 0.60
                                      : constraints.maxWidth < 600
                                          ? 0.65
                                          : 0.75;
                              return GridView.builder(
                                padding: const EdgeInsets.all(12),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: childAspectRatio,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 20.0,
                                ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) {
                                  return ProductCard(
                                      product: _filteredProducts[index]);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
