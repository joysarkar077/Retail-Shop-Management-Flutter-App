import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../auth/register_user_screen.dart';

class ShopUsersScreen extends StatefulWidget {
  final String shopId;
  final String shopName;

  const ShopUsersScreen({Key? key, required this.shopId, required this.shopName}) : super(key: key);

  @override
  State<ShopUsersScreen> createState() => _ShopUsersScreenState();
}

class _ShopUsersScreenState extends State<ShopUsersScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopUsers();
  }

  Future<void> _fetchShopUsers() async {
    try {
      final response = await ApiService.get('${ApiConfig.baseUrl}/auth/shop/${widget.shopId}/users');
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _users = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.shopName} Staff | S-${widget.shopId.substring(widget.shopId.length - 6).toUpperCase()}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Text(user['name'][0].toUpperCase()),
                  ),
                  title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ID: U-${user['_id'].toString().substring(user['_id'].toString().length - 6).toUpperCase()}\n${user['email']}'),
                  trailing: Chip(
                    label: Text(user['role'].toUpperCase(), style: const TextStyle(fontSize: 10)),
                    backgroundColor: Colors.green[50],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo[800],
        foregroundColor: Colors.white,
        onPressed: () async {
          // Open RegisterUserScreen pre-configured for THIS shop
          await Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (_) => RegisterUserScreen(preselectedShopId: widget.shopId),
            )
          );
          _fetchShopUsers(); // Refresh after adding staff
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
      ),
    );
  }
}
