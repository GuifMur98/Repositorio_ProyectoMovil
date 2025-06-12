import 'package:flutter/material.dart';
import 'package:proyecto/services/auth_service.dart';
import 'package:proyecto/widgets/base_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
    // Obtener el usuario autenticado desde FirebaseAuth
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
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
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final source = await showDialog<ImageSource>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Seleccionar imagen'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: const Row(
                                          children: [
                                            Icon(Icons.camera_alt, color: Color(0xFF5C3D2E)),
                                            SizedBox(width: 8),
                                            Text('Tomar foto'),
                                          ],
                                        ),
                                        onTap: () => Navigator.of(context).pop(ImageSource.camera),
                                      ),
                                      const SizedBox(height: 16),
                                      GestureDetector(
                                        child: const Row(
                                          children: [
                                            Icon(Icons.photo_library, color: Color(0xFF5C3D2E)),
                                            SizedBox(width: 8),
                                            Text('Seleccionar de galería'),
                                          ],
                                        ),
                                        onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            if (source == null) return;
                            final picked = await picker.pickImage(source: source, imageQuality: 80);
                            if (picked != null) {
                              final bytes = await picked.readAsBytes();
                              final base64img = base64Encode(bytes);
                              await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).update({'avatarUrl': base64img});
                              await fbUser.updatePhotoURL(base64img);
                              (context as Element).markNeedsBuild();
                            }
                          },
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(fbUser.uid)
                                .get(),
                            builder: (context, snapshot) {
                              String? avatarBase64;
                              if (snapshot.hasData && snapshot.data!.data() != null) {
                                final data = snapshot.data!.data() as Map<String, dynamic>;
                                avatarBase64 = data['avatarUrl'];
                              }
                              return CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: (avatarBase64 != null && avatarBase64.isNotEmpty)
                                    ? MemoryImage(base64Decode(avatarBase64))
                                    : null,
                                child: (avatarBase64 == null || avatarBase64.isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Color(0xFF5C3D2E),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.edit, size: 20, color: Color(0xFF5C3D2E)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fbUser.displayName ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 28, // Aumentado
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fbUser.email ?? 'Sin email',
                    style: const TextStyle(
                      fontSize: 20, // Aumentado
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
                fontSize: 22, // Aumentado
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
        child:
            Icon(icon, color: const Color(0xFF5C3D2E), size: 28), // Aumentado
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF5C3D2E),
          fontWeight: FontWeight.w600,
          fontSize: 18, // Aumentado
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16, // Aumentado
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF5C3D2E),
        size: 28, // Aumentado
      ),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
