import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../services/user_service.dart';
import '../services/product_service.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _currentIndex = 0;
  bool _isLoadingProducts = false;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _allProducts = [];

  final List<Map<String, dynamic>> _categories = [
    {
      'id': '1',
      'name': 'Electrónica',
      'icon': Icons.devices,
      'color': const Color(0xFF5C3D2E),
    },
    {
      'id': '2',
      'name': 'Ropa',
      'icon': Icons.checkroom,
      'color': const Color(0xFF5C3D2E),
    },
    {
      'id': '3',
      'name': 'Hogar',
      'icon': Icons.home,
      'color': const Color(0xFF5C3D2E),
    },
    {
      'id': '4',
      'name': 'Deportes',
      'icon': Icons.sports_basketball,
      'color': const Color(0xFF5C3D2E),
    },
    {
      'id': '5',
      'name': 'Libros',
      'icon': Icons.book,
      'color': const Color(0xFF5C3D2E),
    },
    {
      'id': '6',
      'name': 'Mascotas',
      'icon': Icons.pets,
      'color': const Color(0xFF5C3D2E),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Llamar al método para obtener productos
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Método para cargar productos desde MongoDB
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      // Obtener los productos reales de la BD
      final fetchedProducts = await ProductService.getProducts();

      final productsList = fetchedProducts.map((product) {
        return {
          'id': product.id,
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'image': product.imageUrls.isNotEmpty
              ? product.imageUrls.first
              : 'assets/images/Logo_PMiniatura.png',
          'category': product.category,
          'imageUrls': product.imageUrls,
          'sellerId': product.sellerId,
          'stock': product.stock,
        };
      }).toList();

      setState(() {
        _allProducts = productsList;
        _products = productsList;
        _isLoadingProducts = false;
      });
    } catch (e) {
      print('Error al cargar productos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar los productos. Inténtalo de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _products = List<Map<String, dynamic>>.from(_allProducts);
      } else {
        _products = _allProducts.where((product) {
          final titleLower = product['title'].toString().toLowerCase();
          final descriptionLower =
              product['description'].toString().toLowerCase();
          final categoryLower = product['category'].toString().toLowerCase();
          final searchLower = query.toLowerCase();

          return titleLower.contains(searchLower) ||
              descriptionLower.contains(searchLower) ||
              categoryLower.contains(searchLower);
        }).toList();
      }
    });
  }

  void _onNavigationTap(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0: // Inicio
        // Ya estamos en inicio
        break;
      case 1: // Favoritos
        Navigator.pushReplacementNamed(context, '/favorites');
        break;
      case 2: // Publicar
        Navigator.pushReplacementNamed(context, '/create-product');
        break;
      case 3: // Carrito
        Navigator.pushReplacementNamed(context, '/cart');
        break;
      case 4: // Perfil
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  Widget _buildProductsGrid() {
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron productos',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otra búsqueda',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }
    final showSeeMore = _products.length > 10;
    final productsToShow = _products.take(10).toList();
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.60,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 20.0,
          ),
          itemCount: productsToShow.length,
          itemBuilder: (context, index) {
            final p = productsToShow[index];
            final product = Product(
              id: p['id'] ?? '',
              title: p['title'] ?? '',
              description: p['description'] ?? '',
              price: p['price'] is double
                  ? p['price']
                  : double.tryParse(p['price'].toString()) ?? 0.0,
              imageUrls: p['imageUrls'] != null
                  ? List<String>.from(p['imageUrls'])
                  : (p['image'] != null ? [p['image']] : []),
              category: p['category'] ?? '',
              sellerId: p['sellerId'] ?? '',
              stock: p['stock'] is int
                  ? p['stock']
                  : int.tryParse(p['stock']?.toString() ?? '') ?? 0,
            );
            return ProductCard(product: product);
          },
        ),
        if (showSeeMore)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/all-products');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Ver más productos'),
            ),
          ),
      ],
    );
  }

  Widget _buildCategories() {
    final List<Color> grad = [
      Color(0xFF3E2723),
      Color(0xFF5C3D2E)
    ]; // degradado café oscuro
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categorías',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C3D2E),
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/categories');
                  },
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(
                      color: Color(0xFF5C3D2E),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/category',
                      arguments: {'category': cat['name']},
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeInOut,
                    width: 90,
                    height: 110,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        colors: grad,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            color: grad[0],
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            cat['name'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                  offset: Offset(0, 1),
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
          ),
        ],
      ),
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
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Image.asset('assets/images/Logo_PMiniatura.png', height: 35),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterProducts,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5C3D2E),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF5C3D2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.search,
                          color: Color(0xFF5C3D2E),
                          size: 22,
                        ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Color(0xFF5C3D2E),
                                  size: 22,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterProducts('');
                                },
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF5C3D2E),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      UserService.currentUser != null
                          ? '¡Bienvenido ${UserService.currentUser!.name}!'
                          : '¡Bienvenido!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Un lugar para comprar y vender productos de calidad.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCategories(),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Productos Destacados',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C3D2E),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildProductsGrid(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
    );
  }
}
