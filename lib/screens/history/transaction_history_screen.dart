import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import 'order_detail_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _statusFilter = 'completed';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().user;
      final isEmployee = user?.role == 'employee';
      final orders = isEmployee
          ? await OrderService.getMyOrders(status: _statusFilter)
          : await OrderService.getOrders(status: _statusFilter);
      
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      // Handle error
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                RadioListTile(
                  title: const Text('All'),
                  value: '',
                  groupValue: _statusFilter,
                  onChanged: (val) {
                    setStateSB(() => _statusFilter = val.toString());
                  },
                ),
                RadioListTile(
                  title: const Text('Completed'),
                  value: 'completed',
                  groupValue: _statusFilter,
                  onChanged: (val) {
                    setStateSB(() => _statusFilter = val.toString());
                  },
                ),
                RadioListTile(
                  title: const Text('Voided'),
                  value: 'voided',
                  groupValue: _statusFilter,
                  onChanged: (val) {
                    setStateSB(() => _statusFilter = val.toString());
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _fetchOrders();
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(child: Text('No transactions found.'))
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final bool isVoided = order['status'] == 'voided';
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      order['invoiceNumber'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${order['customerName']} • ${DateTime.parse(order['transactionDate']).toLocal().toString().split('.')[0]}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '৳ ${order['totalAmount']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          isVoided ? 'VOIDED' : 'COMPLETED',
                          style: TextStyle(
                            color: isVoided ? Colors.red : Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(
                            order: order,
                            onStatusChanged: _fetchOrders,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
