import 'package:flutter/material.dart';

class CartItem {
  final String productId;
  final String productName;
  final String productSku;
  final double unitPrice;
  final String unit;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.unitPrice,
    required this.unit,
    this.quantity = 1,
  });

  double get lineTotal => unitPrice * quantity;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  double _manualDiscountAmount = 0;
  double _discountPercentage = 0;
  String _paymentMethod = 'cash';
  String _customerName = '';
  String _customerPhone = '';
  String _couponCode = '';

  List<CartItem> get items => _items;
  double get discountAmount {
    if (_discountPercentage > 0) {
      return subtotal * (_discountPercentage / 100);
    }
    return _manualDiscountAmount;
  }
  String get paymentMethod => _paymentMethod;
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  String get couponCode => _couponCode;

  double get subtotal => _items.fold(0, (sum, item) => sum + item.lineTotal);
  double get taxAmount => subtotal * 0.05; // 5% VAT
  double get total => subtotal + taxAmount - discountAmount;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  void addItem(Map<String, dynamic> product) {
    final productId = product['_id'];
    final existingIndex = _items.indexWhere((item) => item.productId == productId);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(
        productId: productId,
        productName: product['name'],
        productSku: product['sku'] ?? 'N/A',
        unitPrice: (product['sellingPrice'] as num).toDouble(),
        unit: product['unit'],
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final existingIndex = _items.indexWhere((item) => item.productId == productId);
    if (existingIndex >= 0) {
      if (quantity <= 0) {
        _items.removeAt(existingIndex);
      } else {
        _items[existingIndex].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void setDiscount(double amount) {
    _manualDiscountAmount = amount;
    _discountPercentage = 0; // Clear percentage if manual amount is set
    _couponCode = '';
    notifyListeners();
  }

  void applyCouponDiscount(String code, double percentage) {
    _couponCode = code;
    _discountPercentage = percentage;
    _manualDiscountAmount = 0; // Clear manual amount if coupon applied
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  void setCustomerPhone(String phone) {
    _customerPhone = phone;
    notifyListeners();
  }

  void setCouponCode(String code) {
    _couponCode = code;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _manualDiscountAmount = 0;
    _discountPercentage = 0;
    _paymentMethod = 'cash';
    _customerName = '';
    _customerPhone = '';
    _couponCode = '';
    notifyListeners();
  }
}
