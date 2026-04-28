import 'package:flutter/material.dart';

class StockAdjustmentSheet extends StatefulWidget {
  final String productId;
  final String productName;
  final int currentStock;

  const StockAdjustmentSheet({
    super.key,
    required this.productId,
    required this.productName,
    required this.currentStock,
  });

  @override
  State<StockAdjustmentSheet> createState() => _StockAdjustmentSheetState();
}

class _StockAdjustmentSheetState extends State<StockAdjustmentSheet> {
  String _selectedType = 'restock';
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Adjust Stock: ${widget.productName}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Current Stock: ${widget.currentStock}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'restock',
                icon: Icon(Icons.add),
                label: Text('Restock'),
              ),
              ButtonSegment(
                value: 'damage',
                icon: Icon(Icons.remove),
                label: Text('Damage'),
              ),
              ButtonSegment(
                value: 'adjustment',
                icon: Icon(Icons.edit),
                label: Text('Adjust'),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() => _selectedType = newSelection.first);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantity Change (e.g. 50)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Reason / Note',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green[800],
            ),
            onPressed: () {
              Navigator.pop(context, true); // True implies success
            },
            child: const Text(
              'Apply Adjustment',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
