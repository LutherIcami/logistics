import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../../domain/models/finance_models.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  ExpenseCategory _category = ExpenseCategory.other;
  DateTime _selectedDate = DateTime.now();
  bool _isRecording = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E293B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitTransaction() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isRecording = true);

    try {
      final provider = context.read<FinanceProvider>();
      final tx = FinancialTransaction(
        id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
        type: _type,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        description: _descriptionController.text,
        category: _type == TransactionType.expense ? _category : null,
      );

      final success = await provider.addTransaction(tx);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction recorded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to record transaction'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Record Cashflow'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Transaction Type Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                      icon: Icon(Icons.add_circle_outline, size: 20),
                    ),
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                      icon: Icon(Icons.remove_circle_outline, size: 20),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (set) {
                    setState(() => _type = set.first);
                  },
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    selectedBackgroundColor: _type == TransactionType.income
                        ? Colors.green
                        : Colors.red,
                    selectedForegroundColor: Colors.white,
                    side: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            _buildFieldCard(
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Operation Description',
                    hintText: 'e.g., Office Rent, Fuel for Trip #123',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Enter description' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Total Amount (KES)',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    suffixText: 'KES',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter amount';
                    if (double.tryParse(v) == null) return 'Invalid amount';
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category & Date Card
            _buildFieldCard(
              children: [
                if (_type == TransactionType.expense) ...[
                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: _category,
                    decoration: InputDecoration(
                      labelText: 'Expense Category',
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ExpenseCategory.values.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(
                          c.name[0].toUpperCase() + c.name.substring(1),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Transaction Date'),
                  subtitle: Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.blue,
                  ),
                  onTap: _selectDate,
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Submit Button
            ElevatedButton(
              onPressed: _isRecording ? null : _submitTransaction,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isRecording
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Confirm Operation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
