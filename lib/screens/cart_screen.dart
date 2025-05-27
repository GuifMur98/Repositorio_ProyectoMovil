import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de compra'),
        backgroundColor: const Color(0xFF5C3D2E),
      ),
      backgroundColor: const Color(0xFFE1D4C2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_cart, size: 80, color: Color(0xFF5C3D2E)),
            SizedBox(height: 24),
            Text(
              'Tu carrito está vacío',
              style: TextStyle(fontSize: 22, color: Color(0xFF5C3D2E)),
            ),
          ],
        ),
      ),
    );
  }
}
