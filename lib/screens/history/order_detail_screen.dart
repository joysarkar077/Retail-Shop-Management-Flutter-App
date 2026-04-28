import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onStatusChanged;

  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  void _voidOrder(BuildContext context) async {
    final reasonController = TextEditingController();
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Void Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to void this order? This will restore stock.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for voiding',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Void Order',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await OrderService.voidOrder(order['_id'], reasonController.text);
        onStatusChanged();
        Navigator.pop(context); // Go back to history
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final canVoid =
        (auth.role == 'superadmin' ||
            auth.role == 'admin' ||
            auth.role == 'owner' ||
            auth.role == 'manager') &&
        order['status'] == 'completed';
    final items = order['items'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(order['invoiceNumber']),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${order['status'].toString().toUpperCase()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: order['status'] == 'voided' ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Items:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ...items.map(
              (item) => ListTile(
                title: Text(item['productName']),
                subtitle: Text(
                  '${item['quantity']} ${item['unit']} x ৳${item['unitPrice']}',
                ),
                trailing: Text('৳ ${item['lineTotal']}'),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Subtotal'),
              trailing: Text('৳ ${order['subtotal']}'),
            ),
            ListTile(
              title: const Text('VAT (5%)'),
              trailing: Text('৳ ${order['taxAmount']}'),
            ),
            ListTile(
              title: const Text('Discount'),
              trailing: Text('৳ ${order['discountAmount']}'),
            ),
            ListTile(
              title: const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                '৳ ${order['totalAmount']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/invoice', extra: {'order': order});
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Reprint Invoice'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (canVoid) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _voidOrder(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Void Order'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
