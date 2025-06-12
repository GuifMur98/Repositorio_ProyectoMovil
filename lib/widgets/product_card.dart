import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/services/notification_service.dart';
import 'dart:convert';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({Key? key, required this.product, this.onFavoriteToggle})
      : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;
  bool loadingFavorite = false;
  bool loadingCart = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userRef.get();
    final data = userDoc.data() ?? {};
    List favs = List<String>.from(data['favoriteProducts'] ?? []);
    if (!mounted) return;
    setState(() {
      isFavorite = favs.contains(widget.product.id);
    });
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    if (!mounted) return;
    setState(() {
      loadingFavorite = true;
      isFavorite = !isFavorite;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      final userDoc = await userRef.get();
      final data = userDoc.data() ?? {};
      List favs = List<String>.from(data['favoriteProducts'] ?? []);
      if (isFavorite) {
        if (!favs.contains(widget.product.id)) favs.add(widget.product.id);
        // Notificar al vendedor si no es el mismo usuario
        if (widget.product.sellerId != user.uid) {
          await NotificationService.createNotificationForUser(
            userId: widget.product.sellerId,
            title: '¡Tu producto ha sido agregado a favoritos!',
            body:
                'El producto "${widget.product.title}" fue marcado como favorito.',
          );
        }
      } else {
        favs.remove(widget.product.id);
      }
      await userRef.update({'favoriteProducts': favs});
      if (widget.onFavoriteToggle != null) widget.onFavoriteToggle!();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              isFavorite ? 'Agregado a favoritos' : 'Eliminado de favoritos')));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isFavorite = !isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al actualizar favoritos: $e'),
          backgroundColor: Colors.red));
    } finally {
      if (!mounted) return;
      setState(() {
        loadingFavorite = false;
      });
    }
  }

  Future<void> _addToCart(BuildContext context) async {
    if (!mounted) return;
    setState(() {
      loadingCart = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes iniciar sesión para agregar al carrito.')),
      );
      setState(() {
        loadingCart = false;
      });
      return;
    }
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');
    try {
      final cartItemQuery = await cartRef
          .where('productId', isEqualTo: widget.product.id)
          .limit(1)
          .get();
      if (cartItemQuery.docs.isNotEmpty) {
        final doc = cartItemQuery.docs.first;
        final currentQty = (doc['quantity'] ?? 1) as int;
        await cartRef.doc(doc.id).update({'quantity': currentQty + 1});
      } else {
        await cartRef.add({
          'userId': user.uid,
          'productId': widget.product.id,
          'quantity': 1,
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado al carrito.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar al carrito: $e')),
      );
    }
    if (!mounted) return;
    setState(() {
      loadingCart = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: {'productId': widget.product.id},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0E8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: widget.product.imageUrls.isNotEmpty
                      ? (() {
                          final img = widget.product.imageUrls.first;
                          // Validar base64: debe ser suficientemente largo y decodificable
                          bool isBase64Image(String s) {
                            // Heurística: empieza con '/9j' (JPEG) o 'iVBOR' (PNG) y es largo
                            return (s.startsWith('/9j') || s.startsWith('iVBOR')) && s.length > 100;
                          }
                          if (isBase64Image(img)) {
                            try {
                              final bytes = base64Decode(img);
                              // Validar tamaño razonable (no más de 5MB)
                              if (bytes.lengthInBytes > 5 * 1024 * 1024) {
                                throw Exception('Imagen demasiado grande');
                              }
                              return Image.memory(
                                bytes,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 120,
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
                              // Si falla la decodificación, mostrar placeholder
                              return Container(
                                height: 120,
                                width: double.infinity,
                                color: const Color(0xFFE1D4C2),
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                  color: Color(0xFF5C3D2E),
                                ),
                              );
                            }
                          }
                          // Si no es base64, intentar como URL
                          return Image.network(
                            img,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
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
                        })()
                      : Image.asset(
                          'assets/images/Logo_PMiniatura.png',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: loadingFavorite
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : const Color(0xFF5C3D2E),
                              size: 20,
                            ),
                            onPressed: () => _toggleFavorite(context),
                          ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontSize: 16, // antes 13
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1810),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17, // antes 14
                      color: Color(0xFF2C1810),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1D4C2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.category,
                                size: 12,
                                color: Color(0xFF2C1810),
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  widget.product.category,
                                  style: const TextStyle(
                                    color: Color(0xFF2C1810),
                                    fontSize: 13, // antes 10
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  loadingCart
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_shopping_cart,
                                size: 20), // antes 18
                            label: const Text('Añadir al carrito',
                                style: TextStyle(fontSize: 15)), // antes 13
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF5C3D2E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 0,
                            ),
                            onPressed: () => _addToCart(context),
                          ),
                        ),
                  const SizedBox(
                      height: 8), // Espaciado reducido al final de la columna
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
