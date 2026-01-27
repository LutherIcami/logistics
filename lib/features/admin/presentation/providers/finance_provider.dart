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
      _error = 'Failed to create invoice';
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
}
