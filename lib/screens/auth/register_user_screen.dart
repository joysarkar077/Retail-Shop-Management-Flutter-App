import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class RegisterUserScreen extends StatefulWidget {
  final String? preselectedShopId;
  const RegisterUserScreen({super.key, this.preselectedShopId});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedRole;
  String? _selectedShopId;
  List<dynamic> _shops = [];
  bool _isLoading = false;
  bool _shopsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    final role = context.read<AuthProvider>().role;
    if (role == 'superadmin' || role == 'admin') {
      try {
        final response = await ApiService.get('${ApiConfig.baseUrl}/shops');
        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              _shops = jsonDecode(response.body);
              // Verify preselectedShopId exists in the fetched shops before assigning to prevent crashes
              if (widget.preselectedShopId != null) {
                final bool exists = _shops.any(
                  (shop) => shop['_id'] == widget.preselectedShopId,
                );
                if (exists) {
                  _selectedShopId = widget.preselectedShopId;
                }
              }
              _shopsLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _shopsLoading = false);
        }
      } catch (e) {
        if (mounted) setState(() => _shopsLoading = false);
      }
    } else {
      if (mounted) setState(() => _shopsLoading = false);
    }
  }

  List<String> _getAllowedRoles() {
    final role = context.read<AuthProvider>().role;
    switch (role) {
      case 'superadmin':
        return ['admin', 'owner', 'manager', 'employee'];
      case 'admin':
        return ['owner', 'manager', 'employee'];
      case 'owner':
        return ['manager', 'employee'];
      case 'manager':
        return ['employee'];
      default:
        return [];
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) return;

    final creatorRole = context.read<AuthProvider>().role;
    // Validate shop selection if creating an owner/manager/employee
    if ((creatorRole == 'superadmin' || creatorRole == 'admin') &&
        ['owner', 'manager', 'employee'].contains(_selectedRole) &&
        _selectedShopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shop first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post(ApiConfig.authRegister, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'role': _selectedRole,
        if (_selectedShopId != null) 'shopId': _selectedShopId,
      });

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account Created Successfully!')),
          );
          Navigator.pop(context); // Go back after success
        }
      } else {
        final err = jsonDecode(response.body)['message'] ?? 'Creation failed';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Network Error')));
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final allowedRoles = _getAllowedRoles();
    final creatorRole = context.read<AuthProvider>().role;
    final requiresShop = [
      'owner',
      'manager',
      'employee',
    ].contains(_selectedRole);
    final showShopSelector =
        (creatorRole == 'superadmin' || creatorRole == 'admin') && requiresShop;

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Staff Account')),
      body:
          _shopsLoading &&
              (creatorRole == 'superadmin' || creatorRole == 'admin')
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || !val.contains('@')
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Temporary Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (val) => val != null && val.length < 8
                          ? 'Min 8 characters'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: allowedRoles
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() {
                        _selectedRole = val;
                        if (!['owner', 'manager', 'employee'].contains(val)) {
                          _selectedShopId = null;
                        }
                      }),
                      validator: (val) =>
                          val == null ? 'Please select a role' : null,
                    ),
                    if (showShopSelector) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedShopId,
                        decoration: const InputDecoration(
                          labelText: 'Assign to Shop',
                          border: OutlineInputBorder(),
                        ),
                        items: _shops
                            .map(
                              (shop) => DropdownMenuItem<String>(
                                value: shop['_id'],
                                child: Text(shop['name']),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedShopId = val),
                        validator: (val) =>
                            val == null ? 'Shop selection required' : null,
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.green[800],
                      ),
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
