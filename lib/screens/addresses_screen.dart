import 'package:flutter/material.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  // Datos de ejemplo para las direcciones
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': 1,
      'street': 'Calle Principal 123',
      'city': 'Ciudad de Ejemplo',
      'state': 'Estado de Ejemplo',
      'zipCode': '12345',
      'country': 'País de Ejemplo',
    },
    {
      'id': 2,
      'street': 'Avenida Central 456',
      'city': 'Ciudad de Ejemplo',
      'state': 'Estado de Ejemplo',
      'zipCode': '67890',
      'country': 'País de Ejemplo',
    },
  ];

  void _navigateToAddAddressScreen() {
    // Mostrar mensaje de funcionalidad no disponible
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Funcionalidad no disponible en la versión de demostración',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Direcciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _navigateToAddAddressScreen,
          ),
        ],
      ),
      body: _addresses.isEmpty
          ? const Center(
              child: Text(
                'No tienes direcciones guardadas.',
                style: TextStyle(fontSize: 18, color: Color(0xFF5C3D2E)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      // Mostrar mensaje de funcionalidad no disponible
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Funcionalidad no disponible en la versión de demostración',
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address['street'] ?? 'Sin calle',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5C3D2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${address['city'] ?? 'Sin ciudad'}${address['state'] != null && address['state'].isNotEmpty ? ', ${address['state']}' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${address['zipCode'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            address['country'] ?? 'Sin país',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
