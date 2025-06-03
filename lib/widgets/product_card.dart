import 'package:flutter/material.dart';
import 'package:proyecto/models/product.dart';
import 'package:proyecto/services/favorite_service.dart';
import 'package:proyecto/services/user_service.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({Key? key, required this.product, this.onFavoriteToggle})
      : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;
  bool loadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final fav = await FavoriteService.isFavoriteProduct(widget.product.id);
    setState(() {
      isFavorite = fav;
    });
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    setState(() {
      loadingFavorite = true;
    });
    final user = UserService.currentUser;
    if (user == null) {
      setState(() {
        loadingFavorite = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes iniciar sesión para agregar a favoritos.')),
      );
      return;
    }
    try {
      await FavoriteService.toggleFavorite(widget.product.id);
      await _loadFavorite();
      if (widget.onFavoriteToggle != null) widget.onFavoriteToggle!();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              isFavorite ? 'Agregado a favoritos' : 'Eliminado de favoritos')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar favoritos.')),
      );
    } finally {
      setState(() {
        loadingFavorite = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: {'productId': widget.product.id},
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
                  child: widget.product.imageUrls.isNotEmpty
                      ? Image.network(
                          widget.product.imageUrls.first,
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
                    child: loadingFavorite
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : const Color(0xFF5C3D2E),
                              size: 20,
                            ),
                            onPressed: () => _toggleFavorite(context),
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
                    widget.product.title,
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
                    '\$${widget.product.price.toStringAsFixed(2)}',
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
                            widget.product.category,
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
