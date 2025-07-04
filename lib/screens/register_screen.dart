import 'package:flutter/material.dart';
import 'package:proyecto/services/auth_service.dart';
import 'package:proyecto/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_image_spinner.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final registeredUser = await AuthService.registerWithEmailPassword(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (registeredUser != null) {
        final user = registeredUser['user'] as User;

        // Crear documento de usuario en Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.id).set({
          'name': user.name,
          'email': user.email,
          'favoriteProducts': [],
          'addresses': [],
          'publishedProducts': [],
          'purchaseHistory': [],
        });

        // Guardar la sesión después de un registro exitoso
        await AuthService.saveSession(user);

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
      } else {
        setState(() {
          _errorMessage = 'El correo electrónico ya está registrado';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar usuario: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su nombre';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su correo electrónico';
    }
    if (!value.contains('@')) {
      return 'Por favor ingrese un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirme su contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1D4C2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D4C2),
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.transparent, width: 0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5C3D2E)),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/welcome', (route) => false);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Logo y título
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'TradeNest',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3D2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Crea tu cuenta',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Formulario de registro
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha((0.1 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Registro',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3D2E),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Campo de nombre
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre completo',
                            labelStyle:
                                const TextStyle(color: Color(0xFF5C3D2E)),
                            floatingLabelStyle:
                                const TextStyle(color: Color(0xFF5C3D2E)),
                            hintText: 'Ingresa tu nombre',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF5C3D2E),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFE1D4C2)
                                .withAlpha((0.3 * 255).toInt()),
                          ),
                          validator: _validateName,
                        ),
                        const SizedBox(height: 16),
                        // Campo de email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            labelStyle:
                                const TextStyle(color: Color(0xFF5C3D2E)),
                            floatingLabelStyle:
                                const TextStyle(color: Color(0xFF5C3D2E)),
                            hintText: 'ejemplo@correo.com',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF5C3D2E),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFE1D4C2)
                                .withAlpha((0.3 * 255).toInt()),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        // Campo de contraseña
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle:
                                const TextStyle(color: Color(0xFF5C3D2E)),
                            floatingLabelStyle:
                                const TextStyle(color: Color(0xFF5C3D2E)),
                            hintText: '',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF5C3D2E),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF5C3D2E),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFE1D4C2)
                                .withAlpha((0.3 * 255).toInt()),
                          ),
                          obscureText: _obscurePassword,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),
                        // Campo de confirmar contraseña
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirmar contraseña',
                            labelStyle:
                                const TextStyle(color: Color(0xFF5C3D2E)),
                            floatingLabelStyle:
                                const TextStyle(color: Color(0xFF5C3D2E)),
                            hintText: '',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF5C3D2E),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF5C3D2E),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFE1D4C2)
                                .withAlpha((0.3 * 255).toInt()),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: _validateConfirmPassword,
                        ),
                        const SizedBox(height: 24),
                        // Mensaje de error
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha((0.1 * 255).toInt()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Botón de registro
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C3D2E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CustomImageSpinner(
                                      size: 20, color: Colors.white),
                                )
                              : const Text(
                                  'Registrarse',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Enlace para iniciar sesión
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            '¿Ya tienes una cuenta? Inicia sesión',
                            style: TextStyle(
                              color: Color(0xFF5C3D2E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
