import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../auth/register_user_screen.dart';
import '../inventory/product_list_screen.dart';
import '../inventory/low_stock_alerts_screen.dart';

import '../../widgets/sales_summary_widget.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final String uId = user != null
        ? 'U-${user.id.substring(user.id.length - 6).toUpperCase()}'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Owner Dashboard | $uId',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[800]!, Colors.green[500]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 24.0, top: 24.0, right: 24.0, bottom: 8.0),
              child: Text(
                'Branch Operations',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SalesSummaryWidget(),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  children: [
                    _buildActionCard(
                      context,
                      title: 'Sales Analytics',
                      subtitle: 'View revenue and top products',
                      icon: Icons.analytics,
                      color: Colors.indigo,
                      onTap: () => context.push('/analytics'),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Customer Database',
                      subtitle: 'View customers and history',
                      icon: Icons.people,
                      color: Colors.teal,
                      onTap: () => context.push('/customers'),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Coupons & Discounts',
                      subtitle: 'Manage promotional codes',
                      icon: Icons.local_offer,
                      color: Colors.deepOrange,
                      onTap: () => context.push('/coupons'),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Shop Settings',
                      subtitle: 'Update address, phone, manager',
                      icon: Icons.store,
                      color: Colors.brown,
                      onTap: () => context.push('/shop-settings'),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Transaction History',
                      subtitle: 'View and void past orders',
                      icon: Icons.history,
                      color: Colors.purple,
                      onTap: () => context.push('/history'),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Product Catalog',
                      subtitle: 'Manage local inventory',
                      icon: Icons.inventory_2,
                      color: Colors.green,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductListScreen(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Low Stock Alerts',
                      subtitle: 'Check items requiring restock',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LowStockAlertsScreen(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Register Staff',
                      subtitle: 'Add managers or employees',
                      icon: Icons.person_add_alt_1,
                      color: Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterUserScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color[50],
          radius: 30,
          child: Icon(icon, color: color[700], size: 30),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
