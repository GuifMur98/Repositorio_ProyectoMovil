import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/purchase.dart';
import '../widgets/custom_image_spinner.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  List<Purchase> _purchases = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPurchaseHistory();
  }

  Future<void> _fetchPurchaseHistory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = userDoc.data();
      List<Purchase> purchases = [];
      if (data != null && data['purchaseHistory'] != null) {
        final purchaseList = data['purchaseHistory'] as List<dynamic>;
        // Debug: imprime la estructura de cada compra
        for (var i = 0; i < purchaseList.length; i++) {
          print('purchaseHistory[$i]: ' + purchaseList[i].toString());
        }
        purchases = purchaseList
            .where((json) => json is Map<String, dynamic> || json is Map)
            .map((json) =>
                Purchase.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
        purchases.sort((a, b) => b.date.compareTo(a.date));
      }
      setState(() {
        _purchases = purchases;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al obtener historial: ${e.toString()}');
      setState(() {
        _purchases = [];
        _isLoading = false;
      });
    }
  }

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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CustomImageSpinner(size: 40))
          : _purchases.isEmpty
              ? const Center(child: Text('No has realizado compras.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _purchases.length,
                  itemBuilder: (context, index) {
                    final compra = _purchases[index];
                    final productos = compra.products
                        .map((e) => e['title'] as String)
                        .join(', ');
                    final total = compra.total;
                    final fecha = compra.date;
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
