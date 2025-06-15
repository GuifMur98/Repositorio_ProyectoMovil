import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:proyecto/services/notification_service.dart';
import '../models/product.dart';
import '../widgets/custom_image_spinner.dart';
import 'dart:convert';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  bool _isFavorite = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    // Obtiene el producto desde Firestore usando el id
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _product = Product.fromJson(data, id: doc.id);
          _isLoading = false;
        });
        await _loadFavoriteStatus();
      } else {
        setState(() {
          _product = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _product = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_product == null) return;
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      // Si el documento no existe, créalo con los campos mínimos
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        await userRef.set({
          'favoriteProducts': [],
          'name': user.displayName ?? '',
          'email': user.email ?? '',
        });
      }
      final data = (await userRef.get()).data() ?? {};
      List favs = List<String>.from(data['favoriteProducts'] ?? []);
      setState(() {
        _isFavorite = !_isFavorite;
      });
      if (_isFavorite) {
        if (!favs.contains(_product!.id)) favs.add(_product!.id);
        // Notificar al vendedor si no es el mismo usuario
        if (_product!.sellerId != user.uid) {
          await NotificationService.createNotificationForUser(
            userId: _product!.sellerId,
            title: '¡Tu producto ha sido agregado a favoritos!',
            body: 'El producto "${_product!.title}" fue marcado como favorito.',
          );
        }
      } else {
        favs.remove(_product!.id);
      }
      await userRef.update({'favoriteProducts': favs});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite
              ? 'Producto agregado a favoritos'
              : 'Producto removido de favoritos'),
          backgroundColor: const Color(0xFF5C3D2E),
        ),
      );
    } catch (e) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar favoritos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null || _product == null) return;
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userRef.get();
    final data = userDoc.data() ?? {};
    List favs = List<String>.from(data['favoriteProducts'] ?? []);
    setState(() {
      _isFavorite = favs.contains(_product!.id);
    });
  }

  Future<void> _addToCart() async {
    if (_product == null) return;
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes iniciar sesión para agregar al carrito.')),
      );
      return;
    }
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');
    try {
      final cartItemQuery = await cartRef
          .where('productId', isEqualTo: _product!.id)
          .limit(1)
          .get();
      if (cartItemQuery.docs.isNotEmpty) {
        // Ya existe, incrementar cantidad
        final doc = cartItemQuery.docs.first;
        final currentQty = (doc['quantity'] ?? 1) as int;
        await cartRef.doc(doc.id).update({'quantity': currentQty + 1});
      } else {
        // Nuevo item
        await cartRef.add({
          'userId': user.uid,
          'productId': _product!.id,
          'quantity': 1,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado al carrito.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar al carrito: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CustomImageSpinner(size: 40),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Detalles del Producto',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF5C3D2E),
          elevation: 0,
          shape: const Border(
            bottom: BorderSide(color: Colors.transparent, width: 0),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Producto no encontrado'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detalles del Producto',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.transparent, width: 0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de imágenes
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFFE1D4C2)),
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: _product!.imageUrls.isEmpty
                        ? 1
                        : _product!.imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      if (_product!.imageUrls.isEmpty) {
                        return Image.asset(
                          'assets/images/Logo_PMiniatura.png',
                          fit: BoxFit.cover,
                        );
                      }
                      final img = _product!.imageUrls[index];
                      bool isBase64Image(String s) {
                        return (s.startsWith('/9j') || s.startsWith('iVBOR')) &&
                            s.length > 100;
                      }

                      if (isBase64Image(img)) {
                        try {
                          final bytes = base64Decode(img);
                          if (bytes.lengthInBytes > 5 * 1024 * 1024) {
                            throw Exception('Imagen demasiado grande');
                          }
                          return Image.memory(
                            bytes,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
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
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
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
                  ),
                  if (_product!.imageUrls.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _product!.imageUrls.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? const Color(0xFF5C3D2E)
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _product!.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$${_product!.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3D2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.category,
                          color: Color(0xFF5C3D2E), size: 20),
                      const SizedBox(width: 4),
                      Text(
                        _product!.category,
                        style: const TextStyle(
                          color: Color(0xFF5C3D2E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.inventory_2,
                          color: Color(0xFF5C3D2E), size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Stock: ${_product!.stock}',
                        style: const TextStyle(
                          color: Color(0xFF5C3D2E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3D2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product!.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C3D2E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Añadir al Carrito',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
                      final isSeller =
                          fbUser != null && _product!.sellerId == fbUser.uid;
                      if (isSeller) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: const Text(
                            'Eres el vendedor de este producto.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            if (_product != null &&
                                _product!.sellerId.isNotEmpty) {
                              Navigator.pushNamed(
                                context,
                                '/chat',
                                arguments: {'sellerId': _product!.sellerId},
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'No se puede contactar al vendedor.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF5C3D2E),
                            side: const BorderSide(color: Color(0xFF5C3D2E)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Contactar al Vendedor',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
