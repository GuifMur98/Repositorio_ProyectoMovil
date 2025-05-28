import 'package:flutter/material.dart';
import 'package:proyecto/services/database_service.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/models/user.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    print('ProductDetailScreen - ID del producto: ${widget.productId}');
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    print('Verificando si el producto ${widget.productId} está en favoritos');
    final isFavorite = await DatabaseService.isProductInFavorites(
      widget.productId,
    );
    print('Resultado de verificación de favoritos: $isFavorite');
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite() async {
    try {
      print(
        'Intentando ${_isFavorite ? "remover" : "agregar"} el producto ${widget.productId} de favoritos',
      );
      if (_isFavorite) {
        await DatabaseService.removeFromFavorites(widget.productId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto removido de favoritos'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        await DatabaseService.addToFavorites(widget.productId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto agregado a favoritos'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      // Verificar el estado actual después de la operación
      final isFavorite = await DatabaseService.isProductInFavorites(
        widget.productId,
      );
      print('Estado de favoritos después de la operación: $isFavorite');
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
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
                  child: Image.network(product.imageUrl, fit: BoxFit.cover),
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
                        'Información del Vendedor',
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
                            print(
                              'No se encontró vendedor con ID: ${product.sellerId}',
                            ); // Para debugging
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
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
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
                                      _buildSellerStat('Valoración', '4.8'),
                                    ],
                                  ),
                                  if (seller.address != null &&
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
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/chat',
                                        arguments: {'sellerId': seller.id},
                                      );
                                    },
                                    icon: const Icon(Icons.message),
                                    label: const Text('Contactar al vendedor'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5C3D2E),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(
                                        double.infinity,
                                        45,
                                      ),
                                    ),
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
