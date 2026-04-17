import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../auth/register_user_screen.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Owner!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to product list
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not implemented yet')));
              },
              child: const Text('Manage Products'),
            ),
             ElevatedButton(
              onPressed: () {
                // Navigate to low stock
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not implemented yet')));
              },
              child: const Text('Low Stock Alerts'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterUserScreen()));
              },
              child: const Text('Register Staff'),
            )
          ],
        ),
      ),
    );
  }
}
