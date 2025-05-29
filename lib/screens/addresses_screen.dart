import 'package:flutter/material.dart';
import 'package:proyecto/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Importar modelo de dirección (necesitaremos crearlo o definirlo)
// import 'package:proyecto/models/address.dart';

// Placeholder: aquí podrías implementar la gestión real de direcciones
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Map<String, dynamic>> _addresses =
      []; // Usaremos Map<String, dynamic> por ahora
  bool _loading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');

      if (userEmail != null) {
        final user = await DatabaseService.getUserByEmail(userEmail);
        if (user != null) {
          setState(() {
            _currentUserId = user.id;
          });
          await _loadAddresses();
        } else {
          setState(() {
            _loading = false;
          });
        }
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('Error al inicializar datos en AddressesScreen: $e');
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar datos de usuario'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _loadAddresses() async {
    if (_currentUserId == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final addresses = await DatabaseService.getAddressesByUserId(
        _currentUserId!,
      );

      setState(() {
        _addresses = addresses;
        _loading = false;
      });
    } catch (e) {
      print('Error al cargar direcciones: $e');
      setState(() {
        _addresses = [];
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar direcciones'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _navigateToAddAddressScreen() async {
    // Navegar a una nueva pantalla para agregar dirección y esperar resultado
    final result = await Navigator.pushNamed(context, '/add-address');
    if (result == true) {
      // Si se agregó una dirección exitosamente
      _loadAddresses(); // Recargar la lista
    }
  }

  // Future<void> _editAddress(int addressId) async { ... }
  // Future<void> _deleteAddress(int addressId) async { ... }

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
            onPressed: () {
              // Navegar a la pantalla para agregar nueva dirección
              _navigateToAddAddressScreen();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
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
                // Diseño para cada tarjeta de dirección
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: InkWell(
                    onTap: () async {
                      // Navegar a la pantalla de edición de dirección
                      final result = await Navigator.pushNamed(
                        context,
                        '/edit-address',
                        arguments: {'addressId': address['id'] as int},
                      );
                      if (result == true) {
                        _loadAddresses();
                      }
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
