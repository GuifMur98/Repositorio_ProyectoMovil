import 'package:flutter/material.dart';
import 'package:proyecto/widgets/base_screen.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 2, // Índice para la pestaña de publicar
      onNavigationTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/favorites');
            break;
          case 2:
            // Ya estamos en publicar
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
          'Publicar Producto',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text('Formulario de publicación'),
      ),
    );
  }
}
