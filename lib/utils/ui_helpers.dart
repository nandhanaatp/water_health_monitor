import 'package:flutter/material.dart';
import 'dart:html' as html;

class UIHelpers {
  // -------------------------------------------------------
  // SUCCESS SNACKBAR
  // -------------------------------------------------------
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // -------------------------------------------------------
  // ERROR SNACKBAR
  // -------------------------------------------------------
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // -------------------------------------------------------
  // EXPORT CSV (Flutter Web Safe)
  // -------------------------------------------------------
  static void exportToCsv(List<Map<String, dynamic>> data, String filename) {
    if (data.isEmpty) return;

    final headers = data.first.keys.join(',');
    final rows = data.map((row) => row.values.join(',')).join('\n');
    final csvContent = '$headers\n$rows';

    final blob = html.Blob([csvContent], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final downloadAnchor = html.AnchorElement(href: url)
      ..download = '$filename.csv'
      ..style.display = 'none';

    html.document.body?.append(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();

    html.Url.revokeObjectUrl(url);
  }

  // -------------------------------------------------------
  // PRINT REPORT (Flutter Web Safe)
  // -------------------------------------------------------
  static void printReport(String title, String content) {
    final printWindow = html.window.open('', '_blank');

    // Ensure window is available
    if (printWindow == null) return;

    final htmlDoc = (printWindow as dynamic).document;

    htmlDoc.write('''
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <title>$title</title>
          <style>
            body {
              font-family: Arial, sans-serif;
              margin: 20px;
            }
            h1 {
              color: #009688;
              text-align: left;
            }
            table {
              border-collapse: collapse;
              width: 100%;
              margin-top: 20px;
            }
            th, td {
              border: 1px solid #ccc;
              padding: 8px;
              text-align: left;
            }
            th {
              background-color: #f0f0f0;
            }
          </style>
        </head>
        <body>
          <h1>$title</h1>
          <p><b>Generated on:</b> ${DateTime.now().toString().split('.')[0]}</p>
          $content
        </body>
      </html>
    ''');

    htmlDoc.close();

    // Trigger print AFTER page load
    Future.delayed(const Duration(milliseconds: 300), () {
      (printWindow as dynamic).print();
    });
  }
}
