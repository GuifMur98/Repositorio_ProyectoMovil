import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFF5C3D2E), width: 3),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/Logo_PMiniatura.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
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
          label,
          style: const TextStyle(color: Color(0xFF5C3D2E), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C3D2E),
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5C3D2E)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  _buildProfileImage(),
                  const SizedBox(height: 16),
                  const Text(
                    'Usuario Ejemplo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3D2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'usuario@ejemplo.com',
                    style: TextStyle(
                      color: Color(0xFF5C3D2E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Productos', '5'),
                      _buildStatColumn('Valoración', '4.8'),
                      _buildStatColumn('Compras', '3'),
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
                  _buildSettingsSection('Configuración de la cuenta', [
                    _buildSettingsTile(
                      Icons.person_outline,
                      'Editar perfil',
                      () => Navigator.pushNamed(context, '/edit-profile'),
                    ),
                    _buildSettingsTile(
                      Icons.location_on_outlined,
                      'Mis direcciones',
                      () => Navigator.pushNamed(context, '/addresses'),
                    ),
                    _buildSettingsTile(
                      Icons.notifications_none,
                      'Notificaciones',
                      () => Navigator.pushNamed(context, '/notifications'),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSettingsSection('Mis productos', [
                    _buildSettingsTile(
                      Icons.shopping_bag_outlined,
                      'Productos publicados',
                      () => Navigator.pushNamed(context, '/user-products'),
                    ),
                    _buildSettingsTile(
                      Icons.history,
                      'Historial de compras',
                      () => Navigator.pushNamed(context, '/purchase-history'),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSettingsSection('Ayuda y soporte', [
                    _buildSettingsTile(
                      Icons.help_outline,
                      'Ayuda y soporte',
                      () => Navigator.pushNamed(context, '/help-support'),
                    ),
                    _buildSettingsTile(
                      Icons.security,
                      'Privacidad y seguridad',
                      () => Navigator.pushNamed(context, '/privacy-security'),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/welcome');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
