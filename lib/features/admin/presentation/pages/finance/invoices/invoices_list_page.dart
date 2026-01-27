import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/finance_provider.dart';
import '../../../../domain/models/finance_models.dart';

class InvoicesListPage extends StatelessWidget {
  const InvoicesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.invoices.isEmpty) {
            return const Center(child: Text('No invoices found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.invoices.length,
            itemBuilder: (context, index) {
              final invoice = provider.invoices[index];
              return _InvoiceListItem(invoice: invoice);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/finance/invoices/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _InvoiceListItem extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceListItem({required this.invoice});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (invoice.status) {
      case InvoiceStatus.paid:
        statusColor = Colors.green;
        break;
      case InvoiceStatus.overdue:
        statusColor = Colors.red;
        break;
      case InvoiceStatus.sent:
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          // View details
        },
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(Icons.receipt, color: statusColor, size: 20),
        ),
        title: Text(
          invoice.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Due: ${invoice.dueDate.toString().split(' ')[0]}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'KES ${invoice.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              invoice.status.name.toUpperCase(),
              style: TextStyle(fontSize: 10, color: statusColor),
            ),
          ],
        ),
      ),
    );
  }
}
