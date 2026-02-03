import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/finance_provider.dart';
import '../../../../domain/models/finance_models.dart';

class InvoiceFormPage extends StatefulWidget {
  const InvoiceFormPage({super.key});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _notesController = TextEditingController();

  // Simplified items for MVP
  final _amountController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Invoice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: 'Customer Name'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Amount (Mock Item)',
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (d != null) setState(() => _dueDate = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Due Date'),
                child: Text(
                  '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final provider = context.read<FinanceProvider>();

                  // Create mock invoice
                  final invoice = Invoice(
                    id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
                    customerId: 'CUST-MOCK',
                    customerName: _customerNameController.text,
                    issueDate: DateTime.now(),
                    dueDate: _dueDate,
                    status: InvoiceStatus.draft,
                    notes: _notesController.text,
                    items: [
                      InvoiceItem(
                        description: 'General Services',
                        quantity: 1,
                        unitPrice: double.tryParse(_amountController.text) ?? 0,
                      ),
                    ],
                  );

                  provider.addInvoice(invoice);
                  context.pop();
                }
              },
              child: const Text('Create Invoice'),
            ),
          ],
        ),
      ),
    );
  }
}
