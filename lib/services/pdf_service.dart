import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:trucky/services/currency_service.dart';
import 'package:trucky/utils/amount_formatter.dart'; // Added for custom formatting

class PdfService {
  Future<String> generateMonthlySubscriptionReport({
    required String userName,
    required List<Map<String, dynamic>> subscriptions,
    required DateTime selectedMonth,
    required double totalAmount,
    required String currencyCode,
  }) async {
    try {
      // Define colors for a more attractive design - use specific colors instead of lighter property
      final PdfColor primaryColor = PdfColors.blue700;
      final PdfColor primaryColorLight =
          PdfColors.blue200; // Instead of primaryColor.lighter
      final PdfColor accentColor = PdfColors.amber700;
      final PdfColor backgroundColor = PdfColors.grey100;
      final PdfColor textColor = PdfColors.blueGrey800;

      // Create the PDF document
      final pdf = pw.Document();

      // Create data for table
      final tableData =
          subscriptions.map((subscription) {
            return [
              subscription['name']?.toString() ?? 'Unknown',
              DateFormat('dd MMM').format(subscription['paymentDate']),
              formatAmountWithCurrencyAfter(
                subscription['amount'],
                currencyCode,
              ),
            ];
          }).toList();

      // Add page to the PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: primaryColorLight, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Padding(
                padding: pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header section
                    pw.Container(
                      width: double.infinity,
                      decoration: pw.BoxDecoration(
                        color: primaryColor,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      padding: pw.EdgeInsets.all(16),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'Subscription Report',
                                    style: pw.TextStyle(
                                      color: PdfColors.white,
                                      fontSize: 24,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    DateFormat(
                                      'MMMM yyyy',
                                    ).format(selectedMonth),
                                    style: pw.TextStyle(
                                      color: PdfColors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              pw.Container(
                                padding: pw.EdgeInsets.all(8),
                                decoration: pw.BoxDecoration(
                                  color: accentColor,
                                  borderRadius: pw.BorderRadius.circular(20),
                                ),
                                child: pw.Text(
                                  'TRACKY',
                                  style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 20),

                    // User info section
                    pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: backgroundColor,
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: primaryColorLight),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'User: $userName',
                                style: pw.TextStyle(
                                  color: textColor,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                'Generated: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                                style: pw.TextStyle(
                                  color: textColor,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                'Total Amount',
                                style: pw.TextStyle(color: textColor),
                              ),
                              pw.SizedBox(height: 3),
                              pw.Text(
                                formatAmountWithCurrencyAfter(
                                  totalAmount,
                                  currencyCode,
                                ),
                                style: pw.TextStyle(
                                  color: primaryColor,
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 20),

                    // Title for table
                    pw.Text(
                      'Monthly Subscriptions',
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),

                    pw.SizedBox(height: 10),

                    // Table with styled header
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: primaryColorLight),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Table(
                        border: pw.TableBorder.symmetric(
                          inside: pw.BorderSide(
                            color: PdfColors.grey300,
                            width: 0.5,
                          ),
                        ),
                        children: [
                          // Header row
                          pw.TableRow(
                            decoration: pw.BoxDecoration(
                              color: primaryColorLight,
                            ),
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: pw.Text(
                                  'Name',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: textColor,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: pw.Text(
                                  'Date',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: textColor,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: pw.Text(
                                  'Amount',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: textColor,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ],
                          ),

                          // Data rows with alternating colors
                          ...tableData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final row = entry.value;
                            final isEvenRow = index % 2 == 0;

                            return pw.TableRow(
                              decoration: pw.BoxDecoration(
                                color:
                                    isEvenRow
                                        ? PdfColors.white
                                        : backgroundColor,
                              ),
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    row[0],
                                    textAlign: pw.TextAlign.left,
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    row[1],
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    row[2],
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 15),

                    // Summary section
                    pw.Container(
                      width: double.infinity,
                      padding: pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: primaryColor),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Summary',
                            style: pw.TextStyle(
                              color: primaryColor,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Divider(color: PdfColors.grey300),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total subscriptions:'),
                              pw.Text(
                                '${subscriptions.length}',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total monthly cost:'),
                              pw.Text(
                                formatAmountWithCurrencyAfter(
                                  totalAmount,
                                  currencyCode,
                                ),
                                style: pw.TextStyle(
                                  color: primaryColor,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.Spacer(),

                    // Footer
                    pw.Center(
                      child: pw.Container(
                        padding: pw.EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey400),
                          borderRadius: pw.BorderRadius.circular(30),
                        ),
                        child: pw.Text(
                          'Generated by Tracky App',
                          style: pw.TextStyle(
                            color: PdfColors.grey600,
                            fontStyle: pw.FontStyle.italic,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Save file logic remains the same
      try {
        // Use temporary directory for reliable access
        final dir = await getTemporaryDirectory();
        final String fileName =
            'trucky_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final String filePath = '${dir.path}/$fileName';

        // Write PDF to file
        final File file = File(filePath);
        final bytes = await pdf.save();
        await file.writeAsBytes(bytes);

        print('PDF saved successfully to: $filePath');
        return filePath;
      } catch (e) {
        print("Error saving PDF: $e");

        // Fall back to application documents directory
        final dir = await getApplicationDocumentsDirectory();
        final String fileName =
            'trucky_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final String filePath = '${dir.path}/$fileName';

        // Write PDF to file
        final File file = File(filePath);
        await file.writeAsBytes(await pdf.save());

        print('PDF saved to application documents: $filePath');
        return filePath;
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
