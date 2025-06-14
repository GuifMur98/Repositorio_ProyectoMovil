import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/user_product_detail_screen.dart';
import '../models/product.dart';
import '../widgets/custom_image_spinner.dart';
import 'dart:convert';

class UserProductsScreen extends StatefulWidget {
  const UserProductsScreen({super.key});

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProducts();
  }

  Future<void> _fetchUserProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      final query = await FirebaseFirestore.instance
          .collection('products')
          .where('sellerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();
      final userProducts = query.docs
          .map((doc) => Product.fromJson(doc.data(), id: doc.id))
          .toList();
      setState(() {
        _products = userProducts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _products = [];
        _isLoading = false;
        _errorMessage = 'Error al cargar productos: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Productos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CustomImageSpinner(size: 40))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _products.isEmpty
                  ? const Center(child: Text('No has publicado productos.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProductDetailScreen(
                                      productId: product.id),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE1D4C2),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                    child: Builder(
                                      builder: (context) {
                                        if (product.imageUrls.isNotEmpty) {
                                          final img = product.imageUrls.first;
                                          bool isBase64Image(String s) {
                                            return (s.startsWith('/9j') ||
                                                    s.startsWith('iVBOR')) &&
                                                s.length > 100;
                                          }

                                          if (isBase64Image(img)) {
                                            try {
                                              final bytes = base64Decode(img);
                                              if (bytes.lengthInBytes >
                                                  5 * 1024 * 1024) {
                                                throw Exception(
                                                    'Imagen demasiado grande');
                                              }
                                              return Image.memory(
                                                bytes,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    width: 120,
                                                    height: 120,
                                                    color:
                                                        const Color(0xFFE1D4C2),
                                                    child: const Icon(
                                                      Icons
                                                          .image_not_supported_outlined,
                                                      size: 40,
                                                      color: Color(0xFF5C3D2E),
                                                    ),
                                                  );
                                                },
                                              );
                                            } catch (e) {
                                              return Container(
                                                width: 120,
                                                height: 120,
                                                color: const Color(0xFFE1D4C2),
                                                child: const Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  size: 40,
                                                  color: Color(0xFF5C3D2E),
                                                ),
                                              );
                                            }
                                          } else {
                                            return Image.network(
                                              img,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: 120,
                                                  height: 120,
                                                  color:
                                                      const Color(0xFFE1D4C2),
                                                  child: const Icon(
                                                    Icons
                                                        .image_not_supported_outlined,
                                                    size: 40,
                                                    color: Color(0xFF5C3D2E),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        } else {
                                          return Image.asset(
                                            'assets/images/Logo_PMiniatura.png',
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.title,
                                          style: const TextStyle(
                                            fontSize: 20, // Aumentado
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF5C3D2E),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$ ${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Color(0xFF5C3D2E),
                                            fontSize: 22, // Aumentado
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.category,
                                              size: 18, // Aumentado
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                product.category,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16, // Aumentado
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
