import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../../domain/models/finance_models.dart';

import '../base_module_page.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseModulePage(
      title: 'Economic Center',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/finance/invoices/new'),
        backgroundColor: const Color(0xFF1E293B),
        icon: const Icon(Icons.add_chart_rounded, color: Colors.white),
        label: const Text(
          'Create Invoice',
          style: TextStyle(color: Colors.white),
        ),
      ),
      child: Consumer<FinanceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Financial Insights
                const Text(
                  'Market Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryCards(context, provider),
                const SizedBox(height: 32),

                // Invoices Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Billings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/admin/finance/invoices'),
                      child: const Text(
                        'View Ledger',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.invoices.isEmpty)
                  _buildEmptyState('No pending or historical invoices.')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.invoices.take(3).length,
                    itemBuilder: (context, index) =>
                        _InvoiceListItem(invoice: provider.invoices[index]),
                  ),

                const SizedBox(height: 32),

                // Transactions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cash Flow Operations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.push('/admin/finance/transactions'),
                      child: const Text(
                        'View All',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.transactions.isEmpty)
                  _buildEmptyState('No recent activity recorded.')
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.transactions.take(5).length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.grey[100],
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, index) => _TransactionListItem(
                            transaction: provider.transactions[index],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.push('/admin/finance/transactions/new'),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Record Transaction'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, FinanceProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _FinanceStatCard(
            title: 'Gross Revenue',
            amount: provider.totalRevenue,
            icon: Icons.account_balance_rounded,
            color: Colors.green,
            trend: '+12.4%',
            onTap: () => context.push('/admin/reports/financial'),
          ),
          const SizedBox(width: 16),
          _FinanceStatCard(
            title: 'Trip Commissions (30%)',
            amount: provider.commissionIncome,
            icon: Icons.pie_chart_rounded,
            color: Colors.indigo,
            trend: 'Direct Cut',
            onTap: () => context.push('/admin/finance/transactions'),
          ),
          const SizedBox(width: 16),
          _FinanceStatCard(
            title: 'Operational Cost',
            amount: provider.totalExpenses,
            icon: Icons.payments_rounded,
            color: Colors.orange,
            trend: '-2.1%',
            onTap: () => context.push('/admin/reports/financial'),
          ),
          const SizedBox(width: 16),
          _FinanceStatCard(
            title: 'Net Performance',
            amount: provider.netProfit,
            icon: Icons.analytics_rounded,
            color: Colors.blue,
            trend: '+8.5%',
            onTap: () => context.push('/admin/reports/financial'),
          ),
          const SizedBox(width: 16),
          _FinanceStatCard(
            title: 'Accounts Receivable',
            amount: provider.pendingInvoicesAmount,
            icon: Icons.hourglass_bottom_rounded,
            color: Colors.purple,
            trend: '15 items',
            onTap: () => context.push('/admin/finance/invoices'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _FinanceStatCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final String trend;
  final VoidCallback? onTap;

  const _FinanceStatCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.trend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  trend,
                  style: TextStyle(
                    color: trend.contains('+')
                        ? Colors.green
                        : (trend.contains('-') ? Colors.red : Colors.grey),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'KES ${amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => context.push('/admin/finance/invoices/${invoice.id}'),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(Icons.receipt_rounded, color: statusColor, size: 24),
        ),
        title: Text(
          invoice.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          'ID: ${invoice.id.substring(0, 8)} • Due: ${invoice.dueDate.day}/${invoice.dueDate.month}',
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'KES ${invoice.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                invoice.status.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final FinancialTransaction transaction;
  const _TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    return ListTile(
      onTap: () => context.push('/admin/finance/transactions'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isIncome ? Colors.green : Colors.red).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
          color: isIncome ? Colors.green : Colors.red,
          size: 16,
        ),
      ),
      title: Text(
        transaction.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${transaction.date.day}/${transaction.date.month} • ${transaction.category?.name ?? "Other"}',
        style: TextStyle(color: Colors.grey[400], fontSize: 11),
      ),
      trailing: Text(
        '${isIncome ? "+" : "-"} ${transaction.amount.toStringAsFixed(0)}',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
