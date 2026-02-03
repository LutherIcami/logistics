import 'package:flutter/material.dart';
import '../../domain/models/finance_models.dart';
import '../../data/repositories/finance_repository.dart';
import '../../../../app/di/injection_container.dart' as di;

class FinanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Invoice> _invoices = [];
  List<FinancialTransaction> _transactions = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Invoice> get invoices => _invoices;
  List<FinancialTransaction> get transactions => _transactions;

  final FinanceRepository _repository;

  FinanceProvider() : _repository = di.sl<FinanceRepository>() {
    loadData();
  }

  // KPIs
  double get totalRevenue => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get commissionIncome => _transactions
      .where(
        (t) =>
            t.category?.name == 'commission' ||
            t.description.contains('Commission'),
      )
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get netProfit => totalRevenue - totalExpenses;

  double get pendingInvoicesAmount => _invoices
      .where(
        (i) =>
            i.status == InvoiceStatus.sent || i.status == InvoiceStatus.overdue,
      )
      .fold(0, (sum, i) => sum + i.totalAmount);

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getInvoices(),
        _repository.getTransactions(),
      ]);
      _invoices = results[0] as List<Invoice>;
      _transactions = results[1] as List<FinancialTransaction>;
    } catch (e) {
      _error = 'Failed to load finance data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addInvoice(Invoice invoice) async {
    try {
      final newInvoice = await _repository.createInvoice(invoice);
      _invoices.insert(0, newInvoice);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addTransaction(FinancialTransaction transaction) async {
    try {
      final newTx = await _repository.addTransaction(transaction);
      _transactions.insert(0, newTx);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add transaction';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete transaction';
      notifyListeners();
    }
  }

  Future<bool> updateInvoice(Invoice invoice) async {
    try {
      // Check if we need to create/remove an automated transaction
      final oldInvoice = _invoices.firstWhere((inv) => inv.id == invoice.id);

      // 1. If moving TO Paid: Add automated income transaction
      if (invoice.status == InvoiceStatus.paid &&
          oldInvoice.status != InvoiceStatus.paid) {
        final automatedTx = FinancialTransaction(
          id: 'AUTO-${invoice.id}',
          type: TransactionType.income,
          amount: invoice.totalAmount,
          date: DateTime.now(),
          description:
              'Payment received: ${invoice.customerName} (Inv #${invoice.id.substring(0, 8)})',
          referenceId: invoice.id,
        );
        await addTransaction(automatedTx);
      }

      // 2. If moving AWAY from Paid: Remove automated transaction
      if (oldInvoice.status == InvoiceStatus.paid &&
          invoice.status != InvoiceStatus.paid) {
        await deleteTransaction('AUTO-${invoice.id}');
      }

      await _repository.updateInvoice(invoice);
      final index = _invoices.indexWhere((inv) => inv.id == invoice.id);
      if (index != -1) {
        _invoices[index] = invoice;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update invoice';
      notifyListeners();
      return false;
    }
  }
}
