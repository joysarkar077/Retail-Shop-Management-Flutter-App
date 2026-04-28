import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/stock_adjustment_sheet.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2,
                size: 80,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sample Product Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'SKU: PRD-001 | Barcode: 123456789012',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Stock', '45 pcs', Colors.green),
                _buildStatCard('Price', '৳ 120', Colors.blue),
                if ([
                  'superadmin',
                  'admin',
                  'owner',
                ].contains(Provider.of<AuthProvider>(context).role))
                  _buildStatCard('Cost', '৳ 90', Colors.orange),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Stock History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.add_circle, color: Colors.green),
              title: Text('Restock'),
              subtitle: Text('Added 50 pcs - "New shipment"'),
              trailing: Text('Yesterday'),
            ),
            const ListTile(
              leading: Icon(Icons.remove_circle, color: Colors.red),
              title: Text('Damage'),
              subtitle: Text('Removed 5 pcs - "Water damage"'),
              trailing: Text('3 days ago'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[800],
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const StockAdjustmentSheet(
              productId: 'PRD-001',
              productName: 'Sample Product Name',
              currentStock: 45,
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('Adjust Stock'),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: color[800], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, color: color[900])),
        ],
      ),
    );
  }
}
