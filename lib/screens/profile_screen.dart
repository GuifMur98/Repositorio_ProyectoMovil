import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
              decoration: const BoxDecoration(
                color: Color(0xFFE1D4C2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF5C3D2E),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nombre del Usuario',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3D2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'usuario@email.com',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Productos', '12'),
                      _buildStatColumn('Valoración', '4.8'),
                      _buildStatColumn('Ventas', '8'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSettingsSection(
                    'Configuración de la cuenta',
                    [
                      _buildSettingsTile(
                        Icons.person_outline,
                        'Editar perfil',
                        () {},
                      ),
                      _buildSettingsTile(
                        Icons.location_on_outlined,
                        'Mis direcciones',
                        () {},
                      ),
                      _buildSettingsTile(
                        Icons.notifications_none,
                        'Notificaciones',
                        () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    'Mis productos',
                    [
                      _buildSettingsTile(
                        Icons.shopping_bag_outlined,
                        'Productos publicados',
                        () {},
                      ),
                      _buildSettingsTile(
                        Icons.favorite_border,
                        'Productos favoritos',
                        () {
                          Navigator.pushNamed(context, '/favorites');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    'Otros',
                    [
                      _buildSettingsTile(
                        Icons.help_outline,
                        'Ayuda y soporte',
                        () {},
                      ),
                      _buildSettingsTile(
                        Icons.privacy_tip_outlined,
                        'Privacidad y seguridad',
                        () {},
                      ),
                      _buildSettingsTile(
                        Icons.logout,
                        'Cerrar sesión',
                        () {
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        textColor: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF5C3D2E),
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Publicar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/favorites');
              break;
            case 2:
              Navigator.pushNamed(context, '/create-product');
              break;
          }
        },
      ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C3D2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C3D2E),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE1D4C2).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: tiles,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5C3D2E)),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF5C3D2E)),
      onTap: onTap,
    );
  }
}