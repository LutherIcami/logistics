import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/finance_models.dart';
import 'finance_repository.dart';

class SupabaseFinanceRepository implements FinanceRepository {
  final SupabaseClient client;

  SupabaseFinanceRepository(this.client);

  @override
  Future<List<Invoice>> getInvoices() async {
    try {
      final response = await client
          .from('invoices')
          .select()
          .order('issue_date', ascending: false);
      return (response as List).map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch invoices: $e');
    }
  }

  @override
  Future<List<FinancialTransaction>> getTransactions() async {
    try {
      final response = await client
          .from('financial_transactions')
          .select()
          .order('date', ascending: false);
      return (response as List)
          .map((json) => FinancialTransaction.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  @override
  Future<Invoice> createInvoice(Invoice invoice) async {
    try {
      final response = await client
          .from('invoices')
          .insert(invoice.toJson())
          .select()
          .single();
      return Invoice.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }

  @override
  Future<Invoice> updateInvoice(Invoice invoice) async {
    try {
      final response = await client
          .from('invoices')
          .update(invoice.toJson())
          .eq('id', invoice.id)
          .select()
          .single();
      return Invoice.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }

  @override
  Future<FinancialTransaction> addTransaction(
    FinancialTransaction transaction,
  ) async {
    try {
      final response = await client
          .from('financial_transactions')
          .insert(transaction.toJson())
          .select()
          .single();
      return FinancialTransaction.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await client.from('financial_transactions').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }
}
