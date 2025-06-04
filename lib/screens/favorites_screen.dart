import 'package:flutter/material.dart';
import 'package:proyecto/widgets/base_screen.dart';
import 'package:proyecto/services/user_service.dart';
import 'package:proyecto/services/product_service.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/widgets/product_card.dart'; // Asumiendo que tienes un widget para mostrar productos

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteProducts();
  }

  Future<void> _fetchFavoriteProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUser = UserService.currentUser; // Obtener el usuario actual

    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Debes iniciar sesión para ver tus favoritos.';
      });
      return;
    }

    if (currentUser.favoriteProducts.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Aún no tienes productos favoritos.';
      });
      return;
    }

    try {
      // Obtener los detalles de cada producto favorito
      List<Product> products = [];
      for (String productId in currentUser.favoriteProducts) {
        final product = await ProductService.getProductById(productId);
        if (product != null) {
          products.add(product);
        }
      }

      setState(() {
        _favoriteProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar favoritos: e.toString()}';
        print('Error fetching favorite products: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 1, // Índice para la pestaña de favoritos
      onNavigationTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            // Ya estamos en favoritos
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/create-product');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/cart');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mis Favoritos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border,
                          size: 80, color: Colors.brown),
                      SizedBox(height: 24),
                      Text(
                        'Aún no tienes productos favoritos.',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _favoriteProducts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border,
                              size: 80, color: Colors.brown),
                          SizedBox(height: 24),
                          Text(
                            'Aún no tienes productos favoritos.',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 87, 81, 79),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columnas
                        childAspectRatio:
                            0.60, // Igual que home para que el card se vea bien
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 20.0,
                      ),
                      itemCount: _favoriteProducts.length,
                      itemBuilder: (context, index) {
                        final product = _favoriteProducts[index];
                        // Asumiendo que tienes un ProductCard widget para mostrar cada producto
                        return ProductCard(
                          product: product,
                          onFavoriteToggle: _fetchFavoriteProducts,
                        );
                      },
                    ),
    );
  }
}
