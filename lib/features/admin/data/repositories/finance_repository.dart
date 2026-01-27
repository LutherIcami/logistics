import '../../domain/models/finance_models.dart';

abstract class FinanceRepository {
  Future<List<Invoice>> getInvoices();
  Future<List<FinancialTransaction>> getTransactions();
  Future<Invoice> createInvoice(Invoice invoice);
  Future<FinancialTransaction> addTransaction(FinancialTransaction transaction);
}
