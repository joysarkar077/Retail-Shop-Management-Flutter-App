import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:go_router/go_router.dart';
import '../../utils/pdf_generator.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const InvoicePreviewScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final invoiceNumber = orderData['order']['invoiceNumber'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #$invoiceNumber'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/employee'), // Navigate back to scanner
        ),
      ),
      body: PdfPreview(
        build: (format) => PdfGenerator.generateInvoicePdf(orderData),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final pdfBytes = await PdfGenerator.generateInvoicePdf(orderData);
          await Printing.layoutPdf(
            onLayout: (format) async => pdfBytes,
            name: 'Invoice_$invoiceNumber.pdf',
          );
        },
        backgroundColor: Colors.indigo[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.print),
        label: const Text('Print / Share'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton.icon(
            onPressed: () => context.go('/employee'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('New Customer'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green[800],
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }
}
