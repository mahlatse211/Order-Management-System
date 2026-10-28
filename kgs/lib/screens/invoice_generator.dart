import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart'; // Make sure to add 'intl' to pubspec.yaml if you haven't

class InvoiceGenerator {
  static Future<void> generateAndDownloadInvoice({
    required String orderId,
    required String serviceName,
    required String status,
    required String description,
    required String deadline,
    required String budget,
    required String adminMessage,
  }) async {
    final pdf = pw.Document();

    // Format the date
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('KATLIEY GRAPHICS', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('Build a brand people remember.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                        pw.SizedBox(height: 4),
                        pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 20),

                // --- ORDER DETAILS ---
                pw.Text('Order Details', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      _buildRow('Order ID', orderId),
                      _buildRow('Service', serviceName),
                      _buildRow('Status', status),
                      _buildRow('Deadline', deadline.isEmpty ? 'Not Set' : deadline),
                      _buildRow('Budget', budget == '0.00' || budget.isEmpty ? 'Not Set' : 'R $budget'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // --- DESCRIPTION ---
                pw.Text('Description', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(description.isEmpty ? 'No description provided.' : description, style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),

                // --- ADMIN MESSAGE ---
                pw.Text('Message From Admin', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(adminMessage.isEmpty ? 'No message from admin.' : adminMessage, style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),

                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 20),

                // --- FOOTER ---
                pw.Center(
                  child: pw.Text(
                    'Thank you for choosing Katliey Graphics!',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    'For any queries, please contact us via the app.',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Print / Save to device
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_$orderId.pdf',
    );
  }

  // Helper widget for the rows
  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}