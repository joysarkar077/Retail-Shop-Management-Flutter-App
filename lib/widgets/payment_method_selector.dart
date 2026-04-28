import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedMethod = context.watch<CartProvider>().paymentMethod;
    final setMethod = context.read<CartProvider>().setPaymentMethod;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPill('cash', 'Cash', selectedMethod, setMethod),
        _buildPill('card', 'Card', selectedMethod, setMethod),
        _buildPill('mobile', 'bKash/Nagad', selectedMethod, setMethod),
      ],
    );
  }

  Widget _buildPill(
    String method,
    String label,
    String selectedMethod,
    Function(String) onSelect,
  ) {
    final isSelected = method == selectedMethod;
    return GestureDetector(
      onTap: () => onSelect(method),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[600] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green[800]! : Colors.grey[400]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
