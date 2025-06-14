import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../widgets/custom_image_spinner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto/services/notification_service.dart';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
  bool _imageError = false;
  bool _categoryError = false;

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

  // Método para convertir una imagen a base64
  Future<String> _imageFileToBase64(File imageFile) async {
    final compressed = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      quality: 70,
    );
    return base64Encode(compressed ?? await imageFile.readAsBytes());
  }

  // Modificado: Guardar imágenes como base64 en Firestore
  void _saveProduct() async {
    setState(() {
      _imageError = false;
      _categoryError = false;
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_images.isEmpty) {
      setState(() {
        _imageError = true;
      });
      return;
    }
    if (_selectedCategory == null) {
      setState(() {
        _categoryError = true;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      // Convertir imágenes a base64
      final imageBase64List = <String>[];
      for (final img in _images) {
        imageBase64List.add(await _imageFileToBase64(img));
      }
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      final productData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'imageUrls': imageBase64List,
        'category': _selectedCategory,
        'sellerId': user.uid,
        'stock': int.parse(_stockController.text.trim()),
        'createdAt': FieldValue.serverTimestamp(),
      };
      final docRef = await FirebaseFirestore.instance
          .collection('products')
          .add(productData);
      await docRef.collection('comments').add({
        'text': '¡Sé el primero en comentar!',
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'isSystem': true,
      });
      await NotificationService.createNotificationForUser(
        userId: user.uid,
        title: '¡Producto publicado!',
        body:
            'Tu producto "${_titleController.text.trim()}" ha sido publicado exitosamente.',
      );
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto publicado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al publicar producto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Validadores
  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa el título del producto';
    }
    if (value.trim().length < 3) {
      return 'El título debe tener al menos 3 caracteres';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa la descripción del producto';
    }
    if (value.trim().length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa el precio';
    }
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'El precio debe ser un número válido';
    }
    if (price <= 0) {
      return 'El precio debe ser mayor a 0';
    }
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa la cantidad en stock';
    }
    final stock = int.tryParse(value.trim());
    if (stock == null) {
      return 'El stock debe ser un número entero válido';
    }
    if (stock < 0) {
      return 'El stock no puede ser negativo';
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
              if (_imageError)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'Por favor, selecciona al menos una imagen.',
                    style: TextStyle(color: Colors.red, fontSize: 13),
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
                    _categoryError = false;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return null; // No mostrar error aquí, lo mostramos abajo
                  }
                  return null;
                },
                icon:
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF5C3D2E)),
                style: const TextStyle(color: Color(0xFF5C3D2E), fontSize: 16),
              ),
              if (_categoryError)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'Por favor, selecciona una categoría.',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
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
                  ? const Center(child: CustomImageSpinner(size: 40))
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
