import 'package:flutter/material.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
              title: Text(dummyCategories[index], style: const TextStyle(fontWeight: FontWeight.bold)),
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
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        onPressed: () {
           // Show Add Category dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
