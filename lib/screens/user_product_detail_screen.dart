import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../widgets/custom_image_spinner.dart';

class UserProductDetailScreen extends StatefulWidget {
  final String productId;
  const UserProductDetailScreen({super.key, required this.productId});

  @override
  State<UserProductDetailScreen> createState() =>
      _UserProductDetailScreenState();
}

class _UserProductDetailScreenState extends State<UserProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> categories = [
    'Electrónica',
    'Ropa',
    'Hogar',
    'Deportes',
    'Libros',
    'Mascotas',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProductDetail();
  }

  Future<void> _fetchProductDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _product = Product(
            id: doc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            price: (data['price'] is int)
                ? (data['price'] as int).toDouble()
                : (data['price'] ?? 0.0),
            imageUrls: (data['imageUrls'] as List<dynamic>? ?? [])
                .map((e) => e.toString())
                .toList(),
            category: data['category'] ?? '',
            sellerId: data['sellerId'] ?? '',
            stock: data['stock'] ?? 0,
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _product = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el producto: $e';
        _isLoading = false;
      });
    }
  }

  Future<String> imageToBase64(Uint8List bytes) async {
    return base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detalle del Producto',
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
          if (_product != null) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea:
                      true, // <-- Agregado para evitar cierre inesperado con el teclado
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) {
                    final titleController =
                        TextEditingController(text: _product!.title);
                    final descController =
                        TextEditingController(text: _product!.description);
                    final priceController =
                        TextEditingController(text: _product!.price.toString());
                    final stockController =
                        TextEditingController(text: _product!.stock.toString());
                    final categoryController =
                        TextEditingController(text: _product!.category);
                    final formKey = GlobalKey<FormState>();
                    bool isSaving = false;
                    String? newImageBase64;
                    String? imageError;
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        Future<void> pickImage() async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                              source: ImageSource.gallery, imageQuality: 80);
                          if (picked != null) {
                            final bytes = await picked.readAsBytes();
                            if (bytes.length > 5 * 1024 * 1024) {
                              setModalState(() => imageError =
                                  'La imagen es demasiado grande (máx 5MB)');
                              return;
                            }
                            newImageBase64 =
                                await compute(imageToBase64, bytes);
                            setModalState(() {
                              imageError = null;
                            });
                          }
                        }

                        return Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 24,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 16,
                          ),
                          child: Form(
                            key: formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Editar producto',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: GestureDetector(
                                      onTap: pickImage,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: newImageBase64 != null
                                            ? Image.memory(
                                                base64Decode(newImageBase64!),
                                                height: 120,
                                                width: 120,
                                                fit: BoxFit.cover,
                                              )
                                            : (_product!.imageUrls.isNotEmpty
                                                ? (isBase64Image(_product!
                                                        .imageUrls.first)
                                                    ? Image.memory(
                                                        base64Decode(_product!
                                                            .imageUrls.first),
                                                        height: 120,
                                                        width: 120,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.network(
                                                        _product!
                                                            .imageUrls.first,
                                                        height: 120,
                                                        width: 120,
                                                        fit: BoxFit.cover,
                                                      ))
                                                : Image.asset(
                                                    'assets/images/Logo_PMiniatura.png',
                                                    height: 120,
                                                    width: 120,
                                                    fit: BoxFit.cover,
                                                  )),
                                      ),
                                    ),
                                  ),
                                  if (imageError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(imageError!,
                                          style: const TextStyle(
                                              color: Colors.red)),
                                    ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: titleController,
                                    decoration: const InputDecoration(
                                        labelText: 'Título'),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Campo requerido'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: descController,
                                    decoration: const InputDecoration(
                                        labelText: 'Descripción'),
                                    maxLines: 2,
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Campo requerido'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: priceController,
                                    decoration: const InputDecoration(
                                        labelText: 'Precio'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Campo requerido';
                                      }
                                      final n = double.tryParse(v);
                                      if (n == null || n < 0) {
                                        return 'Precio inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: stockController,
                                    decoration: const InputDecoration(
                                        labelText: 'Stock'),
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Campo requerido';
                                      }
                                      final n = int.tryParse(v);
                                      if (n == null || n < 0) {
                                        return 'Stock inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    value: categories
                                            .contains(categoryController.text)
                                        ? categoryController.text
                                        : null,
                                    decoration: const InputDecoration(
                                        labelText: 'Categoría'),
                                    items: categories.map((cat) {
                                      return DropdownMenuItem<String>(
                                        value: cat,
                                        child: Text(cat),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      categoryController.text = val ?? '';
                                    },
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Campo requerido'
                                        : null,
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF5C3D2E),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: isSaving
                                          ? null
                                          : () async {
                                              if (!formKey.currentState!
                                                  .validate()) return;
                                              setModalState(
                                                  () => isSaving = true);
                                              try {
                                                final updateData = {
                                                  'title': titleController.text
                                                      .trim(),
                                                  'description': descController
                                                      .text
                                                      .trim(),
                                                  'price': double.parse(
                                                      priceController.text
                                                          .trim()),
                                                  'stock': int.parse(
                                                      stockController.text
                                                          .trim()),
                                                  'category': categoryController
                                                      .text
                                                      .trim(),
                                                };
                                                if (newImageBase64 != null) {
                                                  updateData['imageUrls'] = [
                                                    newImageBase64
                                                  ];
                                                }
                                                await FirebaseFirestore.instance
                                                    .collection('products')
                                                    .doc(_product!.id)
                                                    .update(updateData);
                                                await _fetchProductDetail();
                                                if (mounted) {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Producto actualizado')),
                                                  );
                                                }
                                              } catch (e) {
                                                setModalState(
                                                    () => isSaving = false);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Error al actualizar: $e'),
                                                      backgroundColor:
                                                          Colors.red),
                                                );
                                              }
                                            },
                                      child: isSaving
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CustomImageSpinner(
                                                  size: 24,
                                                  color: Colors.white),
                                            )
                                          : const Text('Guardar cambios'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar producto'),
                    content: const Text(
                        '¿Estás seguro de que deseas eliminar este producto? Esta acción no se puede deshacer.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await FirebaseFirestore.instance
                        .collection('products')
                        .doc(_product!.id)
                        .delete();
                    if (mounted) {
                      Navigator.pop(
                          context, true); // Regresa y notifica que se eliminó
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar producto: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CustomImageSpinner(size: 40))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _product == null
                  ? const Center(child: Text('Producto no encontrado.'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1D4C2),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withAlpha((0.08 * 255).toInt()),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: _product!.imageUrls.isNotEmpty
                                    ? Builder(
                                        builder: (context) {
                                          final img = _product!.imageUrls.first;

                                          if (isBase64Image(img)) {
                                            try {
                                              final bytes = base64Decode(img);
                                              if (bytes.lengthInBytes >
                                                  5 * 1024 * 1024) {
                                                throw Exception(
                                                    'Imagen demasiado grande');
                                              }
                                              return Image.memory(
                                                bytes,
                                                height: 240,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    height: 240,
                                                    width: double.infinity,
                                                    color:
                                                        const Color(0xFFE1D4C2),
                                                    child: const Icon(
                                                      Icons
                                                          .image_not_supported_outlined,
                                                      size: 40,
                                                      color: Color(0xFF5C3D2E),
                                                    ),
                                                  );
                                                },
                                              );
                                            } catch (e) {
                                              return Container(
                                                height: 240,
                                                width: double.infinity,
                                                color: const Color(0xFFE1D4C2),
                                                child: const Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  size: 40,
                                                  color: Color(0xFF5C3D2E),
                                                ),
                                              );
                                            }
                                          } else {
                                            return Image.network(
                                              img,
                                              height: 240,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 240,
                                                  width: double.infinity,
                                                  color:
                                                      const Color(0xFFE1D4C2),
                                                  child: const Icon(
                                                    Icons
                                                        .image_not_supported_outlined,
                                                    size: 40,
                                                    color: Color(0xFF5C3D2E),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                      )
                                    : Image.asset(
                                        'assets/images/Logo_PMiniatura.png',
                                        height: 240,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ), // <-- Asegura que este paréntesis y coma cierran el Center correctamente
                            const SizedBox(height: 24),
                            Text(_product!.title,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5C3D2E))),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.category,
                                    color: Color(0xFF5C3D2E), size: 22),
                                const SizedBox(width: 8),
                                Text('Categoría: ${_product!.category}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Descripción',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5C3D2E))),
                            const SizedBox(height: 8),
                            Text(_product!.description,
                                style:
                                    const TextStyle(fontSize: 18, height: 1.5)),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F1E7),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withAlpha((0.04 * 255).toInt()),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Precio',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey)),
                                      Text(
                                        '\$ ${_product!.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF5C3D2E)),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Stock',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey)),
                                      Text(
                                        '${_product!.stock}',
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF5C3D2E)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

// Helper para base64
bool isBase64Image(String s) {
  return (s.startsWith('/9j') || s.startsWith('iVBOR')) && s.length > 100;
}
