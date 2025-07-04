import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 90),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Image.asset('assets/images/Logo_Proyecto.png', height: 150),
                    const SizedBox(height: 8),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Card(
              margin: EdgeInsets.zero,
              color: const Color(0xFFE1D4C2),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Bienvenidos',
                      style: TextStyle(
                        color: Color(0xFF5C3D2E),
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: const [
                            Text(
                              'Descubre una amplia variedad de productos al mejor precio, todo en un solo lugar. En TradeNest te ofrecemos una experiencia de compra rápida, segura y fácil, con artículos seleccionados para ti.',
                              style: TextStyle(
                                  color: Color(0xFF5C3D2E), fontSize: 21),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              '¡Empieza a comprar con un solo clic!',
                              style: TextStyle(
                                color: Color(0xFF5C3D2E),
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 70),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5C3D2E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                ),
                              ),
                              child: const Text('Iniciar sesión'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5C3D2E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                ),
                              ),
                              child: const Text('Registrarse'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 77),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
