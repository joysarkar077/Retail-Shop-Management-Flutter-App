import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cart_item_card.dart';
import '../../widgets/payment_method_selector.dart';
import '../../services/order_service.dart';
import '../../services/customer_service.dart';
import '../../services/coupon_service.dart';

class POSCartScreen extends StatefulWidget {
  const POSCartScreen({super.key});

  @override
  State<POSCartScreen> createState() => _POSCartScreenState();
}

class _POSCartScreenState extends State<POSCartScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();
  bool _isProcessing = false;
  bool _isSearchingPhone = false;
  bool _isApplyingCoupon = false;

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartProvider>();
    _customerNameController.text = cart.customerName;
    _customerPhoneController.text = cart.customerPhone;
    _couponController.text = cart.couponCode;
    if (cart.discountAmount > 0 && cart.couponCode.isEmpty) {
      _discountController.text = cart.discountAmount.toString();
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _discountController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _searchCustomer(String phone) async {
    if (phone.isEmpty) return;
    setState(() => _isSearchingPhone = true);
    final customer = await CustomerService.searchByPhone(phone);
    if (mounted) {
      setState(() => _isSearchingPhone = false);
      if (customer != null) {
        _customerNameController.text = customer['name'];
        context.read<CartProvider>().setCustomerName(customer['name']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Found customer: ${customer['name']}')),
        );
      }
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isApplyingCoupon = true);
    try {
      final coupon = await CouponService.applyCoupon(code);
      if (mounted && coupon != null) {
        context.read<CartProvider>().applyCouponDiscount(
          coupon['code'],
          (coupon['discountPercentage'] as num).toDouble(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Coupon applied: ${coupon['discountPercentage']}% off',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplyingCoupon = false);
    }
  }

  void _completeCheckout() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final itemsData = cart.items
          .map(
            (item) => {'productId': item.productId, 'quantity': item.quantity},
          )
          .toList();

      final orderData = {
        'items': itemsData,
        'paymentMethod': cart.paymentMethod,
        'customerName': _customerNameController.text.trim().isEmpty
            ? 'Walk-in Customer'
            : _customerNameController.text.trim(),
        'customerPhone': _customerPhoneController.text.trim(),
        'discountAmount': cart.discountAmount,
      };

      final response = await OrderService.createOrder(orderData);

      cart.clearCart();
      if (mounted) {
        context.pushReplacement('/invoice', extra: response);
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Checkout Failed'),
          content: Text(e.toString().replaceAll('Exception: ', '')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.read<AuthProvider>();
    final canEditDiscount =
        auth.role == 'superadmin' ||
        auth.role == 'admin' ||
        auth.role == 'owner' ||
        auth.role == 'manager';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Cart'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Chip(
                label: Text('${cart.itemCount} items', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Cart is empty',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      return CartItemCard(item: cart.items[index]);
                    },
                  ),
                ),
                // Checkout Panel
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _customerPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Customer Phone',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          suffixIcon: _isSearchingPhone
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () => _searchCustomer(
                                    _customerPhoneController.text.trim(),
                                  ),
                                ),
                        ),
                        onChanged: (val) {
                          context.read<CartProvider>().setCustomerPhone(val);
                          if (val.length >= 10) _searchCustomer(val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name (Optional)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) =>
                            context.read<CartProvider>().setCustomerName(val),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              decoration: const InputDecoration(
                                labelText: 'Coupon Code',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isApplyingCoupon ? null : _applyCoupon,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isApplyingCoupon
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Apply'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '৳ ${cart.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'VAT (5%):',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '৳ ${cart.taxAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Discount:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          canEditDiscount
                              ? SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: _discountController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      prefixText: '৳ ',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 8,
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val) {
                                      final amount = double.tryParse(val) ?? 0;
                                      context.read<CartProvider>().setDiscount(
                                        amount,
                                      );
                                    },
                                  ),
                                )
                              : Text(
                                  '৳ ${cart.discountAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '৳ ${cart.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const PaymentMethodSelector(),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isProcessing ? null : _completeCheckout,
                          child: _isProcessing
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Complete Checkout ✓',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
