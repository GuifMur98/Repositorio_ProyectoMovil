import 'package:flutter/material.dart';
import '../models/address.dart';
import '../widgets/custom_image_spinner.dart';
import '../services/address_service.dart';

class EditAddressScreen extends StatefulWidget {
  final Address address;
  const EditAddressScreen({super.key, required this.address});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _countryController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(text: widget.address.street);
    _cityController = TextEditingController(text: widget.address.city);
    _stateController = TextEditingController(text: widget.address.state);
    _zipCodeController = TextEditingController(text: widget.address.zipCode);
    _countryController = TextEditingController(text: widget.address.country);
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final street = _streetController.text.trim();
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final zipCode = _zipCodeController.text.trim();
    final country = _countryController.text.trim();

    if (street.isEmpty || city.isEmpty || country.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, completa los campos obligatorios (Calle, Ciudad, País).',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final updated = widget.address.copyWith(
        street: street,
        city: city,
        state: state,
        zipCode: zipCode,
        country: country,
      );
      await AddressService.updateAddress(updated);
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar cambios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _deleteAddress() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar dirección'),
        content:
            const Text('¿Estás seguro de que deseas eliminar esta dirección?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await AddressService.deleteAddress(widget.address.id);
      if (!mounted) return;
      Navigator.pop(context, null); // Regresa y notifica que se eliminó
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar dirección: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Dirección',
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
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _deleteAddress,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CustomImageSpinner(size: 40))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _streetController,
                    decoration: InputDecoration(
                      labelText: 'Calle y número',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.streetview),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Ciudad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: 'Estado/Provincia',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.area_chart),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _zipCodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Código Postal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.local_post_office_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _countryController,
                    decoration: InputDecoration(
                      labelText: 'País',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.flag_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C3D2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Guardar Cambios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
