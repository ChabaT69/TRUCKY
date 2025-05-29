import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfService {
  Future<String> generateMonthlySubscriptionReport({
    required String userName,
    required List<Map<String, dynamic>> subscriptions,
    required DateTime selectedMonth,
    required double totalAmount,
  }) async {
    try {
      // Create a bare minimum PDF document
      final pdf = pw.Document();

      // Simplify data preparation
      List<List<String>> tableRows = [];
      for (var sub in subscriptions) {
        tableRows.add([
          sub['name']?.toString() ?? 'Unknown',
          DateFormat('dd/MM').format(sub['paymentDate']),
          '\$${sub['amount'].toStringAsFixed(2)}',
        ]);
      }

      // Create a single page with minimal content
      pdf.addPage(
        pw.Page(
          build:
              (context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Subscription Report'),
                  pw.SizedBox(height: 10),
                  pw.Text('User: $userName'),
                  pw.Text(
                    'Month: ${DateFormat('MMMM yyyy').format(selectedMonth)}',
                  ),
                  pw.SizedBox(height: 10),

                  // Simple table
                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      // Header row
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Name'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Date'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Amount'),
                          ),
                        ],
                      ),
                      // Data rows
                      ...tableRows.map(
                        (row) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(row[0]),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(row[1]),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(row[2]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 10),
                  pw.Text('Total: \$${totalAmount.toStringAsFixed(2)}'),
                ],
              ),
        ),
      );

      // Generate PDF bytes
      final Uint8List pdfBytes = await pdf.save();

      // Try multiple methods to get a path to save the file
      String filePath = '';

      try {
        // Method 1: Try using getTemporaryDirectory
        final tempDir = await getTemporaryDirectory();
        filePath =
            '${tempDir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      } catch (e) {
        print("Error getting temporary directory: $e");

        try {
          // Method 2: Try using getApplicationDocumentsDirectory
          final docDir = await getApplicationDocumentsDirectory();
          filePath =
              '${docDir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        } catch (e) {
          print("Error getting documents directory: $e");

          try {
            // Method 3: Try using getExternalStorageDirectory (Android only)
            final extDir = await getExternalStorageDirectory();
            filePath =
                '${extDir?.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
          } catch (e) {
            print("Error getting external storage directory: $e");

            // Method 4: Last resort - hardcode a path that might work on Android
            filePath =
                '/storage/emulated/0/Download/report_${DateTime.now().millisecondsSinceEpoch}.pdf';
          }
        }
      }

      // Save file
      if (filePath.isNotEmpty) {
        final File file = File(filePath);
        await file.writeAsBytes(pdfBytes);
        print("PDF saved successfully to: $filePath");

        // Verify file exists
        if (await file.exists()) {
          return filePath;
        } else {
          throw "File was not created at path: $filePath";
        }
      } else {
        throw "Could not determine a valid file path";
      }
    } catch (e) {
      print("PDF generation error: $e");

      if (e is PlatformException) {
        throw 'Platform error: ${e.message}';
      }

      throw 'Could not create PDF: ${e.toString()}';
    }
  }
}
