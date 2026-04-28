import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'create_shop_screen.dart';
import 'shop_users_screen.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  List<dynamic> _shops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    try {
      final response = await ApiService.get('${ApiConfig.baseUrl}/shops');
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _shops = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showRenameDialog(Map<String, dynamic> shop) async {
    final controller = TextEditingController(text: shop['name']);
    bool loading = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Rename Shop'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Store Name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          if (controller.text.trim().isEmpty) return;
                          setDialogState(() => loading = true);
                          try {
                            final res = await ApiService.put(
                              '${ApiConfig.baseUrl}/shops/${shop['_id']}',
                              {'name': controller.text.trim()},
                            );
                            if (res.statusCode == 200) {
                              Navigator.pop(ctx);
                              _fetchShops();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to rename'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Network error')),
                            );
                          }
                          if (mounted) setDialogState(() => loading = false);
                        },
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Shops',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo[800],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _shops.length,
              itemBuilder: (context, index) {
                final shop = _shops[index];
                final String shopIdStr = shop['_id'];
                final String uniqueId =
                    'S-${shopIdStr.substring(shopIdStr.length - 6).toUpperCase()}';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo[50],
                      child: Icon(Icons.storefront, color: Colors.indigo[800]),
                    ),
                    title: Text(
                      shop['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'ID: $uniqueId\n${shop['address'] ?? 'No address provided'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showRenameDialog(shop),
                        ),
                        const Icon(Icons.people_alt, color: Colors.grey),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShopUsersScreen(
                            shopId: shop['_id'],
                            shopName: shop['name'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo[800],
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateShopScreen()),
          );
          _fetchShops(); // Refresh the list after coming back
        },
        icon: const Icon(Icons.add),
        label: const Text('New Shop'),
      ),
    );
  }
}
