import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class AddEditProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product; // If null, we are creating

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockCountController = TextEditingController();
  final _thresholdController = TextEditingController();

  String? _selectedUnit;
  String? _selectedShopId;

  List<dynamic> _shops = [];
  bool _isLoading = false;
  bool _isFetchingShops = false;

  final List<String> _unitOptions = [
    'kg',
    'g',
    'liter',
    'ml',
    'piece',
    'packet',
    'box',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'] ?? '';
      _skuController.text = widget.product!['sku'] ?? '';
      _barcodeController.text = widget.product!['barcode'] ?? '';
      _costPriceController.text =
          widget.product!['costPrice']?.toString() ?? '';
      _sellingPriceController.text =
          widget.product!['sellingPrice']?.toString() ?? '';
      _stockCountController.text =
          widget.product!['stock_count']?.toString() ?? '';
      _thresholdController.text =
          widget.product!['low_stock_threshold']?.toString() ?? '';

      if (_unitOptions.contains(widget.product!['unit'])) {
        _selectedUnit = widget.product!['unit'];
      }

      // If editing and we already have a shop explicitly
      _selectedShopId = widget.product!['shopId'];
    }

    _fetchContextData();
  }

  Future<void> _fetchContextData() async {
    final role = context.read<AuthProvider>().role;
    if (role == 'superadmin' || role == 'admin') {
      setState(() => _isFetchingShops = true);
      try {
        final response = await ApiService.get('${ApiConfig.baseUrl}/shops');
        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              _shops = jsonDecode(response.body);

              // Validate if editing and existing shop is in the list
              if (_selectedShopId != null &&
                  !_shops.any((s) => s['_id'] == _selectedShopId)) {
                _selectedShopId = null;
              }
            });
          }
        }
      } catch (e) {
        // ignore
      }
      if (mounted) setState(() => _isFetchingShops = false);
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate() || _selectedUnit == null) return;

    final role = context.read<AuthProvider>().role;
    if ((role == 'superadmin' || role == 'admin') && _selectedShopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a branch explicitly.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final payload = {
      'name': _nameController.text.trim(),
      'sku': _skuController.text.trim(),
      'barcode': _barcodeController.text.trim(),
      'unit': _selectedUnit,
      'sellingPrice': double.tryParse(_sellingPriceController.text) ?? 0,
      'stock_count': int.tryParse(_stockCountController.text) ?? 0,
      'low_stock_threshold': int.tryParse(_thresholdController.text) ?? 5,
    };

    // Cost Price inclusion based on role
    if (role == 'superadmin' || role == 'admin' || role == 'owner') {
      payload['costPrice'] = double.tryParse(_costPriceController.text) ?? 0;
    }

    if ((role == 'superadmin' || role == 'admin') && _selectedShopId != null) {
      payload['shopId'] = _selectedShopId;
    }

    try {
      final isUpdating = widget.product != null;
      final response = isUpdating
          ? await ApiService.put(
              '${ApiConfig.baseUrl}/products/${widget.product!['_id']}',
              payload,
            )
          : await ApiService.post('${ApiConfig.baseUrl}/products', payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isUpdating ? 'Product Updated' : 'Product Created Successfully',
              ),
            ),
          );
          Navigator.pop(context, true); // true indicates successful change
        }
      } else {
        final err = jsonDecode(response.body)['message'] ?? 'Failed operation';
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err)));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Network Error')));
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthProvider>().role;
    final isGlobalAdmin = role == 'superadmin' || role == 'admin';
    final canSeeCostPrice =
        role == 'superadmin' || role == 'admin' || role == 'owner';
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modify Product' : 'Add New Product'),
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
      ),
      body: _isFetchingShops
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (isGlobalAdmin) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _selectedShopId,
                        decoration: const InputDecoration(
                          labelText: 'Store Assignment *',
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
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _skuController,
                            decoration: const InputDecoration(
                              labelText: 'SKU (Optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit *',
                              border: OutlineInputBorder(),
                            ),
                            items: _unitOptions
                                .map(
                                  (u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedUnit = val),
                            validator: (val) => val == null ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      'Pricing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (canSeeCostPrice) ...[
                          Expanded(
                            child: TextFormField(
                              controller: _costPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Cost Price',
                                border: OutlineInputBorder(),
                                prefixText: '৳',
                              ),
                              validator: (val) =>
                                  val!.isNotEmpty &&
                                      double.tryParse(val) == null
                                  ? 'Invalid Number'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: TextFormField(
                            controller: _sellingPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Selling Price *',
                              border: OutlineInputBorder(),
                              prefixText: '৳',
                            ),
                            validator: (val) =>
                                val == null ||
                                    val.isEmpty ||
                                    double.tryParse(val) == null
                                ? 'Invalid Number'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      'Inventory Count',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockCountController,
                            enabled:
                                !isEditing, // Typically you adjust stock via Stock Log, not directly editing. But for creation it's fine.
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: isEditing
                                  ? 'Current Stock (Use POS to adjust)'
                                  : 'Initial Stock Count *',
                              border: const OutlineInputBorder(),
                              filled: isEditing,
                            ),
                            validator: (val) =>
                                !isEditing &&
                                    (val == null ||
                                        val.isEmpty ||
                                        int.tryParse(val) == null)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _thresholdController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Low Stock Alert Threshold',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) =>
                                val!.isNotEmpty && int.tryParse(val) == null
                                ? 'Invalid Number'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.teal[800],
                      ),
                      onPressed: _isLoading ? null : _submitProduct,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditing ? 'Save Changes' : 'Create Product',
                              style: const TextStyle(
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
