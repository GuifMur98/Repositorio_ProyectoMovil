import 'package:flutter/material.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final String redirectRoute;

  const ProtectedRoute({
    super.key,
    required this.child,
    this.redirectRoute = '/login',
  });

  @override
  Widget build(BuildContext context) {
    // Simulación: siempre permite el acceso, elimina la lógica de AuthService
    return child;
  }
}
