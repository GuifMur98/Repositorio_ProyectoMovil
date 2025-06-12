import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _save() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty) {
      setState(() {
        _error = 'Por favor, completa los campos obligatorios.';
      });
      return;
    }

    if (password.isNotEmpty && password != confirmPassword) {
      setState(() {
        _error = 'Las contraseñas no coinciden.';
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'No hay usuario logueado.';
      });
      return;
    }

    setState(() {
      _error = null;
    });
    try {
      // Actualizar nombre
      if (name != user.displayName) {
        await user.updateDisplayName(name);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'name': name});
      }
      // Actualizar email
      if (email != user.email) {
        await user.updateEmail(email);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'email': email});
      }
      // Actualizar contraseña
      if (password.isNotEmpty) {
        await user.updatePassword(password);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = 'Error al actualizar el perfil: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60),
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
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'avatarUrl': base64img});
                            await user.updatePhotoURL(base64img);
                            setState(() {});
                          }
                        }
                      },
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).get(),
                        builder: (context, snapshot) {
                          String? avatarBase64;
                          if (snapshot.hasData && snapshot.data!.data() != null) {
                            final data = snapshot.data!.data() as Map<String, dynamic>;
                            avatarBase64 = data['avatarUrl'];
                          }
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: (avatarBase64 != null && avatarBase64.isNotEmpty)
                                ? MemoryImage(base64Decode(avatarBase64))
                                : null,
                            child: (avatarBase64 == null || avatarBase64.isEmpty)
                                ? const Icon(Icons.person, size: 60, color: Color(0xFF5C3D2E))
                                : null,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
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
                        child: const Icon(Icons.edit, size: 22, color: Color(0xFF5C3D2E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Actualiza tu información',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(height: 32, color: Colors.grey[300]),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Nueva contraseña',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirmar nueva contraseña',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C3D2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Guardar cambios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
