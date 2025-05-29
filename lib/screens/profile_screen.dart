import 'package:flutter/material.dart';
import 'package:proyecto/services/auth_service.dart';
import 'package:proyecto/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto/screens/purchase_history_screen.dart';
import 'package:proyecto/screens/edit_profile_screen.dart';
import 'package:proyecto/screens/addresses_screen.dart';
import 'package:proyecto/screens/notifications_screen.dart';
import 'package:proyecto/screens/user_products_screen.dart';
import 'package:proyecto/screens/help_support_screen.dart';
import 'package:proyecto/screens/privacy_security_screen.dart';
import 'package:proyecto/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _loading = true;
  String? _userName;
  String? _userEmail;
  int _publishedCount = 0;
  int _salesCount = 0;
  double _rating =
      4.8; // Placeholder, puedes cambiarlo si tienes ratings reales
  File? _selectedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _loading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      print('Email del usuario: $userEmail'); // Debug log

      if (userEmail != null) {
        final user = await DatabaseService.getUserByEmail(userEmail);
        print('Usuario encontrado: ${user?.toMap()}'); // Debug log

        if (user != null) {
          final products = await DatabaseService.getProducts();
          print('Productos encontrados: ${products.length}'); // Debug log

          setState(() {
            _user = user;
            _userName = user.name;
            _userEmail = user.email;
            _publishedCount = products
                .where((p) => p.sellerId == user.id)
                .length;
            _salesCount = 0;
            _loading = false;
          });
        } else {
          print('No se encontró el usuario con email: $userEmail'); // Debug log
          setState(() {
            _loading = false;
          });
        }
      } else {
        print('No hay email guardado en SharedPreferences'); // Debug log
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _saveProfileImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar la imagen')),
      );
    }
  }

  Future<void> _saveProfileImage() async {
    if (_selectedImage == null || _user == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final savedImage = await _selectedImage!.copy(
        '${directory.path}/$fileName',
      );

      final updatedUser = User(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        password: _user!.password,
        phone: _user!.phone,
        address: _user!.address,
        imageUrl: savedImage.path,
      );

      await DatabaseService.updateUser(updatedUser);
      await _loadUserData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen de perfil actualizada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar la imagen de perfil'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const Center(child: Text('Error al cargar el perfil'))
          : SingleChildScrollView(
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
                        Text(
                          _userName ?? _user?.name ?? 'Nombre del Usuario',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3D2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _userEmail ?? _user?.email ?? 'usuario@email.com',
                          style: const TextStyle(
                            color: Color(0xFF5C3D2E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn(
                              'Productos',
                              _publishedCount.toString(),
                            ),
                            _buildStatColumn(
                              'Valoración',
                              _rating.toStringAsFixed(1),
                            ),
                            _buildStatColumn('Compras', _salesCount.toString()),
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
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                          _buildSettingsTile(
                            Icons.location_on_outlined,
                            'Mis direcciones',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddressesScreen(),
                                ),
                              );
                            },
                          ),
                          _buildSettingsTile(
                            Icons.notifications_none,
                            'Notificaciones',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen(),
                                ),
                              );
                            },
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildSettingsSection('Mis productos', [
                          _buildSettingsTile(
                            Icons.shopping_bag_outlined,
                            'Productos publicados',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const UserProductsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildSettingsTile(
                            Icons.favorite_border,
                            'Productos favoritos',
                            () {
                              Navigator.pushNamed(context, '/favorites');
                            },
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildSettingsSection('Otros', [
                          _buildSettingsTile(
                            Icons.history,
                            'Historial de compras',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PurchaseHistoryScreen(),
                                ),
                              );
                            },
                          ),
                          _buildSettingsTile(
                            Icons.help_outline,
                            'Ayuda y soporte',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HelpSupportScreen(),
                                ),
                              );
                            },
                          ),
                          _buildSettingsTile(
                            Icons.privacy_tip_outlined,
                            'Privacidad y seguridad',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PrivacySecurityScreen(),
                                ),
                              );
                            },
                          ),
                          _buildSettingsTile(
                            Icons.logout,
                            'Cerrar sesión',
                            () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('is_logged_in', false);
                              await prefs.remove('user_name');
                              await prefs.remove('user_email');
                              if (!mounted) return;
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                            textColor: Colors.red,
                          ),
                        ]),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Publicar',
          ),
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

  Widget _buildProfileImage() {
    if (_user?.imageUrl != null && _user!.imageUrl!.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SafeArea(
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Galería'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_camera),
                      title: const Text('Cámara'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF5C3D2E),
              child: ClipOval(
                child: Image.file(
                  File(_user!.imageUrl!),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF5C3D2E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Galería'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Cámara'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF5C3D2E),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF5C3D2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
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
          style: const TextStyle(
            color: Color(0xFF5C3D2E),
            fontWeight: FontWeight.w500,
          ),
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
          child: Column(children: tiles),
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
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF5C3D2E)),
      onTap: onTap,
    );
  }
}
