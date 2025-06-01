import 'package:flutter/material.dart';
import 'package:proyecto/services/user_service.dart';
import 'package:proyecto/services/auth_service.dart';
import 'package:proyecto/widgets/base_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = UserService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No hay usuario iniciado sesión'),
        ),
      );
    }

    return BaseScreen(
      currentIndex: 4, // Índice para la pestaña de perfil
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
            Navigator.pushReplacementNamed(context, '/cart');
            break;
          case 4:
            // Ya estamos en perfil
            break;
        }
      },
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con fondo café
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF5C3D2E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar con borde blanco
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF5C3D2E),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Sección de opciones principales
                  _buildSection(
                    title: 'Mis Opciones',
                    children: [
                      _buildOptionTile(
                        context,
                        icon: Icons.location_on,
                        title: 'Direcciones',
                        subtitle: 'Gestiona tus direcciones de entrega',
                        route: '/addresses',
                      ),
                      _buildOptionTile(
                        context,
                        icon: Icons.favorite,
                        title: 'Productos favoritos',
                        subtitle: 'Ver tus productos guardados',
                        route: '/favorites',
                      ),
                      _buildOptionTile(
                        context,
                        icon: Icons.shopping_bag,
                        title: 'Mis productos',
                        subtitle: 'Gestiona tus productos en venta',
                        route: '/user-products',
                      ),
                      _buildOptionTile(
                        context,
                        icon: Icons.history,
                        title: 'Historial de compras',
                        subtitle: 'Revisa tus compras anteriores',
                        route: '/purchase-history',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Sección de configuración
                  _buildSection(
                    title: 'Configuración',
                    children: [
                      _buildOptionTile(
                        context,
                        icon: Icons.edit,
                        title: 'Editar perfil',
                        subtitle: 'Actualiza tu información personal',
                        route: '/edit-profile',
                      ),
                      _buildOptionTile(
                        context,
                        icon: Icons.notifications,
                        title: 'Notificaciones',
                        subtitle: 'Configura tus preferencias',
                        route: '/notifications',
                      ),
                      _buildOptionTile(
                        context,
                        icon: Icons.help,
                        title: 'Ayuda y soporte',
                        subtitle: 'Obtén ayuda cuando la necesites',
                        route: '/help-support',
                      ),
                      _buildOptionTile(
                        context,
                        icon: Icons.security,
                        title: 'Privacidad y seguridad',
                        subtitle: 'Gestiona tu seguridad',
                        route: '/privacy-security',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Botón de cerrar sesión
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C3D2E),
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF5C3D2E).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF5C3D2E)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF5C3D2E),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF5C3D2E),
      ),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
