import 'package:flutter/material.dart';
import '../../../customer/domain/models/customer_model.dart';
import '../../../customer/domain/models/contract_model.dart';
import '../../../customer/domain/models/pricing_model.dart';
import '../../../customer/data/repositories/customer_repository.dart';
import '../../../../app/di/injection_container.dart' as di;

class AdminCustomerProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];

  // Maps to store contracts and pricing by customerId
  final Map<String, List<Contract>> _contracts = {};
  final Map<String, List<Pricing>> _pricing = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Customer> get customers => _filteredCustomers;

  AdminCustomerProvider() : _repository = di.sl<CustomerRepository>() {
    loadCustomers();
  }

  final CustomerRepository _repository;

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _customers = await _repository.getCustomers();
      _filteredCustomers = List.from(_customers);
      _error = null;
    } catch (e) {
      _error = 'Failed to load customers';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      _filteredCustomers = List.from(_customers);
    } else {
      _filteredCustomers = _customers.where((c) {
        final q = query.toLowerCase();
        return c.name.toLowerCase().contains(q) ||
            (c.companyName?.toLowerCase().contains(q) ?? false) ||
            c.email.toLowerCase().contains(q) ||
            c.phone.contains(q);
      }).toList();
    }
    notifyListeners();
  }

  Future<bool> addCustomer(Customer customer) async {
    try {
      await _repository.updateCustomer(
        customer,
      ); // Using upsert/update for add too
      _customers.add(customer);
      search(''); // Reset filter
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add customer';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      final updated = await _repository.updateCustomer(customer);
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = updated;
        search('');
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update customer';
      notifyListeners();
      return false;
    }
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Contract Management
  List<Contract> getContracts(String customerId) {
    return _contracts[customerId] ?? [];
  }

  void addContract(Contract contract) {
    if (!_contracts.containsKey(contract.customerId)) {
      _contracts[contract.customerId] = [];
    }
    _contracts[contract.customerId]!.add(contract);
    notifyListeners();
  }

  // Pricing Management
  List<Pricing> getPricing(String customerId) {
    return _pricing[customerId] ?? [];
  }

  void addPricing(Pricing pricing) {
    if (!_pricing.containsKey(pricing.customerId)) {
      _pricing[pricing.customerId] = [];
    }
    _pricing[pricing.customerId]!.add(pricing);
    notifyListeners();
  }
}
