import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidad y seguridad'),
        backgroundColor: Color(0xFF5C3D2E),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacidad',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Tus datos personales están protegidos y no se comparten con terceros.',
            ),
            SizedBox(height: 24),
            Text(
              'Seguridad',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Utilizamos cifrado y buenas prácticas para proteger tu información.',
            ),
            SizedBox(height: 24),
            Text(
              'Para más información, contacta a privacidad@ejemplo.com',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
