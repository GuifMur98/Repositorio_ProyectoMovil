import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:proyecto/widgets/base_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import '../services/notification_service.dart';
import '../widgets/custom_image_spinner.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Eliminar simulación, inicializar como vacío
  List<CartItem> _cartItems = [];
  Map<String, Product> _products = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Variables para tipos de envío y dirección seleccionada
  final List<Map<String, dynamic>> _shippingOptions = [
    {'label': 'Estándar (3-5 días)', 'cost': 120.0},
    {'label': 'Express (1-2 días)', 'cost': 220.0},
    {'label': 'Recogida en tienda', 'cost': 0.0},
  ];
  int _selectedShippingIndex = 0;
  Address? _selectedAddressObj;
  List<Address> _addressObjects = [];

  bool _isFacturaExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      final addresses = await AddressService.getAddresses();
      setState(() {
        _addressObjects = addresses;
        if (_addressObjects.isNotEmpty && _selectedAddressObj == null) {
          _selectedAddressObj = _addressObjects.first;
        }
      });
    } catch (e) {
      setState(() {
        _addressObjects = [];
        _selectedAddressObj = null;
      });
    }
  }

  Future<void> _fetchCartItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _cartItems = [];
          _products = {};
          _isLoading = false;
        });
        return;
      }
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();
      final cartItems = cartSnapshot.docs
          .map((doc) => CartItem.fromFirestore(doc.data(), doc.id))
          .toList();
      // Fetch product details for each cart item
      Map<String, Product> products = {};
      for (final item in cartItems) {
        final prodDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(item.productId)
            .get();
        if (prodDoc.exists) {
          products[item.productId] =
              Product.fromJson(prodDoc.data()!, id: prodDoc.id);
        }
      }
      setState(() {
        _cartItems = cartItems;
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el carrito: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeCartItem(String id) async {
    final user = await fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(id)
          .delete();
      await _fetchCartItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado del carrito.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQty) async {
    if (newQty < 1) return;
    final user = await fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(item.id)
          .update({'quantity': newQty});
      await _fetchCartItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cantidad actualizada a $newQty.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar cantidad: $e')),
      );
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
      : 0.0;

  double get _total => _subtotal + _isv + _shipping;

  Future<void> _finalizePurchase() async {
    if (_cartItems.isEmpty) return;
    final user = await fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      // 1. Obtener los productos del carrito
      final products = _cartItems.map((item) {
        final product = _products[item.productId];
        return {
          'title': product?.title ?? '',
          'quantity': item.quantity,
          'price': product?.price ?? 0.0,
          'sellerId': product?.sellerId ?? '',
        };
      }).toList();

      // 1.1 Actualizar el stock de cada producto según la cantidad comprada
      for (final item in _cartItems) {
        final product = _products[item.productId];
        if (product == null) continue;
        final productRef =
            FirebaseFirestore.instance.collection('products').doc(product.id);
        // Leer el stock actual para evitar condiciones de carrera
        final prodDoc = await productRef.get();
        if (!prodDoc.exists) continue;
        final currentStock = (prodDoc.data()?['stock'] ?? 0) as int;
        final newStock = (currentStock - item.quantity) < 0
            ? 0
            : (currentStock - item.quantity);
        await productRef.update({'stock': newStock});
      }

      // 2. Crear el objeto de compra
      final purchase = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'userId': user.uid,
        'products': products,
        'total': _total,
        'date': DateTime.now().toIso8601String(),
      };
      // 3. Agregar la compra al historial del usuario
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.update({
        'purchaseHistory': FieldValue.arrayUnion([purchase])
      });
      // Notificar al comprador
      await NotificationService.createNotificationForUser(
        userId: user.uid,
        title: '¡Compra realizada!',
        body:
            'Tu compra por un total de L. ${_total.toStringAsFixed(2)} fue exitosa.',
      );
      // Notificar a cada vendedor solo una vez, indicando la cantidad total y los títulos de los productos vendidos
      final Map<String, List<Map<String, dynamic>>> ventasPorVendedor = {};
      for (final prod in products) {
        final sellerId = prod['sellerId'] as String?;
        if (sellerId != null && sellerId.isNotEmpty && sellerId != user.uid) {
          ventasPorVendedor.putIfAbsent(sellerId, () => []).add(prod);
        }
      }
      for (final entry in ventasPorVendedor.entries) {
        final sellerId = entry.key;
        final ventas = entry.value;
        final totalCantidad =
            ventas.fold<int>(0, (sum, p) => sum + (p['quantity'] as int? ?? 0));
        final titulos =
            ventas.map((p) => '"${p['title']}" (x${p['quantity']})').join(', ');
        await NotificationService.createNotificationForUser(
          userId: sellerId,
          title: '¡Has realizado una venta!',
          body: 'Vendiste $totalCantidad producto(s): $titulos.',
        );
      }
      // 4. Limpiar el carrito
      final cartRef = userRef.collection('cart');
      final cartSnapshot = await cartRef.get();
      for (final doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }
      setState(() {
        _cartItems.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Compra realizada con éxito!')),
        );
        Navigator.pushNamed(context, '/purchase-history');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al finalizar la compra: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final facturaWidget = Material(
      elevation: 12,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Factura',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
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
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Dirección:',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _addressObjects.isEmpty
                                ? const Text('No hay direcciones',
                                    textAlign: TextAlign.end)
                                : DropdownButton<Address>(
                                    value: _selectedAddressObj,
                                    isExpanded: true,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedAddressObj = value;
                                      });
                                    },
                                    items: _addressObjects
                                        .map((address) => DropdownMenuItem(
                                              value: address,
                                              child: Text(
                                                address.street +
                                                    ', ' +
                                                    address.city +
                                                    (address.state.isNotEmpty
                                                        ? ', ' + address.state
                                                        : '') +
                                                    ', ' +
                                                    address.country,
                                                overflow: TextOverflow.ellipsis,
                                              ),
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
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                  _selectedShippingIndex = value!;
                                });
                              },
                              items: List.generate(
                                _shippingOptions.length,
                                (i) => DropdownMenuItem(
                                  value: i,
                                  child: Text(_shippingOptions[i]['label']),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:', style: TextStyle(fontSize: 18)),
                        Text(_subtotal.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ISV (15%):',
                            style: TextStyle(fontSize: 18)),
                        Text(_isv.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Envío:', style: TextStyle(fontSize: 18)),
                        Text(_shipping.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(_total.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            if (_selectedShippingIndex != 2 && (_selectedAddressObj == null))
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Debes seleccionar una dirección para el envío.',
                  style: TextStyle(
                      color: Colors.red[700], fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed:
                  (_selectedShippingIndex == 2 || (_selectedAddressObj != null))
                      ? _finalizePurchase
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Finalizar compra',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );

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
        shape: const Border(
          bottom: BorderSide(color: Colors.transparent, width: 0),
        ),
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
          ? const Center(child: CustomImageSpinner(size: 40))
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
                              size: 80, color: Color(0xFF5C3D2E)),
                          SizedBox(height: 16),
                          Text(
                            'Tu carrito está vacío',
                            style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFF5C3D2E),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final double maxContentWidth = 700;
                        final double horizontalPadding =
                            constraints.maxWidth > maxContentWidth
                                ? (constraints.maxWidth - maxContentWidth) / 2
                                : 0.0;
                        return SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(horizontalPadding + 16,
                                16, horizontalPadding + 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(0),
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
                                          borderRadius:
                                              BorderRadius.circular(16)),
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: product
                                                      .imageUrls.isNotEmpty
                                                  ? (() {
                                                      final img = product
                                                          .imageUrls.first;
                                                      bool isBase64Image(
                                                          String s) {
                                                        return (s.startsWith(
                                                                    '/9j') ||
                                                                s.startsWith(
                                                                    'iVBOR')) &&
                                                            s.length > 100;
                                                      }

                                                      if (isBase64Image(img)) {
                                                        try {
                                                          final bytes =
                                                              base64Decode(img);
                                                          if (bytes
                                                                  .lengthInBytes >
                                                              5 * 1024 * 1024) {
                                                            throw Exception(
                                                                'Imagen demasiado grande');
                                                          }
                                                          return Image.memory(
                                                            bytes,
                                                            width: 64,
                                                            height: 64,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Container(
                                                                width: 64,
                                                                height: 64,
                                                                color: const Color(
                                                                    0xFFE1D4C2),
                                                                child:
                                                                    const Icon(
                                                                  Icons
                                                                      .image_not_supported_outlined,
                                                                  size: 28,
                                                                  color: Color(
                                                                      0xFF5C3D2E),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        } catch (e) {
                                                          return Container(
                                                            width: 64,
                                                            height: 64,
                                                            color: const Color(
                                                                0xFFE1D4C2),
                                                            child: const Icon(
                                                              Icons
                                                                  .image_not_supported_outlined,
                                                              size: 28,
                                                              color: Color(
                                                                  0xFF5C3D2E),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                      return Image.network(
                                                        img,
                                                        width: 64,
                                                        height: 64,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Container(
                                                            width: 64,
                                                            height: 64,
                                                            color: const Color(
                                                                0xFFE1D4C2),
                                                            child: const Icon(
                                                              Icons
                                                                  .image_not_supported_outlined,
                                                              size: 28,
                                                              color: Color(
                                                                  0xFF5C3D2E),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    })()
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF2C1810)),
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
                                                        color:
                                                            Color(0xFF5C3D2E),
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                                          Icons
                                                              .remove_circle_outline,
                                                          color: Colors.brown),
                                                      onPressed: () =>
                                                          _updateQuantity(
                                                              item,
                                                              item.quantity -
                                                                  1),
                                                    ),
                                                    Text('${item.quantity}',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16)),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons
                                                              .add_circle_outline,
                                                          color: Colors.brown),
                                                      onPressed: () =>
                                                          _updateQuantity(
                                                              item,
                                                              item.quantity +
                                                                  1),
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      bottomBar: _cartItems.isNotEmpty ? facturaWidget : null,
    );
  }
}
