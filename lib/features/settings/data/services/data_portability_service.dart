import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:varavu_selavu/core/constants/app_constants.dart';
import 'package:varavu_selavu/core/database/app_database.dart';
import 'package:varavu_selavu/core/database/database_tables.dart';
import 'package:varavu_selavu/core/extensions/date_extensions.dart';
import 'package:varavu_selavu/core/extensions/number_extensions.dart';
import 'package:varavu_selavu/features/dashboard/domain/entities/monthly_summary.dart';
import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';

class DataPortabilityService {
  final AppDatabase appDatabase;

  DataPortabilityService({required this.appDatabase});

  // 1. Generate PDF Report
  Future<List<int>> generateMonthlyPdf({
    required MonthlySummary summary,
    required List<AppTransaction> transactions,
  }) async {
    final pdf = pw.Document();

    final parts = summary.monthKey.split('-');
    final monthDate = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    final monthTitle = monthDate.toMonthYearString();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Varavu Selavu',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Monthly Expense & Income Report', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(monthTitle, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Generated on: ${DateTime.now().toIsoDateString()}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
            ],
          ),
          pw.Divider(thickness: 1, color: PdfColors.grey300),
          pw.SizedBox(height: 16),

          // Financial Summary Table
          pw.Text('Financial Overview', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _pdfHeaderCell('Starting Balance'),
                  _pdfHeaderCell('Money Added'),
                  _pdfHeaderCell('Total Spent'),
                  _pdfHeaderCell('Available Balance'),
                ],
              ),
              pw.TableRow(
                children: [
                  _pdfCell(summary.startingBalance.toCurrency(symbol: 'Rs.')),
                  _pdfCell(summary.totalIncome.toCurrency(symbol: 'Rs.'), color: PdfColors.green800),
                  _pdfCell(summary.totalExpense.toCurrency(symbol: 'Rs.'), color: PdfColors.red800),
                  _pdfCell(summary.availableBalance.toCurrency(symbol: 'Rs.'), bold: true),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Category Spending Breakdown
          if (summary.categorySpendings.isNotEmpty) ...[
            pw.Text('Category Breakdown', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _pdfHeaderCell('Category'),
                    _pdfHeaderCell('Transactions'),
                    _pdfHeaderCell('Amount'),
                    _pdfHeaderCell('Share %'),
                  ],
                ),
                ...summary.categorySpendings.map((cat) => pw.TableRow(
                      children: [
                        _pdfCell(cat.categoryName),
                        _pdfCell(cat.transactionCount.toString()),
                        _pdfCell(cat.totalAmount.toCurrency(symbol: 'Rs.')),
                        _pdfCell('${cat.percentage.toStringAsFixed(1)}%'),
                      ],
                    )),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // Detailed Transactions List
          pw.Text('Transaction Log (${transactions.length} items)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _pdfHeaderCell('Date'),
                  _pdfHeaderCell('Type'),
                  _pdfHeaderCell('Category'),
                  _pdfHeaderCell('Note'),
                  _pdfHeaderCell('Amount'),
                ],
              ),
              ...transactions.map((tx) => pw.TableRow(
                    children: [
                      _pdfCell(tx.date.toIsoDateString()),
                      _pdfCell(tx.type.name.toUpperCase(), color: tx.type == TransactionType.income ? PdfColors.green800 : PdfColors.red800),
                      _pdfCell(tx.categoryName ?? 'Other'),
                      _pdfCell(tx.note ?? '-'),
                      _pdfCell(tx.amount.toCurrency(symbol: 'Rs.'), bold: true),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pdfHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
    );
  }

  static pw.Widget _pdfCell(String text, {bool bold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  // 2. Generate CSV Export (RFC 4180 standard formatting without external dependency)
  String generateCsv(List<AppTransaction> transactions) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Type,Category,Amount,Note,CreatedAt,UpdatedAt');

    for (final tx in transactions) {
      final date = tx.date.toIsoDateString();
      final type = tx.type.name;
      final category = _escapeCsv(tx.categoryName ?? '');
      final amount = tx.amount.toString();
      final note = _escapeCsv(tx.note ?? '');
      final createdAt = tx.createdAt.toIso8601String();
      final updatedAt = tx.updatedAt.toIso8601String();

      buffer.writeln('$date,$type,$category,$amount,$note,$createdAt,$updatedAt');
    }

    return buffer.toString();
  }

  String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  // 3. Backup JSON Generation
  Future<String> createBackupJson() async {
    final db = await appDatabase.database;

    final categories = await db.query(DatabaseTables.categories);
    final transactions = await db.query(DatabaseTables.transactions);
    final monthlyConfigs = await db.query(DatabaseTables.monthlyConfigs);

    final backupData = {
      'appName': AppConstants.appName,
      'version': AppConstants.backupSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': categories,
      'transactions': transactions,
      'monthlyConfigs': monthlyConfigs,
    };

    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  // 4. Restore and Validate JSON
  Future<Map<String, int>> restoreBackupJson(String jsonString) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (_) {
      throw const FormatException('Invalid JSON format in backup file.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Malformed backup structure.');
    }

    if (!decoded.containsKey('version') || !decoded.containsKey('transactions')) {
      throw const FormatException('Incompatible backup file: missing required schema fields.');
    }

    final int version = decoded['version'] as int? ?? 0;
    if (version > AppConstants.backupSchemaVersion) {
      throw FormatException('Backup from newer version ($version) cannot be restored.');
    }

    final categories = (decoded['categories'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final transactions = (decoded['transactions'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final monthlyConfigs = (decoded['monthlyConfigs'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    final db = await appDatabase.database;

    // Transactionally restore to prevent partial corrupted state
    await db.transaction((txn) async {
      await txn.delete(DatabaseTables.transactions);
      await txn.delete(DatabaseTables.categories);
      await txn.delete(DatabaseTables.monthlyConfigs);

      final catBatch = txn.batch();
      for (final cat in categories) {
        catBatch.insert(DatabaseTables.categories, cat);
      }
      await catBatch.commit(noResult: true);

      final txBatch = txn.batch();
      for (final tx in transactions) {
        txBatch.insert(DatabaseTables.transactions, tx);
      }
      await txBatch.commit(noResult: true);

      final cfgBatch = txn.batch();
      for (final cfg in monthlyConfigs) {
        cfgBatch.insert(DatabaseTables.monthlyConfigs, cfg);
      }
      await cfgBatch.commit(noResult: true);
    });

    return {
      'categories': categories.length,
      'transactions': transactions.length,
      'monthlyConfigs': monthlyConfigs.length,
    };
  }
}
