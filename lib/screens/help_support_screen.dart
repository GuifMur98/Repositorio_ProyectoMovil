import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Ayuda y Soporte',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    const Icon(Icons.support_agent,
                        size: 60, color: Color(0xFF5C3D2E)),
                    const SizedBox(height: 12),
                    const Text(
                      '¿Necesitas ayuda?',
                      style: TextStyle(
                          fontSize: 23, // más grande
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3D2E)),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Estamos aquí para apoyarte. Si tienes dudas, problemas técnicos o sugerencias, contáctanos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, color: Color(0xFF5C3D2E)),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C3D2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      icon: const Icon(Icons.email_outlined),
                      label: const Text('Contactar soporte'),
                      onPressed: () {
                        // Acción: abrir email
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Contacto de soporte'),
                            content:
                                const Text('Escríbenos a soporte@ejemplo.com'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Preguntas frecuentes',
                      style: TextStyle(
                          fontSize: 20, // más grande
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3D2E)),
                    ),
                    SizedBox(height: 12),
                    Text('• ¿Cómo recupero mi contraseña?',
                        style: TextStyle(fontSize: 16)),
                    Text(
                        '  Ve a la pantalla de inicio de sesión y selecciona "¿Olvidaste tu contraseña?".',
                        style: TextStyle(fontSize: 15)),
                    SizedBox(height: 8),
                    Text('• ¿Cómo publico un producto?',
                        style: TextStyle(fontSize: 16)),
                    Text(
                        '  Ve a la pestaña de publicar y completa el formulario.',
                        style: TextStyle(fontSize: 15)),
                    SizedBox(height: 8),
                    Text('• ¿Cómo contacto a un vendedor?',
                        style: TextStyle(fontSize: 16)),
                    Text(
                        '  Usa el chat disponible en la pantalla de detalle del producto.',
                        style: TextStyle(fontSize: 15)),
                    SizedBox(height: 8),
                    Text('• ¿Dónde puedo ver mis compras?',
                        style: TextStyle(fontSize: 16)),
                    Text('  En tu perfil, accede a "Historial de compras".',
                        style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                child: const Text(
                  '¡Gracias por usar nuestra app! Si tienes sugerencias, no dudes en escribirnos.',
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0), fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
