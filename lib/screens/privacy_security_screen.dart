import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Privacidad y Seguridad',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.transparent, width: 0),
        ),
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
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15), // 0.06 * 255 = 15
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Privacidad',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3D2E)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tus datos personales están protegidos y no se comparten con terceros. Solo usamos tu información para mejorar tu experiencia en la app.',
                      style: TextStyle(fontSize: 20, color: Color(0xFF5C3D2E)),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• Puedes editar o eliminar tus datos personales desde tu perfil.',
                      style: TextStyle(fontSize: 18, color: Color(0xFF5C3D2E)),
                    ),
                    Text(
                      '• No compartimos tu información de contacto públicamente.',
                      style: TextStyle(fontSize: 18, color: Color(0xFF5C3D2E)),
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
                      color: Colors.black.withAlpha(15), // 0.06 * 255 = 15
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Seguridad',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3D2E)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Utilizamos cifrado y buenas prácticas para proteger tu información.',
                      style: TextStyle(fontSize: 20, color: Color(0xFF5C3D2E)),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• Tus contraseñas se almacenan de forma segura y nunca se comparten.',
                      style: TextStyle(fontSize: 18, color: Color(0xFF5C3D2E)),
                    ),
                    Text(
                      '• Recomendamos usar contraseñas seguras y no compartirlas con nadie.',
                      style: TextStyle(fontSize: 18, color: Color(0xFF5C3D2E)),
                    ),
                    Text(
                      '• Si detectas actividad sospechosa, cambia tu contraseña y contáctanos.',
                      style: TextStyle(fontSize: 18, color: Color(0xFF5C3D2E)),
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
                      color: Colors.black.withAlpha(8), // 0.03 * 255 = 8
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                child: Column(
                  children: const [
                    Text(
                      'Consejos para tu seguridad',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3D2E)),
                    ),
                    SizedBox(height: 10),
                    Text(
                        '• No compartas tus datos personales con desconocidos.',
                        style: TextStyle(fontSize: 17)),
                    Text(
                        '• Verifica la reputación de los vendedores antes de comprar.',
                        style: TextStyle(fontSize: 17)),
                    Text(
                        '• Usa siempre los canales oficiales de la app para comunicarte.',
                        style: TextStyle(fontSize: 17)),
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
                      color: Colors.black.withAlpha(8), // 0.03 * 255 = 8
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                child: const Text(
                  'Para más información, contacta a privacidad@ejemplo.com o revisa nuestra política completa en la web.',
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0), fontSize: 19),
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
