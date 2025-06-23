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
  List<Purchase> _filteredPurchases = [];
  bool _isLoading = false;
  bool _showAdvancedFilters = false;

  // Filtros
  String _searchTitle = '';
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;

  // Controllers para limpiar los campos de filtro
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // FocusNode para la barra de búsqueda
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchPurchaseHistory();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
        purchases = purchaseList
            .where((json) => json is Map<String, dynamic> || json is Map)
            .map((json) =>
                Purchase.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
        purchases.sort((a, b) => b.date.compareTo(a.date));
      }
      setState(() {
        _purchases = purchases;
        _filteredPurchases = purchases;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al obtener historial: $e');
      setState(() {
        _purchases = [];
        _filteredPurchases = [];
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredPurchases = _purchases.where((purchase) {
        // Filtrar por título
        final matchesTitle = _searchTitle.isEmpty ||
            purchase.products.any((p) => (p['title'] as String)
                .toLowerCase()
                .contains(_searchTitle.toLowerCase()));
        // Filtrar por fecha
        final matchesStartDate =
            _startDate == null || !purchase.date.isBefore(_startDate!);
        final matchesEndDate =
            _endDate == null || !purchase.date.isAfter(_endDate!);
        // Filtrar por monto
        final matchesMin = _minAmount == null || purchase.total >= _minAmount!;
        final matchesMax = _maxAmount == null || purchase.total <= _maxAmount!;
        return matchesTitle &&
            matchesStartDate &&
            matchesEndDate &&
            matchesMin &&
            matchesMax;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate =
        isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _applyFilters();
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
        shape: const Border(
          bottom: BorderSide(color: Colors.transparent, width: 0),
        ),
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
          : GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      color: const Color(
                          0xFFD7CCC8), // Marrón claro, buen contraste
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    focusNode: _searchFocusNode,
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                      labelText: 'Buscar por título',
                                      labelStyle: const TextStyle(
                                          color: Color(0xFF5C3D2E)),
                                      floatingLabelStyle: const TextStyle(
                                          color: Color(0xFF5C3D2E)),
                                      prefixIcon: const Icon(Icons.search,
                                          color: Color(0xFF5C3D2E)),
                                      filled: true,
                                      fillColor: Color(0xFFF5F0E8), // beige
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF5C3D2E), width: 2),
                                      ),
                                      hintText: null, // Sin hint
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                    ),
                                    style: const TextStyle(
                                        color: Color(0xFF5C3D2E)),
                                    onChanged: (value) {
                                      _searchTitle = value;
                                      _applyFilters();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: _showAdvancedFilters
                                      ? 'Ocultar filtros avanzados'
                                      : 'Mostrar filtros avanzados',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(24),
                                      onTap: () {
                                        setState(() {
                                          _showAdvancedFilters =
                                              !_showAdvancedFilters;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF5C3D2E),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                            _showAdvancedFilters
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: 'Limpiar filtros',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(24),
                                      onTap: () {
                                        setState(() {
                                          _searchTitle = '';
                                          _startDate = null;
                                          _endDate = null;
                                          _minAmount = null;
                                          _maxAmount = null;
                                          _titleController.clear();
                                          _minAmountController.clear();
                                          _maxAmountController.clear();
                                          _startDateController.clear();
                                          _endDateController.clear();
                                        });
                                        _applyFilters();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF5C3D2E),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: const Icon(Icons.refresh,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),
                              crossFadeState: _showAdvancedFilters
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            await _selectDate(context, true);
                                            if (_startDate != null) {
                                              _startDateController.text =
                                                  '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}';
                                            } else {
                                              _startDateController.clear();
                                            }
                                          },
                                          child: AbsorbPointer(
                                            child: TextField(
                                              controller: _startDateController,
                                              decoration: InputDecoration(
                                                labelText: 'Desde',
                                                labelStyle: const TextStyle(
                                                    color: Color(0xFF5C3D2E)),
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                        color:
                                                            Color(0xFF5C3D2E)),
                                                prefixIcon: const Icon(
                                                    Icons.date_range,
                                                    color: Color(0xFF5C3D2E)),
                                                filled: true,
                                                fillColor: Color(0xFFF5F0E8),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF5C3D2E),
                                                      width: 2),
                                                ),
                                                hintText: null,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 14),
                                                suffixIcon: _startDate != null
                                                    ? IconButton(
                                                        icon: const Icon(
                                                            Icons.close,
                                                            color: Color(
                                                                0xFF5C3D2E)),
                                                        onPressed: () {
                                                          setState(() {
                                                            _startDate = null;
                                                            _startDateController
                                                                .clear();
                                                          });
                                                          _applyFilters();
                                                        },
                                                      )
                                                    : null,
                                              ),
                                              style: const TextStyle(
                                                  color: Color(0xFF5C3D2E)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            await _selectDate(context, false);
                                            if (_endDate != null) {
                                              _endDateController.text =
                                                  '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
                                            } else {
                                              _endDateController.clear();
                                            }
                                          },
                                          child: AbsorbPointer(
                                            child: TextField(
                                              controller: _endDateController,
                                              decoration: InputDecoration(
                                                labelText: 'Hasta',
                                                labelStyle: const TextStyle(
                                                    color: Color(0xFF5C3D2E)),
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                        color:
                                                            Color(0xFF5C3D2E)),
                                                prefixIcon: const Icon(
                                                    Icons.date_range,
                                                    color: Color(0xFF5C3D2E)),
                                                filled: true,
                                                fillColor: Color(0xFFF5F0E8),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                      color: Color(0xFF5C3D2E),
                                                      width: 2),
                                                ),
                                                hintText: null,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 14),
                                                suffixIcon: _endDate != null
                                                    ? IconButton(
                                                        icon: const Icon(
                                                            Icons.close,
                                                            color: Color(
                                                                0xFF5C3D2E)),
                                                        onPressed: () {
                                                          setState(() {
                                                            _endDate = null;
                                                            _endDateController
                                                                .clear();
                                                          });
                                                          _applyFilters();
                                                        },
                                                      )
                                                    : null,
                                              ),
                                              style: const TextStyle(
                                                  color: Color(0xFF5C3D2E)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _minAmountController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Monto mínimo',
                                            labelStyle: const TextStyle(
                                                color: Color(0xFF5C3D2E)),
                                            floatingLabelStyle: const TextStyle(
                                                color: Color(0xFF5C3D2E)),
                                            prefixIcon: const Icon(
                                                Icons.attach_money,
                                                color: Color(0xFF5C3D2E)),
                                            filled: true,
                                            fillColor: Color(0xFFF5F0E8),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFF5C3D2E),
                                                  width: 2),
                                            ),
                                            hintText: null,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14),
                                          ),
                                          style: const TextStyle(
                                              color: Color(0xFF5C3D2E)),
                                          onChanged: (value) {
                                            _minAmount = double.tryParse(value);
                                            _applyFilters();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _maxAmountController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Monto máximo',
                                            labelStyle: const TextStyle(
                                                color: Color(0xFF5C3D2E)),
                                            floatingLabelStyle: const TextStyle(
                                                color: Color(0xFF5C3D2E)),
                                            prefixIcon: const Icon(
                                                Icons.attach_money,
                                                color: Color(0xFF5C3D2E)),
                                            filled: true,
                                            fillColor: Color(0xFFF5F0E8),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFF5C3D2E),
                                                  width: 2),
                                            ),
                                            hintText: null,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14),
                                          ),
                                          style: const TextStyle(
                                              color: Color(0xFF5C3D2E)),
                                          onChanged: (value) {
                                            _maxAmount = double.tryParse(value);
                                            _applyFilters();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              secondChild: const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _filteredPurchases.isEmpty
                        ? const Center(
                            child: Text('No se encontraron compras.'))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final double maxContentWidth = 700;
                              final double horizontalPadding = constraints
                                          .maxWidth >
                                      maxContentWidth
                                  ? (constraints.maxWidth - maxContentWidth) / 2
                                  : 0.0;
                              return ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                    horizontalPadding + 16,
                                    16,
                                    horizontalPadding + 16,
                                    16),
                                itemCount: _filteredPurchases.length,
                                itemBuilder: (context, index) {
                                  final compra = _filteredPurchases[index];
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
