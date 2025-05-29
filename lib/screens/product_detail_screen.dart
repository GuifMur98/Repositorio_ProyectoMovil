import 'package:flutter/material.dart';
import 'package:proyecto/services/database_service.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final bool isFromProfile;
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.isFromProfile = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    print('ProductDetailScreen - ID del producto: ${widget.productId}');
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserEmail = prefs.getString('user_email');
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

      setState(() {
        _currentUserId = currentUser.id;
      });

      await _checkFavoriteStatus();
    } catch (e) {
      print('Error al inicializar datos: $e');
      setState(() {
        _isFavorite = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (_currentUserId == null) return;

    try {
      final favorite = await DatabaseService.isProductInFavorites(
        widget.productId,
        _currentUserId!,
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
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para añadir a favoritos'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      if (_isFavorite) {
        await DatabaseService.removeFromFavorites(
          widget.productId,
          _currentUserId!,
        );
      } else {
        await DatabaseService.addToFavorites(widget.productId, _currentUserId!);
      }
      await _checkFavoriteStatus();
    } catch (e) {
      print('Error al actualizar favoritos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar favoritos'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _addToCart() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para añadir al carrito'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      await DatabaseService.addToCart(widget.productId, _currentUserId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto añadido al carrito'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error al añadir al carrito: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al añadir al carrito'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final id = args is Map && args['productId'] != null
        ? args['productId'] as String
        : widget.productId;
    return FutureBuilder<Product?>(
      future: () async {
        final products = await DatabaseService.getProducts();
        try {
          return products.firstWhere((p) => p.id == id);
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
                      if (!widget.isFromProfile) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _addToCart,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Añadir al carrito'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5C3D2E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        widget.isFromProfile
                            ? 'Estadísticas del Vendedor'
                            : 'Información del Vendedor',
                        style: const TextStyle(
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
                                            if (!widget.isFromProfile) ...[
                                              Text(
                                                seller.email,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              if (seller.phone != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Teléfono: ${seller.phone}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ] else ...[
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                      _buildSellerStat(
                                        widget.isFromProfile
                                            ? 'Tiempo'
                                            : 'Valoración',
                                        widget.isFromProfile ? '2 años' : '4.8',
                                      ),
                                    ],
                                  ),
                                  if (!widget.isFromProfile &&
                                      seller.address != null &&
                                      seller.address!.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.grey,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            seller.address!,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  FutureBuilder<String?>(
                                    future: SharedPreferences.getInstance()
                                        .then(
                                          (prefs) =>
                                              prefs.getString('user_email'),
                                        ),
                                    builder: (context, snapshot) {
                                      print(
                                        'Email del usuario actual: ${snapshot.data}',
                                      );
                                      if (!snapshot.hasData) {
                                        print('No hay email de usuario');
                                        return const SizedBox.shrink();
                                      }

                                      return FutureBuilder<User?>(
                                        future: DatabaseService.getUserByEmail(
                                          snapshot.data!,
                                        ),
                                        builder: (context, userSnapshot) {
                                          print(
                                            'Usuario actual: ${userSnapshot.data?.id}',
                                          );
                                          print(
                                            'ID del vendedor: ${seller.id}',
                                          );

                                          if (!userSnapshot.hasData) {
                                            print('No se encontró el usuario');
                                            return const SizedBox.shrink();
                                          }

                                          final currentUser =
                                              userSnapshot.data!;
                                          if (currentUser.id != seller.id) {
                                            print(
                                              'Mostrando botón de chat - Usuario no es vendedor',
                                            );
                                            return Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/chat',
                                                    arguments: {
                                                      'sellerId': seller.id,
                                                    },
                                                  );
                                                },
                                                icon: const Icon(Icons.chat),
                                                label: const Text(
                                                  'Contactar al vendedor',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF5C3D2E,
                                                  ),
                                                  foregroundColor: Colors.white,
                                                  minimumSize: const Size(
                                                    double.infinity,
                                                    50,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          print(
                                            'No se muestra el botón - Usuario es el vendedor',
                                          );
                                          return const SizedBox.shrink();
                                        },
                                      );
                                    },
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
