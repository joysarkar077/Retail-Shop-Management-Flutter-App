import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../widgets/cart_item_card.dart';

class POSMainScreen extends StatefulWidget {
  const POSMainScreen({super.key});

  @override
  State<POSMainScreen> createState() => _POSMainScreenState();
}

class _POSMainScreenState extends State<POSMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await ProductService.searchProducts(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _showSuggestions = true;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  void _addToCart(dynamic product) {
    context.read<CartProvider>().addItem(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to cart'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
    _clearSearch();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchResults = [];
      _showSuggestions = false;
    });
  }

  Future<void> _scanFromCamera() async {
    final result = await context.push<String>('/pos-scanner-modal');
    if (result != null && result.isNotEmpty) {
      _handleScannedResult(result);
    }
  }

  Future<void> _scanFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final controller = MobileScannerController();
    final completer = Completer<String?>();

    final subscription = controller.barcodes.listen((capture) {
      if (capture.barcodes.isNotEmpty) {
        final barcode = capture.barcodes.first.rawValue;
        if (!completer.isCompleted) {
          completer.complete(barcode);
        }
      }
    });

    try {
      final success = await controller.analyzeImage(image.path);
      if (!success && !completer.isCompleted) {
        completer.complete(null);
      }

      final barcode = await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );

      if (barcode != null) {
        _handleScannedResult(barcode);
      } else {
        _showError('No QR/Barcode found in the selected image.');
      }
    } catch (e) {
      _showError('Failed to analyze image: $e');
    } finally {
      await subscription.cancel();
      controller.dispose();
    }
  }

  Future<void> _handleScannedResult(String barcode) async {
    _searchController.text = barcode;

    // Automatically search and add if exact match
    setState(() => _isSearching = true);
    try {
      final product = await ProductService.getByBarcode(barcode);
      if (product != null) {
        _addToCart(product);
        HapticFeedback.mediumImpact();
      } else {
        // Fallback to search if not exact barcode match
        final results = await ProductService.searchProducts(barcode);
        if (results.length == 1) {
          _addToCart(results.first);
          HapticFeedback.mediumImpact();
        } else if (results.isNotEmpty) {
          setState(() {
            _searchResults = results;
            _showSuggestions = true;
          });
        } else {
          _showError('Product not found: $barcode');
          HapticFeedback.heavyImpact();
        }
      }
    } catch (e) {
      _showError('Error searching for product.');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Scan Product',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: Colors.green,
                size: 30,
              ),
              title: const Text('Scan with Camera'),
              subtitle: const Text(
                'Use device camera to scan barcode or QR code',
              ),
              onTap: () {
                Navigator.pop(ctx);
                _scanFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Colors.blue,
                size: 30,
              ),
              title: const Text('Upload from Gallery'),
              subtitle: const Text('Select a photo containing a QR code'),
              onTap: () {
                Navigator.pop(ctx);
                _scanFromGallery();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar Area
              Container(
                color: const Color(0xFF2E7D32),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search by Name, SKU or Barcode',
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.green,
                          ),
                          onPressed: _showScanOptions,
                          tooltip: 'Scan QR / Barcode',
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Cart Items List
              Expanded(
                child: cart.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cart is empty',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Search or scan products to add',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          return CartItemCard(item: cart.items[index]);
                        },
                      ),
              ),

              // Checkout Bottom Bar
              if (cart.items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Items: ${cart.itemCount}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Total: ৳ ${cart.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => context.push('/cart'),
                          child: const Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Search Suggestions Overlay
          if (_showSuggestions && _searchResults.isNotEmpty)
            Positioned(
              top: 70, // Below the search bar
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: _searchResults.length > 5
                      ? 5
                      : _searchResults.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    return ListTile(
                      title: Text(
                        product['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'SKU: ${product['sku'] ?? 'N/A'} | Stock: ${product['stock_count']}',
                      ),
                      trailing: Text('৳${product['sellingPrice']}'),
                      onTap: () => _addToCart(product),
                    );
                  },
                ),
              ),
            ),

          if (_isSearching)
            const Positioned(
              top: 80,
              right: 32,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}
