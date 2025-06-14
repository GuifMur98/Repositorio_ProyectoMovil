import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/widgets/base_screen.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/widgets/product_card.dart';
import '../widgets/custom_image_spinner.dart';

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
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final favIds =
          List<String>.from(userDoc.data()?['favoriteProducts'] ?? []);
      if (favIds.isEmpty) {
        setState(() {
          _favoriteProducts = [];
          _isLoading = false;
        });
        return;
      }
      final productsSnap = await FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: favIds)
          .get();
      final products = productsSnap.docs
          .map((doc) => Product.fromJson(doc.data(), id: doc.id))
          .toList();
      setState(() {
        _favoriteProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _favoriteProducts = [];
        _isLoading = false;
        _errorMessage = 'Error al cargar favoritos: $e';
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
          ? const Center(child: CustomImageSpinner(size: 40))
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
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.maxWidth < 600 ? 2 : 3;
                        final childAspectRatio = constraints.maxWidth < 400
                            ? 0.60
                            : constraints.maxWidth < 600
                                ? 0.65
                                : 0.75;
                        final double maxGridWidth = 900;
                        final double horizontalPadding =
                            constraints.maxWidth > maxGridWidth
                                ? (constraints.maxWidth - maxGridWidth) / 2
                                : 8.0;
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 20.0,
                            ),
                            itemCount: _favoriteProducts.length,
                            itemBuilder: (context, index) {
                              final product = _favoriteProducts[index];
                              return ProductCard(
                                product: product,
                                onFavoriteToggle: _fetchFavoriteProducts,
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
