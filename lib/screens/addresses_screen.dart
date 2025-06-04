import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import '../services/user_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = UserService.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      final addresses = await AddressService.getAddressesByUser(user.id);
      setState(() {
        _addresses = addresses;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error al cargar direcciones: [31m${e.toString()}[0m')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAddAddressScreen() async {
    final result = await Navigator.pushNamed(context, '/add-address');
    if (result == true) {
      _fetchAddresses();
    }
  }

  String extractHexId(String id) {
    final match = RegExp(r'ObjectId\("([a-fA-F0-9]{24})"\)').firstMatch(id);
    if (match != null) {
      return match.group(1)!;
    }
    return id;
  }

  Future<void> _deleteAddress(Address address) async {
    print('Intentando eliminar dirección con id: ${address.id}');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar dirección'),
        content:
            const Text('¿Estás seguro de que deseas eliminar esta dirección?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      String id = address.id;
      id = extractHexId(id); // Extrae el valor hexadecimal si es necesario
      final isValidHex24 = id.isNotEmpty &&
          RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(id);
      print('ID válido para eliminación: $isValidHex24');
      if (!isValidHex24) {
        print('ID inválido, cancelando eliminación.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Error: ID de dirección inválido. No se puede eliminar.')),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        print('Llamando a AddressService.deleteAddress...');
        await AddressService.deleteAddress(id); // Usa el id hexadecimal
        print('Dirección eliminada correctamente.');
        _fetchAddresses();
      } catch (e) {
        print('Error al eliminar dirección: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al eliminar dirección: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Eliminación cancelada por el usuario.');
    }
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
      body: _isLoading
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
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          address.street,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3D2E),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${address.city}${address.state.isNotEmpty ? ', ${address.state}' : ''}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              address.zipCode,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              address.country,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAddress(address),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
