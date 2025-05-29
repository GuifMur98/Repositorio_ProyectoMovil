import 'package:flutter/material.dart';
import 'package:proyecto/services/database_service.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProductDetailScreen extends StatefulWidget {
  final String productId;
  const UserProductDetailScreen({super.key, required this.productId});

  @override
  State<UserProductDetailScreen> createState() =>
      _UserProductDetailScreenState();
}

class _UserProductDetailScreenState extends State<UserProductDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserEmail = prefs.getString('userEmail');
      if (currentUserEmail == null) {
        setState(() {
          _isFavorite = false;
        });
        return;
      }

      final currentUser = await DatabaseService.getUserByEmail(
        currentUserEmail,
      );
      if (currentUser == null) {
        setState(() {
          _isFavorite = false;
        });
        return;
      }

      final favorite = await DatabaseService.isProductInFavorites(
        widget.productId,
        currentUser.id,
      );
      setState(() {
        _isFavorite = favorite;
      });
    } catch (e) {
      print('Error al verificar estado de favorito: $e');
      setState(() {
        _isFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserEmail = prefs.getString('userEmail');
      if (currentUserEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para marcar favoritos'),
          ),
        );
        return;
      }

      final currentUser = await DatabaseService.getUserByEmail(
        currentUserEmail,
      );
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al obtener información del usuario'),
          ),
        );
        return;
      }

      if (_isFavorite) {
        await DatabaseService.removeFromFavorites(
          widget.productId,
          currentUser.id,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto removido de favoritos')),
        );
      } else {
        await DatabaseService.addToFavorites(widget.productId, currentUser.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto agregado a favoritos')),
        );
      }

      final isFavorite = await DatabaseService.isProductInFavorites(
        widget.productId,
        currentUser.id,
      );
      setState(() {
        _isFavorite = isFavorite;
      });
    } catch (e) {
      print('Error al actualizar favoritos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar favoritos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product?>(
      future: () async {
        final products = await DatabaseService.getProducts();
        try {
          return products.firstWhere((p) => p.id == widget.productId);
        } catch (_) {
          return null;
        }
      }(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final product = snapshot.data;
        if (product == null) {
          return const Scaffold(
            body: Center(child: Text('Producto no encontrado')),
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Color(0xFFE1D4C2)),
                  child: product.getImageWidget(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5C3D2E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Categoría: ${product.category}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Estadísticas del Vendedor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<User?>(
                        future: DatabaseService.getUserById(product.sellerId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final seller = snapshot.data;
                          if (seller == null) {
                            return const Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Color(0xFFE1D4C2),
                                  child: Icon(
                                    Icons.person,
                                    color: Color(0xFF5C3D2E),
                                  ),
                                ),
                                title: Text('Vendedor no disponible'),
                                subtitle: Text(
                                  'No se pudo cargar la información del vendedor',
                                ),
                              ),
                            );
                          }

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Color(0xFFE1D4C2),
                                        radius: 30,
                                        child: Icon(
                                          Icons.person,
                                          color: Color(0xFF5C3D2E),
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              seller.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  '4.8',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF5C3D2E),
                                                  ),
                                                ),
                                                const Text(
                                                  ' (120 valoraciones)',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      FutureBuilder<List<Product>>(
                                        future: DatabaseService.getProducts(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return _buildSellerStat(
                                              'Productos',
                                              '0',
                                            );
                                          }
                                          final products = snapshot.data!;
                                          final publishedCount = products
                                              .where(
                                                (p) => p.sellerId == seller.id,
                                              )
                                              .length;
                                          return _buildSellerStat(
                                            'Productos',
                                            publishedCount.toString(),
                                          );
                                        },
                                      ),
                                      FutureBuilder<List<Map<String, dynamic>>>(
                                        future:
                                            DatabaseService.getPurchasesByUser(
                                              seller.id,
                                            ),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return _buildSellerStat(
                                              'Ventas',
                                              '0',
                                            );
                                          }
                                          final purchases = snapshot.data!;
                                          return _buildSellerStat(
                                            'Ventas',
                                            purchases.length.toString(),
                                          );
                                        },
                                      ),
                                      _buildSellerStat('Tiempo', '2 años'),
                                    ],
                                  ),
                                ],
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
      },
    );
  }

  Widget _buildSellerStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C3D2E),
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
