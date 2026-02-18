import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import '../../../providers/finance_provider.dart';
import '../../../../domain/models/finance_models.dart';

class InvoiceDetailPage extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetailPage({super.key, required this.invoiceId});

  Future<Uint8List> _generatePdfData(Invoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Invoice #: ${invoice.id}'),
                      pw.Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(invoice.issueDate)}',
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Projo Logistics',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Nairobi, Kenya'),
                      pw.Text('support@projo.co.ke'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              // Bill To
              pw.Text(
                'BILL TO:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(invoice.customerName),
              pw.Text('Customer ID: ${invoice.customerId}'),
              pw.SizedBox(height: 32),

              // Items Table
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Description', 'Qty', 'Unit Price', 'Total'],
                data: invoice.items.map((item) {
                  return [
                    item.description,
                    item.quantity.toString(),
                    'KES ${item.unitPrice.toStringAsFixed(2)}',
                    'KES ${item.total.toStringAsFixed(2)}',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 24),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'TOTAL AMOUNT:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'KES ${invoice.totalAmount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 32),
              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                pw.Text(
                  'NOTES:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(invoice.notes!),
              ],

              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _downloadPdf(BuildContext context, Invoice invoice) async {
    try {
      final pdfData = await _generatePdfData(invoice);
      final fileName = 'invoice_${invoice.id}.pdf';

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Desktop: Save to Downloads folder explicitly
        final downloadsDir = await getDownloadsDirectory();

        if (downloadsDir != null) {
          final filePath =
              '${downloadsDir.path}${Platform.pathSeparator}$fileName';
          final file = File(filePath);
          await file.writeAsBytes(pdfData);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Saved to Downloads: $filePath'),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Open Folder',
                  onPressed: () {
                    // Open the folder containing the file
                    if (Platform.isWindows) {
                      Process.run('explorer.exe', ['/select,', filePath]);
                    } else if (Platform.isMacOS) {
                      Process.run('open', ['-R', filePath]);
                    }
                  },
                ),
              ),
            );

            // Try to open safely
            try {
              final result = await OpenFile.open(filePath);
              if (result.type != ResultType.done &&
                  result.type != ResultType.noAppToOpen) {
                debugPrint('Could not open file: ${result.message}');
              }
            } catch (_) {
              // Ignore opening errors on Windows if no app associated
            }
          }
          return;
        }
      }

      // Fallback for mobile
      await Printing.sharePdf(bytes: pdfData, filename: fileName);
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download invoice')),
        );
      }
    }
  }

  Future<void> _printPdf(Invoice invoice) async {
    final pdfData = await _generatePdfData(invoice);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'invoice_${invoice.id}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final invoiceIndex = provider.invoices.indexWhere(
      (inv) => inv.id == invoiceId,
    );
    final invoice = invoiceIndex != -1 ? provider.invoices[invoiceIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          if (invoice != null) ...[
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Download / Export',
              onPressed: () => _downloadPdf(context, invoice),
            ),
            IconButton(
              icon: const Icon(Icons.print_rounded),
              tooltip: 'Print Invoice',
              onPressed: () => _printPdf(invoice),
            ),
          ],
        ],
      ),
      body: Builder(
        builder: (context) {
          if (invoice == null) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Invoice not found'),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 0,
                  color: _getStatusColor(invoice.status).withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: _getStatusColor(
                        invoice.status,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Invoice #${invoice.id.substring(4, 12)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(invoice.status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                invoice.status.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Customer',
                          value: invoice.customerName,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Issued',
                          value: DateFormat(
                            'MMM dd, yyyy',
                          ).format(invoice.issueDate),
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.event_available_outlined,
                          label: 'Due',
                          value: DateFormat(
                            'MMM dd, yyyy',
                          ).format(invoice.dueDate),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Items Section
                const Text(
                  'Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: invoice.items.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) =>
                      _InvoiceItemRow(item: invoice.items[index]),
                ),
                const Divider(thickness: 2),
                const SizedBox(height: 12),

                // Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'KES ${NumberFormat('#,##0.00').format(invoice.totalAmount)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Notes Section
                if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                  const Text(
                    'Notes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      invoice.notes!,
                      style: TextStyle(color: Colors.grey[700], height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Actions Section
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadPdf(context, invoice),
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _printPdf(invoice),
                        icon: const Icon(Icons.print_rounded),
                        label: const Text('Print Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (invoice.status == InvoiceStatus.sent ||
                    invoice.status == InvoiceStatus.draft ||
                    invoice.status == InvoiceStatus.overdue) ...[
                  Row(
                    children: [
                      if (invoice.status == InvoiceStatus.draft) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _updateStatus(
                              context,
                              provider,
                              invoice,
                              InvoiceStatus.sent,
                            ),
                            icon: const Icon(Icons.send_rounded),
                            label: const Text('Mark as Sent'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateStatus(
                            context,
                            provider,
                            invoice,
                            InvoiceStatus.paid,
                          ),
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text('Mark as Paid'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _updateStatus(
                        context,
                        provider,
                        invoice,
                        InvoiceStatus.cancelled,
                      ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel Invoice'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  void _updateStatus(
    BuildContext context,
    FinanceProvider provider,
    Invoice invoice,
    InvoiceStatus newStatus,
  ) {
    final updatedInvoice = invoice.copyWith(status: newStatus);
    provider.updateInvoice(updatedInvoice);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice ${newStatus.name}'),
        backgroundColor: _getStatusColor(newStatus),
      ),
    );

    if (newStatus == InvoiceStatus.paid ||
        newStatus == InvoiceStatus.cancelled) {
      context.pop();
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InvoiceItemRow extends StatelessWidget {
  final InvoiceItem item;

  const _InvoiceItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} × KES ${NumberFormat('#,##0').format(item.unitPrice)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              'KES ${NumberFormat('#,##0').format(item.total)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
