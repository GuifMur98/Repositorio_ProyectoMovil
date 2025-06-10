import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/bottom_navigation.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/widgets/product_card.dart';
import 'package:proyecto/services/notification_service.dart';
import '../models/notification.dart' as model;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _currentIndex = 0;
  List<Map<String, dynamic>> _allProducts = [];
  int _unreadNotifications = 0;
  late final Stream<List<model.AppNotification>> _notificationsStream;

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
    _notificationsStream = NotificationService.getUserNotificationsStream();
    _notificationsStream.listen((notifications) {
      final unread = notifications.where((n) => !n.read).length;
      if (mounted) {
        setState(() {
          _unreadNotifications = unread;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar productos'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
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
        // Filtrado por búsqueda
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final titleLower = (data['title'] ?? '').toString().toLowerCase();
          final descriptionLower =
              (data['description'] ?? '').toString().toLowerCase();
          final categoryLower =
              (data['category'] ?? '').toString().toLowerCase();
          final searchLower = _searchController.text.toLowerCase();
          return titleLower.contains(searchLower) ||
              descriptionLower.contains(searchLower) ||
              categoryLower.contains(searchLower);
        }).toList();
        final showSeeMore = filteredDocs.length > 10;
        final productsToShow = filteredDocs.take(10).toList();
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
                final doc = productsToShow[index];
                final data = doc.data() as Map<String, dynamic>;
                final product = Product(
                  id: doc.id,
                  title: data['title'] ?? '',
                  description: data['description'] ?? '',
                  price: (data['price'] is int)
                      ? (data['price'] as int).toDouble()
                      : (data['price'] ?? 0.0).toDouble(),
                  imageUrls: List<String>.from(data['imageUrls'] ?? []),
                  category: data['category'] ?? '',
                  sellerId: data['sellerId'] ?? '',
                  stock: data['stock'] ?? 0,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Ver más productos'),
                ),
              ),
          ],
        );
      },
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
    final fbUser = FirebaseAuth.instance.currentUser;
    final userName = fbUser?.displayName ?? fbUser?.email ?? '';

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
                    onChanged: (_) {
                      setState(() {});
                    }, // Actualiza el filtro en tiempo real
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
                                  setState(() {});
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
              // Icono de notificaciones con badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        color: Color.fromARGB(255, 255, 255, 255), size: 28),
                    tooltip: 'Notificaciones',
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  if (_unreadNotifications > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          _unreadNotifications > 9
                              ? '9+'
                              : '$_unreadNotifications',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección de bienvenida con fondo café, texto blanco, centrado y esquinas inferiores redondeadas
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF5C3D2E),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '¡Bienvenido${userName.isNotEmpty ? ', $userName' : ''}!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Descubre productos únicos y apoya a vendedores locales.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildCategories(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Productos destacados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3D2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildProductsGrid(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5C3D2E),
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/chats');
        },
        tooltip: 'Chats',
      ),
    );
  }
}
