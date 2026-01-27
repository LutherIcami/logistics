import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_customer_provider.dart';
import '../../../../customer/domain/models/customer_model.dart';

class CustomerFormAdminPage extends StatefulWidget {
  final String? customerId;

  const CustomerFormAdminPage({super.key, this.customerId});

  @override
  State<CustomerFormAdminPage> createState() => _CustomerFormAdminPageState();
}

class _CustomerFormAdminPageState extends State<CustomerFormAdminPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _companyController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController();

    if (widget.customerId != null) {
      // Load existing data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<AdminCustomerProvider>();
        final customer = provider.getCustomerById(widget.customerId!);
        if (customer != null) {
          _nameController.text = customer.name;
          _emailController.text = customer.email;
          _phoneController.text = customer.phone;
          _companyController.text = customer.companyName ?? '';
          _addressController.text = customer.address ?? '';
          _cityController.text = customer.city ?? '';
          _countryController.text = customer.country ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customerId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add New Customer'),
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
            _buildSectionHeader('Basic Information'),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Contact Name'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Address'),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Street Address'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveCustomer,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(isEditing ? 'Update Customer' : 'Create Customer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _saveCustomer() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<AdminCustomerProvider>();

      final customer = Customer(
        id:
            widget.customerId ??
            'CUST-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        companyName: _companyController.text.isNotEmpty
            ? _companyController.text
            : null,
        address: _addressController.text.isNotEmpty
            ? _addressController.text
            : null,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        country: _countryController.text.isNotEmpty
            ? _countryController.text
            : null,
        joinDate:
            DateTime.now(), // In edit mode, usually preserve original date, but simplifying for now or need to fetch original
      );

      if (widget.customerId != null) {
        // We need to preserve original fields that aren't editable here (id, joinDate, stats)
        // Ideally we fetch the original and copyWith.
        final original = provider.getCustomerById(widget.customerId!);
        if (original != null) {
          provider.updateCustomer(
            original.copyWith(
              name: customer.name,
              email: customer.email,
              phone: customer.phone,
              companyName: customer.companyName,
              address: customer.address,
              city: customer.city,
              country: customer.country,
            ),
          );
        }
      } else {
        provider.addCustomer(customer);
      }

      context.pop();
    }
  }
}
