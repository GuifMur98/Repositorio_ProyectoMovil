import 'package:flutter/material.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  String? _category;
  final _addressController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar la imagen')),
      );
    }
  }

  Future<String> _saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${const Uuid().v4()}.jpg';
    final savedImage = await imageFile.copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  Future<void> _publishProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final category = _category;
    final address = _addressController.text.trim();

    if (name.isEmpty ||
        desc.isEmpty ||
        price == null ||
        category == null ||
        address.isEmpty ||
        _selectedImage == null) {
      setState(() {
        _errorMessage =
            'Completa todos los campos obligatorios y selecciona una imagen.';
        _isLoading = false;
      });
      return;
    }

    // Obtener sellerId
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');
    if (userEmail == null) {
      setState(() {
        _errorMessage = 'No se pudo identificar al usuario.';
        _isLoading = false;
      });
      return;
    }

    final user = await DatabaseService.getUserByEmail(userEmail);
    if (user == null) {
      setState(() {
        _errorMessage = 'Usuario no encontrado.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Guardar la imagen y obtener su ruta
      final imagePath = await _saveImage(_selectedImage!);

      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: name,
        description: desc,
        price: price,
        imageUrl: imagePath,
        category: category,
        address: address,
        sellerId: user.id.toString(),
      );

      await DatabaseService.insertProduct(product);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto publicado con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error al insertar producto: $e');
      setState(() {
        _errorMessage = 'Error al publicar el producto.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Publicar Producto',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Galería'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_camera),
                            title: const Text('Cámara'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1D4C2),
                  borderRadius: BorderRadius.circular(12),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: Color(0xFF5C3D2E),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Agregar foto',
                            style: TextStyle(color: Color(0xFF5C3D2E)),
                          ),
                          Text(
                            'Toca para seleccionar',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del producto',
                filled: true,
                fillColor: const Color(0xFFE1D4C2).withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descripción',
                filled: true,
                fillColor: const Color(0xFFE1D4C2).withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Precio',
                prefixText: '\$',
                filled: true,
                fillColor: const Color(0xFFE1D4C2).withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              onChanged: (String? value) {
                setState(() {
                  _category = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Categoría',
                filled: true,
                fillColor: const Color(0xFFE1D4C2).withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: ['Ropa', 'Tecnología', 'Hogar', 'Deportes', 'Libros'].map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Dirección',
                prefixIcon: const Icon(
                  Icons.location_on,
                  color: Color(0xFF5C3D2E),
                ),
                filled: true,
                fillColor: const Color(0xFFE1D4C2).withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _publishProduct,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Publicar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3D2E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
