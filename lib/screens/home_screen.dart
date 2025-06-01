import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _currentIndex = 0;
  String _userName = '';
  List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'title': 'Producto de Ejemplo 1',
      'description':
          'Descripción detallada del producto 1. Este es un producto de ejemplo con una descripción extensa.',
      'price': 99.99,
      'image': 'assets/images/Logo_PMiniatura.png',
      'category': 'Categoría de Ejemplo',
    },
    {
      'id': '2',
      'title': 'Producto de Ejemplo 2',
      'description':
          'Descripción detallada del producto 2. Este es un producto de ejemplo con una descripción extensa.',
      'price': 149.99,
      'image': 'assets/images/Logo_PMiniatura.png',
      'category': 'Categoría de Ejemplo',
    },
    {
      'id': '3',
      'title': 'Producto de Ejemplo 3',
      'description':
          'Descripción detallada del producto 3. Este es un producto de ejemplo con una descripción extensa.',
      'price': 199.99,
      'image': 'assets/images/Logo_PMiniatura.png',
      'category': 'Categoría de Ejemplo',
    },
    {
      'id': '4',
      'title': 'Producto de Ejemplo 4',
      'description':
          'Descripción detallada del producto 4. Este es un producto de ejemplo con una descripción extensa.',
      'price': 249.99,
      'image': 'assets/images/Logo_PMiniatura.png',
      'category': 'Categoría de Ejemplo',
    },
  ];

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _products = _products;
      } else {
        _products = _products.where((product) {
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
        Navigator.pushNamed(context, '/favorites');
        break;
      case 2: // Publicar
        Navigator.pushNamed(context, '/create-product');
        break;
      case 3: // Carrito
        Navigator.pushNamed(context, '/cart');
        break;
      case 4: // Perfil
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Widget _buildProductsGrid() {
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.80,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    bool isFavorite = false; // TODO: Implementar lógica de favoritos

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: {'productId': product['id']},
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
                  child: Image.asset(
                    product['image'] as String,
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
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color:
                            isFavorite ? Colors.red : const Color(0xFF5C3D2E),
                        size: 20,
                      ),
                      onPressed: () {
                        // TODO: Implementar lógica de favoritos
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite
                                  ? 'Producto removido de favoritos'
                                  : 'Producto agregado a favoritos',
                            ),
                            backgroundColor: const Color(0xFF5C3D2E),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1810),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${(product['price'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2C1810),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
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
                            product['category'] as String,
                            style: const TextStyle(
                              color: Color(0xFF2C1810),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C3D2E),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildCategoryCard(
                  context,
                  icon: Icons.phone_android,
                  title: 'Electrónica',
                  subtitle: 'Gadgets y más',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5C3D2E), Color(0xFF8B5A2B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/category',
                    arguments: {'category': 'Electrónica'},
                  ),
                ),
                _buildCategoryCard(
                  context,
                  icon: Icons.checkroom,
                  title: 'Ropa',
                  subtitle: 'Moda y estilo',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5A2B), Color(0xFFA67B5B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/category',
                    arguments: {'category': 'Ropa'},
                  ),
                ),
                _buildCategoryCard(
                  context,
                  icon: Icons.home,
                  title: 'Hogar',
                  subtitle: 'Decoración y más',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA67B5B), Color(0xFFC4A484)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/category',
                    arguments: {'category': 'Hogar'},
                  ),
                ),
                _buildCategoryCard(
                  context,
                  icon: Icons.sports_basketball,
                  title: 'Deportes',
                  subtitle: 'Equipamiento',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC4A484), Color(0xFFD4B996)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/category',
                    arguments: {'category': 'Deportes'},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  icon,
                  size: 100,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
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
