import 'dart:io';
import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String address;
  final String sellerId;

  // Para la base de datos local, id puede ser int (autoincremental)
  int? dbId;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.address,
    required this.sellerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'address': address,
      'sellerId': sellerId,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      sellerId: map['sellerId']?.toString() ?? '',
    );
  }

  Widget getImageWidget() {
    if (imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFFE1D4C2),
        child: const Center(
          child: Icon(
            Icons.add_photo_alternate,
            size: 50,
            color: Color(0xFF5C3D2E),
          ),
        ),
      );
    }

    // Si la URL comienza con /data, es una imagen local
    if (imageUrl.startsWith('/data')) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFE1D4C2),
            child: const Center(
              child: Icon(
                Icons.add_photo_alternate,
                size: 50,
                color: Color(0xFF5C3D2E),
              ),
            ),
          );
        },
      );
    }

    // Si no es una imagen local, asumimos que es una URL de red
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFE1D4C2),
          child: const Center(
            child: Icon(
              Icons.add_photo_alternate,
              size: 50,
              color: Color(0xFF5C3D2E),
            ),
          ),
        );
      },
    );
  }
}
