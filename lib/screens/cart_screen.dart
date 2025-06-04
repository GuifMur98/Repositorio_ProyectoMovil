import 'package:flutter/material.dart';
import 'package:proyecto/widgets/base_screen.dart';
import 'package:proyecto/services/cart_item_service.dart';
import 'package:proyecto/models/cart_item.dart';
import 'package:proyecto/services/product_service.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/services/user_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  Map<String, Product> _products = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Variables para tipos de envío y dirección seleccionada
  final List<Map<String, dynamic>> _shippingOptions = [
    {'label': 'Estándar (3-5 días)', 'cost': 120.0},
    {'label': 'Express (1-2 días)', 'cost': 220.0},
    {'label': 'Recogida en tienda', 'cost': 0.0},
  ];
  int _selectedShippingIndex = 0;
  String? _selectedAddress;
  List<String> _userAddresses = [];

  // Flag para controlar la expansión del ExpansionTile de la factura
  bool _isFacturaExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchCart();
    _fetchAddresses();
  }

  Future<void> _fetchCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final user = UserService.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Debes iniciar sesión para ver tu carrito.';
      });
      return;
    }
    try {
      final items = await CartItemService.getCartItemsByUser(user.id);
      final products = <String, Product>{};
      for (final item in items) {
        final product = await ProductService.getProductById(item.productId);
        if (product != null) {
          products[item.productId] = product;
        }
      }
      setState(() {
        _cartItems = items;
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar el carrito.';
      });
    }
  }

  Future<void> _fetchAddresses() async {
    final user = UserService.currentUser;
    if (user == null) return;
    // Usar el campo addresses del usuario actual
    final addresses = user.addresses;
    setState(() {
      _userAddresses = List<String>.from(addresses);
      if (_userAddresses.isNotEmpty && _selectedAddress == null) {
        _selectedAddress = _userAddresses.first;
      }
    });
  }

  Future<void> _removeCartItem(String id) async {
    try {
      await CartItemService.deleteCartItem(id);
      await _fetchCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado del carrito.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al eliminar: ' +
                (e.toString().isNotEmpty
                    ? e.toString()
                    : 'Error desconocido'))),
      );
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQty) async {
    if (newQty < 1) return;
    try {
      final updated = CartItem(
        id: item.id,
        userId: item.userId,
        productId: item.productId,
        quantity: newQty,
      );
      await CartItemService.updateCartItem(updated);
      await _fetchCart();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cantidad actualizada a $newQty.')),
      );
      // Log para depuración
      // ignore: avoid_print
      print(
          'Cantidad actualizada para el producto ${item.productId} a $newQty');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al actualizar cantidad: ' +
                (e.toString().isNotEmpty
                    ? e.toString()
                    : 'Error desconocido'))),
      );
      // Log para depuración
      // ignore: avoid_print
      print('Error al actualizar cantidad: $e');
    }
  }

  double get _subtotal => _cartItems.fold(0, (sum, item) {
        final product = _products[item.productId];
        if (product == null) return sum;
        return sum + product.price * item.quantity;
      });

  double get _isv => _subtotal * 0.15; // 15% ISV

  double get _shipping => _subtotal > 0
      ? _shippingOptions[_selectedShippingIndex]['cost'] as double
      : 0.0; // Ejemplo: envío fijo

  double get _total => _subtotal + _isv + _shipping;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 3,
      onNavigationTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/favorites');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/create-product');
            break;
          case 3:
            // Ya estamos en carrito
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
          'Mi Carrito',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.brown,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )
              : _cartItems.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 80, color: Colors.brown),
                          SizedBox(height: 24),
                          Text(
                            'Tu carrito está vacío.',
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
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _cartItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final item = _cartItems[i];
                              final product = _products[item.productId];
                              if (product == null) {
                                return const SizedBox();
                              }
                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 0),
                                color: const Color(0xFFF5F0E8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: product.imageUrls.isNotEmpty
                                            ? Image.network(
                                                product.imageUrls.first,
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover)
                                            : Image.asset(
                                                'assets/images/Logo_PMiniatura.png',
                                                width: 64,
                                                height: 64),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color(0xFF2C1810)),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Categoría: ${product.category}',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.brown),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Precio: ${product.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF5C3D2E),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.remove_circle_outline,
                                                    color: Colors.brown),
                                                onPressed: () =>
                                                    _updateQuantity(item,
                                                        item.quantity - 1),
                                              ),
                                              Text('${item.quantity}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16)),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.add_circle_outline,
                                                    color: Colors.brown),
                                                onPressed: () =>
                                                    _updateQuantity(item,
                                                        item.quantity + 1),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _removeCartItem(item.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              StatefulBuilder(
                                builder: (context, setSBState) {
                                  return ExpansionTile(
                                    initiallyExpanded: false,
                                    tilePadding: EdgeInsets.zero,
                                    onExpansionChanged: (expanded) {
                                      setState(() {
                                        _isFacturaExpanded = expanded;
                                      });
                                      setSBState(() {});
                                    },
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Factura',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        if (!_isFacturaExpanded)
                                          Text(
                                            _total.toStringAsFixed(2),
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                      ],
                                    ),
                                    children: [
                                      // Selector de dirección
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text('Dirección:',
                                                style: TextStyle(fontSize: 16)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _userAddresses.isEmpty
                                                  ? const Text(
                                                      'No hay direcciones',
                                                      textAlign: TextAlign.end)
                                                  : DropdownButton<String>(
                                                      value: _selectedAddress,
                                                      isExpanded: true,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _selectedAddress =
                                                              value;
                                                        });
                                                      },
                                                      items: _userAddresses
                                                          .map((address) =>
                                                              DropdownMenuItem(
                                                                value: address,
                                                                child: Text(
                                                                    address,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                              ))
                                                          .toList(),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Selector de tipo de envío
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text('Tipo de envío:',
                                                style: TextStyle(fontSize: 16)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: DropdownButton<int>(
                                                value: _selectedShippingIndex,
                                                isExpanded: true,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedShippingIndex =
                                                        value!;
                                                  });
                                                },
                                                items: List.generate(
                                                  _shippingOptions.length,
                                                  (i) => DropdownMenuItem(
                                                    value: i,
                                                    child: Text(
                                                        _shippingOptions[i]
                                                            ['label']),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Desglose de factura
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Subtotal:',
                                              style: TextStyle(fontSize: 18)),
                                          Text(_subtotal.toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontSize: 18)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('ISV (15%):',
                                              style: TextStyle(fontSize: 18)),
                                          Text(_isv.toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontSize: 18)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Envío:',
                                              style: TextStyle(fontSize: 18)),
                                          Text(_shipping.toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontSize: 18)),
                                        ],
                                      ),
                                      const Divider(height: 24, thickness: 1),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Total:',
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold)),
                                          Text(_total.toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              if (_selectedShippingIndex != 2 &&
                                  (_selectedAddress == null ||
                                      _selectedAddress!.isEmpty))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Debes seleccionar una dirección para el envío.',
                                    style: TextStyle(
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ElevatedButton(
                                onPressed: (_selectedShippingIndex == 2 ||
                                        (_selectedAddress != null &&
                                            _selectedAddress!.isNotEmpty))
                                    ? () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content:
                                                    Text('Compra simulada.')));
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5C3D2E),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text('Finalizar compra',
                                    style: TextStyle(fontSize: 16)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
