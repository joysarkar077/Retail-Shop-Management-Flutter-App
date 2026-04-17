import 'package:flutter/material.dart';
import '../../widgets/stock_adjustment_sheet.dart';

class LowStockAlertsScreen extends StatelessWidget {
  const LowStockAlertsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Alerts'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: 5, // Mock data
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 40),
              title: Text('Product $index Name', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Stock Level: 2   Threshold: 10'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => StockAdjustmentSheet(
                      productId: 'prod_$index',
                      productName: 'Product $index Name',
                      currentStock: 2,
                    ),
                  );
                },
                child: const Text('Adjust', style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),
    );
  }
}
