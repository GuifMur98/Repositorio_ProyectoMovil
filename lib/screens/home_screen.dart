import 'package:flutter/material.dart';
import 'package:proyecto/services/database_service.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  List<String> _favoriteProductIds = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');

      // Cargar productos primero, independientemente del estado de autenticación
      await _loadProducts();

      if (userEmail != null) {
        final user = await DatabaseService.getUserByEmail(userEmail);
        if (user != null) {
          setState(() {
            _currentUserId = user.id;
          });
          await _loadFavorites();
        }
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      print('Error al inicializar datos: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await DatabaseService.getProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      print('Error al cargar productos: $e');
      setState(() {
        _products = [];
      });
    }
  }

  Future<void> _loadFavorites() async {
    if (_currentUserId == null) return;

    try {
      final favoriteIds = await DatabaseService.getFavoriteProductIds(
        _currentUserId!,
      );
      setState(() {
        _favoriteProductIds = favoriteIds;
      });
    } catch (e) {
      print('Error al cargar favoritos: $e');
      setState(() {
        _favoriteProductIds = [];
      });
    }
  }

  Future<void> _toggleFavorite(String productId) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para marcar favoritos'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final isCurrentlyFavorite = _favoriteProductIds.contains(productId);

      if (isCurrentlyFavorite) {
        await DatabaseService.removeFromFavorites(productId, _currentUserId!);
        setState(() {
          _favoriteProductIds.remove(productId);
        });
      } else {
        await DatabaseService.addToFavorites(productId, _currentUserId!);
        setState(() {
          _favoriteProductIds.add(productId);
        });
      }
    } catch (e) {
      print('Error al actualizar favoritos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar favoritos'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addToCart(String productId) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para añadir al carrito'),
        ),
      );
      return;
    }

    try {
      await DatabaseService.addToCart(productId, _currentUserId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto añadido al carrito')),
      );
    } catch (e) {
      print('Error al añadir al carrito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al añadir al carrito')),
      );
    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _products = _products;
      } else {
        _products = _products.where((product) {
          final titleLower = product.title.toLowerCase();
          final descriptionLower = product.description.toLowerCase();
          final categoryLower = product.category.toLowerCase();
          final searchLower = query.toLowerCase();

          return titleLower.contains(searchLower) ||
              descriptionLower.contains(searchLower) ||
              categoryLower.contains(searchLower);
        }).toList();
      }
    });
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        final isFavorite =
            _currentUserId != null && _favoriteProductIds.contains(product.id);

        return _buildProductCard(
          context,
          product,
          isFavorite,
          () => _toggleFavorite(product.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xFF5C3D2E),
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterProducts,
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF5C3D2E),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFF5C3D2E),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterProducts('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
            ],
          ),
        ),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.store_outlined,
                    size: 80,
                    color: Color(0xFF5C3D2E),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay productos destacados',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF5C3D2E),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Sé el primero en publicar un producto!',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-product');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Publicar Producto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C3D2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_searchController.text.isEmpty) ...[
                      const Text(
                        'Categorías',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3D2E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildCategoryCard(
                              context,
                              'Ropa',
                              Icons.checkroom,
                            ),
                            _buildCategoryCard(
                              context,
                              'Tecnología',
                              Icons.devices,
                            ),
                            _buildCategoryCard(context, 'Hogar', Icons.home),
                            _buildCategoryCard(
                              context,
                              'Deportes',
                              Icons.sports_soccer,
                            ),
                            _buildCategoryCard(context, 'Libros', Icons.book),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Productos Destacados',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3D2E),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else if (_products.isEmpty) ...[
                      const SizedBox(height: 32),
                      const Icon(
                        Icons.search_off,
                        size: 80,
                        color: Color(0xFF5C3D2E),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No se encontraron productos',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF5C3D2E),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Intenta con otra búsqueda',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (_products.isNotEmpty) _buildProductsGrid(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF5C3D2E),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              // Ya estamos en Home
              break;
            case 1:
              Navigator.pushNamed(context, '/favorites');
              break;
            case 2:
              Navigator.pushNamed(context, '/create-product');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Publicar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5C3D2E),
        onPressed: () {
          Navigator.pushNamed(context, '/cart');
        },
        child: const Icon(Icons.shopping_cart, color: Colors.white),
        tooltip: 'Carrito de compra',
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String category,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        print('Navegando a la categoría: $category');
        Navigator.pushNamed(
          context,
          '/category',
          arguments: {'category': category},
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE1D4C2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF5C3D2E)),
            const SizedBox(height: 8),
            Text(
              category,
              style: const TextStyle(
                color: Color(0xFF5C3D2E),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
    bool isFavorite,
    Function() onFavoriteToggle,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: {'productId': product.id},
        );
      },
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1D4C2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      child: product.getImageWidget(),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: onFavoriteToggle,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF5C3D2E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _addToCart(product.id),
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Añadir al carrito'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C3D2E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
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
