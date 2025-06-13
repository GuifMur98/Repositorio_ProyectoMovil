import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'dart:convert';

class UserProductDetailScreen extends StatefulWidget {
  final String productId;
  const UserProductDetailScreen({super.key, required this.productId});

  @override
  State<UserProductDetailScreen> createState() =>
      _UserProductDetailScreenState();
}

class _UserProductDetailScreenState extends State<UserProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProductDetail();
  }

  Future<void> _fetchProductDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _product = Product(
            id: doc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            price: (data['price'] is int)
                ? (data['price'] as int).toDouble()
                : (data['price'] ?? 0.0),
            imageUrls: (data['imageUrls'] as List<dynamic>? ?? [])
                .map((e) => e.toString())
                .toList(),
            category: data['category'] ?? '',
            sellerId: data['sellerId'] ?? '',
            stock: data['stock'] ?? 0,
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _product = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el producto: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detalle del Producto',
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
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _product == null
                  ? const Center(child: Text('Producto no encontrado.'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1D4C2),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: _product!.imageUrls.isNotEmpty
                                    ? Builder(
                                        builder: (context) {
                                          final img = _product!.imageUrls.first;
                                          bool isBase64Image(String s) {
                                            return (s.startsWith('/9j') || s.startsWith('iVBOR')) && s.length > 100;
                                          }
                                          if (isBase64Image(img)) {
                                            try {
                                              final bytes = base64Decode(img);
                                              if (bytes.lengthInBytes > 5 * 1024 * 1024) {
                                                throw Exception('Imagen demasiado grande');
                                              }
                                              return Image.memory(
                                                bytes,
                                                height: 240,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    height: 240,
                                                    width: double.infinity,
                                                    color: const Color(0xFFE1D4C2),
                                                    child: const Icon(
                                                      Icons.image_not_supported_outlined,
                                                      size: 40,
                                                      color: Color(0xFF5C3D2E),
                                                    ),
                                                  );
                                                },
                                              );
                                            } catch (e) {
                                              return Container(
                                                height: 240,
                                                width: double.infinity,
                                                color: const Color(0xFFE1D4C2),
                                                child: const Icon(
                                                  Icons.image_not_supported_outlined,
                                                  size: 40,
                                                  color: Color(0xFF5C3D2E),
                                                ),
                                              );
                                            }
                                          } else {
                                            return Image.network(
                                              img,
                                              height: 240,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  height: 240,
                                                  width: double.infinity,
                                                  color: const Color(0xFFE1D4C2),
                                                  child: const Icon(
                                                    Icons.image_not_supported_outlined,
                                                    size: 40,
                                                    color: Color(0xFF5C3D2E),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                      )
                                    : Image.asset(
                                        'assets/images/Logo_PMiniatura.png',
                                        height: 240,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(_product!.title,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5C3D2E))),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.category,
                                    color: Color(0xFF5C3D2E), size: 22),
                                const SizedBox(width: 8),
                                Text('Categoría: ${_product!.category}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Descripción',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5C3D2E))),
                            const SizedBox(height: 8),
                            Text(_product!.description,
                                style:
                                    const TextStyle(fontSize: 18, height: 1.5)),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F1E7),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Precio', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                      Text(
                                        '\$ ${_product!.price.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF5C3D2E)),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Stock', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                      Text(
                                        '${_product!.stock}',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C3D2E)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
