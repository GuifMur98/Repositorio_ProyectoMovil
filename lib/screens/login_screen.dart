import 'package:flutter/material.dart';
import 'package:proyecto/services/auth_service.dart';
import 'package:proyecto/models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.loginWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result != null) {
        final user = result['user'] as User;

        // Guardar la sesión después de un login exitoso
        await AuthService.saveSession(user);

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        setState(() {
          _errorMessage = 'Credenciales inválidas';
        });
      }
    } catch (e) {
      setState(() {
        if (e is Exception &&
            e.toString().contains('Credenciales incorrectas')) {
          _errorMessage = 'Correo o contraseña incorrectos';
        } else if (e is Exception &&
            e.toString().contains('Correo electrónico inválido')) {
          _errorMessage = 'Correo electrónico inválido';
        } else if (e is Exception && e.toString().contains('deshabilitada')) {
          _errorMessage = 'La cuenta está deshabilitada';
        } else if (e is Exception && e.toString().contains('autenticación')) {
          _errorMessage = 'Error de autenticación. Intenta de nuevo.';
        } else {
          _errorMessage = 'Error al iniciar sesión';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1D4C2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D4C2),
        elevation: 0,
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          'Inicia sesión',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Formulario de inicio de sesión
                  Container(
                    padding: const EdgeInsets.all(24),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3D2E),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Campo de email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
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
                            fillColor: const Color(0xFFE1D4C2).withOpacity(0.3),
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
                            fillColor: const Color(0xFFE1D4C2).withOpacity(0.3),
                          ),
                          obscureText: _obscurePassword,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 24),
                        // Mensaje de error
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
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
                        // Botón de inicio de sesión
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
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
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Enlace para recuperar contraseña
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(color: Color(0xFF5C3D2E)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Enlace para registrarse
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            '¿No tienes una cuenta? Regístrate',
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
