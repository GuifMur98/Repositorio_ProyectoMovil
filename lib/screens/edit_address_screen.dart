import 'package:flutter/material.dart';
import 'package:proyecto/services/database_service.dart';

class EditAddressScreen extends StatefulWidget {
  final int addressId; // Recibir el ID de la dirección a editar

  const EditAddressScreen({super.key, required this.addressId});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isLoading = true;
  Map<String, dynamic>?
  _addressData; // Para almacenar los datos de la dirección

  @override
  void initState() {
    super.initState();
    _loadAddressData();
  }

  Future<void> _loadAddressData() async {
    try {
      final address = await DatabaseService.getAddressById(widget.addressId);

      if (address != null) {
        _addressData = address;
        _streetController.text = address['street'] as String? ?? '';
        _cityController.text = address['city'] as String? ?? '';
        _stateController.text = address['state'] as String? ?? '';
        _zipCodeController.text = address['zipCode'] as String? ?? '';
        _countryController.text = address['country'] as String? ?? '';
      } else {
        // Manejar el caso en que la dirección no se encuentra
        print('Dirección con ID ${widget.addressId} no encontrada.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dirección no encontrada.'),
              backgroundColor: Colors.red,
            ),
          );
          // Opcional: navegar de regreso si la dirección no existe
          // Navigator.pop(context, false);
        }
      }
    } catch (e) {
      print('Error al cargar datos de la dirección: $e');
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar datos de la dirección.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> _saveChanges() async {
    if (_addressData == null) return; // No hay datos para guardar

    setState(() {
      _isLoading = true;
    });

    final updatedAddress = {
      'id': _addressData!['id'] as int,
      'userId':
          _addressData!['userId'] as String, // Mantener el userId original
      'street': _streetController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'zipCode': _zipCodeController.text.trim(),
      'country': _countryController.text.trim(),
    };

    try {
      // Necesitaremos un método updateAddress en DatabaseService
      await DatabaseService.updateAddress(
        updatedAddress['id'] as int,
        updatedAddress,
      ); // Llamar al método de actualización

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dirección actualizada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        // Indicar que se realizó un cambio (actualización)
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error al actualizar dirección: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar dirección.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAddress() async {
    if (_addressData == null) return; // No hay dirección para eliminar

    // Opcional: Mostrar un diálogo de confirmación antes de eliminar
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar dirección'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar esta dirección?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancelar
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), // Confirmar
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ), // Botón rojo para eliminar
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false; // Si el diálogo se cierra sin seleccionar, se considera Cancelar

    if (!confirmed) return; // Si no se confirmó, salir

    setState(() {
      _isLoading = true;
    });

    try {
      // Necesitaremos un método deleteAddress en DatabaseService
      await DatabaseService.deleteAddress(
        _addressData!['id'] as int,
      ); // Llamar al método de eliminación

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dirección eliminada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        // Indicar que se realizó un cambio (eliminación)
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error al eliminar dirección: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar dirección.'),
            backgroundColor: Colors.red,
          ),
        );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_addressData != null &&
              !_isLoading) // Mostrar botón eliminar si hay datos y no está cargando
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white,
              ), // Icono de eliminar
              onPressed: _deleteAddress,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addressData == null
          ? const Center(
              child: Text(
                'No se pudieron cargar los datos de la dirección.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            )
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
                    onPressed:
                        _saveChanges, // Llama a la función de guardar cambios
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
                      'Guardar cambios',
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
