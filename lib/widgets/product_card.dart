import 'package:flutter/material.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/services/favorite_service.dart'; // Importar el servicio de favoritos
import 'package:proyecto/screens/product_detail_screen.dart'; // Para navegar al detalle

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback?
      onFavoriteToggle; // Callback opcional para notificar cambios en favoritos

  const ProductCard({Key? key, required this.product, this.onFavoriteToggle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener el estado de favorito desde el servicio
    // Nota: Esto asume que FavoriteService tiene un estado global o se actualiza correctamente
    bool isFavorite = FavoriteService.isFavoriteProduct(product.id);

    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de detalle del producto
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: {'productId': product.id},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0E8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(
                          product.imageUrls.first,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: double.infinity,
                              color: const Color(0xFFE1D4C2),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: Color(0xFF5C3D2E),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 120,
                          width: double.infinity,
                          color: const Color(0xFFE1D4C2),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: Color(0xFF5C3D2E),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color:
                            isFavorite ? Colors.red : const Color(0xFF5C3D2E),
                        size: 20,
                      ),
                      onPressed: () async {
                        // Alternar estado de favorito y ejecutar callback
                        await FavoriteService.toggleFavorite(product.id);
                        if (onFavoriteToggle != null) {
                          onFavoriteToggle!();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1810),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2C1810),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1D4C2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.category,
                          size: 12,
                          color: Color(0xFF2C1810),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              color: Color(0xFF2C1810),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
