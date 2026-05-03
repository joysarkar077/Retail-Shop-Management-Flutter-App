import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/shop_service.dart';

class PdfGenerator {
  static Future<Uint8List> generateInvoicePdf(
    Map<String, dynamic> orderData,
  ) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.courierPrimeRegular();
    final fontBold = await PdfGoogleFonts.courierPrimeBold();

    final order = orderData['order'];
    final items = order['items'] as List<dynamic>;

    // Try to fetch shop details for header
    Map<String, dynamic>? shopDetails;
    try {
      shopDetails = await ShopService.getShopDetails(order['shopId']);
    } catch (e) {
      print('Failed to get shop details: $e');
    }

    final shopName = shopDetails?['name']?.toUpperCase() ?? 'STORE NAME';
    final shopPhone = shopDetails?['phone'] ?? '(888) 888 - 8888';
    final shopManager =
        shopDetails?['managerName']?.toUpperCase() ?? 'JOHN DOE';
    final shopAddress =
        shopDetails?['address']?.toUpperCase() ??
        '123 RETAIL AVE\nCITY, STATE 12345';

    // Simulated values for layout
    final stNum = order['shopId'].toString().substring(18).toUpperCase();
    final opNum = order['staffId'].toString().substring(18).toUpperCase();
    final trNum = order['invoiceNumber'].substring(0, 4);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Header
            pw.Text(
              shopName,
              style: pw.TextStyle(font: fontBold, fontSize: 12),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              shopAddress,
              style: pw.TextStyle(font: fontRegular, fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 15),

            // Meta Info
            pw.Text(
              DateTime.parse(order['transactionDate']).toLocal().toString().split('.')[0],
              style: pw.TextStyle(font: fontRegular, fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Order # ${order['invoiceNumber']}',
              style: pw.TextStyle(font: fontRegular, fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 15),

            // Items
            ...items.map((item) {
              final name = item['productName'].toString();
              final price = item['lineTotal'].toStringAsFixed(2);
              final isMultiQty = item['quantity'] > 1;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          name,
                          style: pw.TextStyle(font: fontRegular, fontSize: 10),
                        ),
                      ),
                      pw.Text(
                        '\$$price',
                        style: pw.TextStyle(font: fontRegular, fontSize: 10),
                      ),
                    ],
                  ),
                  if (isMultiQty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 8.0, top: 2.0),
                      child: pw.Text(
                        '${item['quantity']} x \$${item['unitPrice'].toStringAsFixed(2)}',
                        style: pw.TextStyle(font: fontRegular, fontSize: 10, color: PdfColors.grey700),
                      ),
                    ),
                  pw.SizedBox(height: 4),
                ],
              );
            }),
            pw.SizedBox(height: 5),

            // Separator
            pw.Divider(borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 5),

            // Totals
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 80,
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('Subtotal', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Container(
                    width: 60,
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('\$${order['subtotal'].toStringAsFixed(2)}', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  ),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 80,
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('Tax (5%)', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Container(
                    width: 60,
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('\$${order['taxAmount'].toStringAsFixed(2)}', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  ),
                ],
              ),
            ),
            if (order['discountAmount'] > 0)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 80,
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text('Discount', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Container(
                      width: 60,
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text('-\$${order['discountAmount'].toStringAsFixed(2)}', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                    ),
                  ],
                ),
              ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 80,
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('Total', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Container(
                    width: 60,
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('\$${order['totalAmount'].toStringAsFixed(2)}', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Footer
            pw.Text(
              'Thank You for Shopping With Us!',
              style: pw.TextStyle(font: fontRegular, fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
