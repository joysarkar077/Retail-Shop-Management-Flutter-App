import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../inventory/product_list_screen.dart';
import '../../widgets/sales_summary_widget.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final String uId = user != null
        ? 'U-${user.id.substring(user.id.length - 6).toUpperCase()}'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employee Dashboard | $uId',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
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
            colors: [Colors.green[800]!, Colors.green[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Checkout Station',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SalesSummaryWidget(darkTheme: true),
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
                      title: 'Open POS',
                      subtitle: 'Search & Scan Checkout System',
                      icon: Icons.point_of_sale,
                      color: Colors.green,
                      onTap: () => context.push('/pos-main'),
                    ),
                    _buildActionCard(
                      context,
                      title: 'My Sales History',
                      subtitle: 'View your past transactions',
                      icon: Icons.history,
                      color: Colors.purple,
                      onTap: () => context.push('/history'),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Browse Catalog',
                      subtitle: 'Manually select product',
                      icon: Icons.search,
                      color: Colors.blueGrey,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductListScreen(),
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
