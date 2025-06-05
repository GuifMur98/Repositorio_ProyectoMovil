import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/product.dart';
import '../services/product_service.dart';
import '../services/user_service.dart';
import '../config/database.dart';
import 'package:mongo_dart/mongo_dart.dart' as mdb;

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<String> _categories = [
    'Electrónica',
    'Ropa',
    'Hogar',
    'Deportes',
    'Libros',
    'Mascotas',
  ];
  String? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // Método para seleccionar imágenes
  Future<void> _pickImages() async {
    // Mostrar un diálogo para elegir entre cámara o galería
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Row(
                    children: [
                      Icon(Icons.camera_alt, color: Color(0xFF5C3D2E)),
                      SizedBox(width: 8),
                      Text('Tomar foto'),
                    ],
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  child: const Row(
                    children: [
                      Icon(Icons.photo_library, color: Color(0xFF5C3D2E)),
                      SizedBox(width: 8),
                      Text('Seleccionar de galería'),
                    ],
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      if (source == ImageSource.camera) {
        // Tomar una foto con la cámara
        final XFile? photo = await _picker.pickImage(
          source: source,
          imageQuality: 80,
        );
        if (photo != null) {
          setState(() {
            _images.add(File(photo.path));
          });
        }
      } else {
        // Seleccionar múltiples imágenes de la galería
        final List<XFile> pickedFiles = await _picker.pickMultiImage(
          imageQuality: 80,
        );
        if (pickedFiles.isNotEmpty) {
          setState(() {
            _images.addAll(
              pickedFiles.map((pickedFile) => File(pickedFile.path)).toList(),
            );
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona al menos una imagen.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que se haya seleccionado una categoría
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una categoría.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: 1. Subir imágenes a Cloudinary
    List<String> imageUrls = [];

    final newProduct = Product(
      id: '', // MongoDB generará el ID automáticamente
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      imageUrls: imageUrls,
      category: _selectedCategory!,
      sellerId: UserService.currentUser?.id ?? 'unknown',
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
    );

    // 3. Guardar en MongoDB
    final insertedProductId = await ProductService.createProduct(newProduct);

    setState(() {
      _isLoading = false;
    });

    if (insertedProductId != null) {
      // Agregar el ID del producto publicado al usuario
      final userId = UserService.currentUser?.id;
      if (userId != null) {
        await DatabaseConfig.users.updateOne(
          mdb.where.id(mdb.ObjectId.fromHexString(userId)),
          mdb.modify.push('publishedProducts', insertedProductId),
        );
      }
      // Mostrar mensaje de éxito y navegar al Home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto publicado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Mostrar mensaje de error al guardar en BD
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al publicar producto. Inténtalo de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Validadores
  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa el título del producto';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa la descripción del producto';
    }
    if (value.length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa el precio';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Por favor, ingresa un precio válido';
    }
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa la cantidad en stock';
    }
    final stock = int.tryParse(value);
    if (stock == null || stock < 0) {
      return 'Por favor, ingresa una cantidad válida';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 2, // Índice para la pestaña de publicar
      onNavigationTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/favorites');
            break;
          case 2:
            // Ya estamos en publicar
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/cart');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
      appBar: AppBar(
        title: const Text('Publicar Producto',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5C3D2E),
        iconTheme: const IconThemeData(
            color: Colors
                .white), // Color de los iconos del AppBar (como el botón de atrás)
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección para subir imágenes
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0E8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE1D4C2)),
                  ),
                  child: _images.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt,
                                size: 50, color: Color(0xFF5C3D2E)),
                            const SizedBox(height: 8),
                            const Text('Toca para seleccionar imágenes',
                                style: TextStyle(
                                    color: Color(0xFF5C3D2E),
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(
                              'Cámara o galería',
                              style: TextStyle(
                                color: Color(0xFF5C3D2E).withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _images[index],
                                      width: 100,
                                      height: 130,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                  alignment: _images.isEmpty ? Alignment.center : null,
                ),
              ),
              const SizedBox(
                  height: 24.0), // Aumentar espacio después de las imágenes

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    // Estilo cuando está enfocado
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF5C3D2E), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Estilo normal
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  labelStyle: const TextStyle(
                      color: Color(0xFF5C3D2E)), // Color del label
                ),
                validator: _validateTitle,
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF5C3D2E), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  labelStyle: const TextStyle(color: Color(0xFF5C3D2E)),
                ),
                maxLines: 3,
                validator: _validateDescription,
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF5C3D2E), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  labelStyle: const TextStyle(color: Color(0xFF5C3D2E)),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: _validatePrice,
              ),
              const SizedBox(height: 16.0),

              // Campo de Categoría con Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF5C3D2E), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  labelStyle: const TextStyle(color: Color(0xFF5C3D2E)),
                ),
                hint: const Text('Selecciona una categoría',
                    style:
                        TextStyle(color: Colors.grey)), // Hint con color gris
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category,
                        style: const TextStyle(
                            color: Color(0xFF5C3D2E))), // Texto del item marrón
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona una categoría';
                  }
                  return null;
                },
                // Estilo del ícono del dropdown
                icon:
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF5C3D2E)),
                // Estilo del texto seleccionado
                style: const TextStyle(color: Color(0xFF5C3D2E), fontSize: 16),
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF5C3D2E), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  labelStyle: const TextStyle(color: Color(0xFF5C3D2E)),
                ),
                keyboardType: TextInputType.number,
                validator: _validateStock,
              ),
              const SizedBox(height: 24.0),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProduct,
                      child: const Text('Publicar Producto'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor:
                            const Color(0xFF5C3D2E), // Color de fondo del botón
                        foregroundColor:
                            Colors.white, // Color del texto del botón
                        elevation: 2,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
