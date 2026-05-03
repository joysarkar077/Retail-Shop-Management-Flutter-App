import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../widgets/stock_adjustment_sheet.dart';

class LowStockAlertsScreen extends StatefulWidget {
  const LowStockAlertsScreen({super.key});

  @override
  State<LowStockAlertsScreen> createState() => _LowStockAlertsScreenState();
}

class _LowStockAlertsScreenState extends State<LowStockAlertsScreen> {
  bool _isLoading = true;
  List<dynamic> _lowStockProducts = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLowStockProducts();
  }

  Future<void> _fetchLowStockProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await ProductService.getLowStockAlerts();
      setState(() {
        _lowStockProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Alerts'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchLowStockProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_lowStockProducts.isEmpty) {
      return const Center(
        child: Text(
          'No low stock alerts!',
          style: TextStyle(fontSize: 18, color: Colors.green),
        ),
      );
    }

    return ListView.builder(
      itemCount: _lowStockProducts.length,
      itemBuilder: (context, index) {
        final product = _lowStockProducts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 40,
            ),
            title: Text(
              product['name'] ?? 'Unknown Product',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
                'Stock Level: ${product['stock_count']}   Threshold: ${product['low_stock_threshold']}'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
              ),
              onPressed: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) => StockAdjustmentSheet(
                    productId: product['_id'],
                    productName: product['name'] ?? 'Unknown',
                    currentStock: product['stock_count'] ?? 0,
                  ),
                );

                if (result == true) {
                  _fetchLowStockProducts(); // Refresh list after adjustment
                }
              },
              child: const Text(
                'Adjust',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
