import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_customer_provider.dart';
import '../../../../customer/domain/models/customer_model.dart';
import '../../../../customer/domain/models/contract_model.dart';
import '../../../../customer/domain/models/pricing_model.dart';

class CustomerDetailAdminPage extends StatefulWidget {
  final String customerId;

  const CustomerDetailAdminPage({super.key, required this.customerId});

  @override
  State<CustomerDetailAdminPage> createState() =>
      _CustomerDetailAdminPageState();
}

class _CustomerDetailAdminPageState extends State<CustomerDetailAdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminCustomerProvider>(
      builder: (context, provider, child) {
        final customer = provider.getCustomerById(widget.customerId);

        if (customer == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Customer Details')),
            body: const Center(child: Text('Customer not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(customer.companyName ?? customer.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/admin/customers'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.go('/admin/customers/${customer.id}/edit'),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Contracts'),
                Tab(text: 'Pricing'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(customer),
              _buildContractsTab(context, provider, customer.id),
              _buildPricingTab(context, provider, customer.id),
            ],
          ),
          floatingActionButton: _tabController.index > 0
              ? FloatingActionButton(
                  onPressed: () {
                    // Show dialog to add contract or pricing based on tab
                    if (_tabController.index == 1) {
                      _showAddContractDialog(context, provider, customer.id);
                    } else if (_tabController.index == 2) {
                      _showAddPricingDialog(context, provider, customer.id);
                    }
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  Widget _buildDetailsTab(Customer customer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Contact Info', [
            _buildInfoRow(Icons.person, 'Name', customer.name),
            _buildInfoRow(Icons.email, 'Email', customer.email),
            _buildInfoRow(Icons.phone, 'Phone', customer.phone),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Company Info', [
            if (customer.companyName != null)
              _buildInfoRow(Icons.business, 'Company', customer.companyName!),
            _buildInfoRow(
              Icons.location_on,
              'Address',
              '${customer.address ?? ''}, ${customer.city ?? ''}, ${customer.country ?? ''}',
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Joined',
              customer.joinDate.toIso8601String().split('T')[0],
            ),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Statistics', [
            _buildInfoRow(
              Icons.shopping_bag,
              'Total Orders',
              customer.totalOrders.toString(),
            ),
            _buildInfoRow(
              Icons.attach_money,
              'Total Spent',
              customer.totalSpent.toStringAsFixed(2),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildContractsTab(
    BuildContext context,
    AdminCustomerProvider provider,
    String customerId,
  ) {
    final contracts = provider.getContracts(customerId);

    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No contracts found',
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
              onPressed: () =>
                  _showAddContractDialog(context, provider, customerId),
              child: const Text('Add Contract'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final contract = contracts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.description, color: Colors.blue),
            title: Text(contract.title),
            subtitle: Text(
              '${contract.startDate.toString().split(' ')[0]} - ${contract.endDate.toString().split(' ')[0]}',
            ),
            trailing: Chip(
              label: Text(contract.status),
              backgroundColor: contract.isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: contract.isActive ? Colors.green : Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPricingTab(
    BuildContext context,
    AdminCustomerProvider provider,
    String customerId,
  ) {
    final pricingList = provider.getPricing(customerId);

    if (pricingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.price_change_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No pricing configurations found',
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
              onPressed: () =>
                  _showAddPricingDialog(context, provider, customerId),
              child: const Text('Add Pricing'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pricingList.length,
      itemBuilder: (context, index) {
        final pricing = pricingList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pricing.zoneName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (!pricing.isActive)
                      const Chip(
                        label: Text('Inactive'),
                        backgroundColor: Colors.grey,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildPriceItem('Base', pricing.baseRate),
                    _buildPriceItem('/ KM', pricing.perKmRate),
                    _buildPriceItem('/ KG', pricing.perKgRate),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceItem(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          amount.toStringAsFixed(2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddContractDialog(
    BuildContext context,
    AdminCustomerProvider provider,
    String customerId,
  ) {
    // Simplified Dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contract'),
        content: const Text('Contract form implementation would go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Mock adding a contract
              provider.addContract(
                Contract(
                  id: 'CON-${DateTime.now().millisecondsSinceEpoch}',
                  customerId: customerId,
                  title: 'New Contract',
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 365)),
                  status: 'Pending',
                  value: 0,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Quick Add (Mock)'),
          ),
        ],
      ),
    );
  }

  void _showAddPricingDialog(
    BuildContext context,
    AdminCustomerProvider provider,
    String customerId,
  ) {
    // Simplified Dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Pricing'),
        content: const Text('Pricing form implementation would go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Mock adding pricing
              provider.addPricing(
                Pricing(
                  id: 'PR-${DateTime.now().millisecondsSinceEpoch}',
                  customerId: customerId,
                  zoneName: 'New Zone',
                  baseRate: 0,
                  perKmRate: 0,
                  perKgRate: 0,
                  waitingChargePerHour: 0,
                  effectiveDate: DateTime.now(),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Quick Add (Mock)'),
          ),
        ],
      ),
    );
  }
}
