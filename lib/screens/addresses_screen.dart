import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import '../widgets/custom_image_spinner.dart';

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
      final addresses = await AddressService.getAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _addresses = [];
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar direcciones: $e')),
      );
    }
  }

  void _navigateToAddAddressScreen() async {
    final result = await Navigator.pushNamed(context, '/add-address');
    if (!mounted) return;
    if (result is Address) {
      setState(() {
        _addresses.add(result);
      });
    }
    await _fetchAddresses(); // Refresca la lista tras agregar
    if (!mounted) return;
  }

  Future<void> _deleteAddress(Address address) async {
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
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (!mounted) return;
    if (confirm == true) {
      try {
        await AddressService.deleteAddress(address.id);
        await _fetchAddresses();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dirección eliminada.')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar dirección: $e')),
        );
      }
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
        shape: const Border(
          bottom: BorderSide(color: Colors.transparent, width: 0),
        ),
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
          ? const Center(child: CustomImageSpinner(size: 40))
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  '/edit-address',
                                  arguments: address,
                                );
                                if (result is Address) {
                                  await _fetchAddresses();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAddress(address),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
