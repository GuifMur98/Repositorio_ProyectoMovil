import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder: aquí podrías mostrar notificaciones reales
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Color(0xFF5C3D2E),
      ),
      body: const Center(child: Text('Aquí aparecerán tus notificaciones.')),
    );
  }
}
