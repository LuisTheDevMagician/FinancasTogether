import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../models/user.dart';
import '../models/category.dart';

class ExportHelpers {
  // Exportar para CSV
  static Future<String> exportToCsv({
    required List<Transaction> transactions,
    required Map<String, User> usersMap,
    required Map<String, Category> categoriesMap,
  }) async {
    // Preparar dados
    List<List<dynamic>> rows = [
      [
        'ID',
        'Data',
        'Usuário',
        'Cor Usuário',
        'Tipo',
        'Categoria',
        'Cor Categoria',
        'Valor',
        'Nota',
      ],
    ];

    for (final tx in transactions) {
      final user = usersMap[tx.userId];
      final category = categoriesMap[tx.categoryId];

      rows.add([
        tx.id,
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(tx.date),
        user?.name ?? 'Desconhecido',
        user?.colorHex ?? '',
        tx.type.value,
        category?.name ?? 'Desconhecida',
        category?.colorHex ?? '',
        tx.amount.toStringAsFixed(2),
        tx.note ?? '',
      ]);
    }

    // Converter para CSV
    String csv = const ListToCsvConverter().convert(rows);

    // Salvar arquivo
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/financas_together_$timestamp.csv';

    final file = File(filePath);
    await file.writeAsString(csv);

    return filePath;
  }

  // Exportar para PDF
  static Future<String> exportToPdf({
    required List<Transaction> transactions,
    required Map<String, User> usersMap,
    required Map<String, Category> categoriesMap,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    // Calcular totais
    double totalIncome = 0;
    double totalOutcome = 0;

    for (final tx in transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalOutcome += tx.amount;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Cabeçalho
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Finanças Together',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Relatório de Transações',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Período: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Total de Entradas: R\$ ${totalIncome.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Total de Saídas: R\$ ${totalOutcome.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Saldo: R\$ ${(totalIncome - totalOutcome).toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // Tabela de transações
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildPdfCell('Data', isHeader: true),
                  _buildPdfCell('Usuário', isHeader: true),
                  _buildPdfCell('Categoria', isHeader: true),
                  _buildPdfCell('Tipo', isHeader: true),
                  _buildPdfCell('Valor', isHeader: true),
                ],
              ),
              // Dados
              ...transactions.map((tx) {
                final user = usersMap[tx.userId];
                final category = categoriesMap[tx.categoryId];

                return pw.TableRow(
                  children: [
                    _buildPdfCell(
                      DateFormat('dd/MM/yyyy HH:mm').format(tx.date),
                    ),
                    _buildPdfCell(user?.name ?? 'Desconhecido'),
                    _buildPdfCell(category?.name ?? 'Desconhecida'),
                    _buildPdfCell(
                      tx.type == TransactionType.income ? 'Entrada' : 'Saída',
                    ),
                    _buildPdfCell('R\$ ${tx.amount.toStringAsFixed(2)}'),
                  ],
                );
              }),
            ],
          ),
        ],
        footer: (context) => pw.Column(
          children: [
            pw.Divider(),
            pw.Text(
              'Gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())} por Finanças Together',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );

    // Salvar arquivo
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/financas_together_$timestamp.pdf';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  // Helper para célula PDF
  static pw.Widget _buildPdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // Compartilhar arquivo
  static Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([
      XFile(filePath),
    ], subject: 'Relatório Finanças Together');
  }
}
