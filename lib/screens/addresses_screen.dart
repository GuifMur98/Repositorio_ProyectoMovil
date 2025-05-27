import 'package:flutter/material.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder: aquí podrías implementar la gestión real de direcciones
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis direcciones'),
        backgroundColor: Color(0xFF5C3D2E),
      ),
      body: const Center(child: Text('Aquí podrás gestionar tus direcciones.')),
    );
  }
}
