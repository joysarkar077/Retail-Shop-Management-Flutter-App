import 'package:flutter/material.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: 4, // Mock data
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final dummyCategories = ['Rice', 'Vegetables', 'Fruits', 'Spices'];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                dummyCategories[index],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Tap to edit'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show edit dialog
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        onPressed: () {
          // Show Add Category dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
