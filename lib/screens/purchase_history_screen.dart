import 'package:flutter/material.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  // Datos de ejemplo para el historial de compras
  final List<Map<String, dynamic>> _purchases = [
    {
      'id': '1',
      'products': [
        {'title': 'Camiseta Básica'},
        {'title': 'Pantalón Vaquero'},
      ],
      'total': 59.98,
      'date': '2024-03-15',
    },
    {
      'id': '2',
      'products': [
        {'title': 'Zapatillas Deportivas'},
      ],
      'total': 79.99,
      'date': '2024-03-10',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Compras',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: _purchases.isEmpty
          ? const Center(child: Text('No has realizado compras.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _purchases.length,
              itemBuilder: (context, index) {
                final compra = _purchases[index];
                final productos = (compra['products'] as List)
                    .map((e) => e['title'] as String)
                    .join(', ');
                final total = compra['total'] as double;
                final fecha = DateTime.parse(compra['date'] as String);
                final fechaFormateada =
                    '${fecha.day}/${fecha.month}/${fecha.year}';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              color: Color(0xFF5C3D2E),
                              size: 24,
                            ),
                            Text(
                              'Compra del $fechaFormateada',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C3D2E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          productos,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C3D2E),
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C3D2E),
                              ),
                            ),
                          ],
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
