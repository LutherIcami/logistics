enum TransactionType { income, expense }

enum InvoiceStatus { draft, sent, paid, overdue, cancelled }

enum ExpenseCategory { fuel, maintenance, salary, office, marketing, other }

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
    'description': description,
    'quantity': quantity,
    'unit_price': unitPrice,
  };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    description: json['description'],
    quantity: json['quantity'],
    unitPrice: (json['unit_price'] ?? json['unitPrice']).toDouble(),
  );
}

class Invoice {
  final String id;
  final String customerId;
  final String customerName;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final InvoiceStatus status;
  final String? notes;
  final String? orderId; // Reference to the order this invoice is for

  Invoice({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.issueDate,
    required this.dueDate,
    required this.items,
    this.status = InvoiceStatus.draft,
    this.notes,
    this.orderId,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer_id': customerId,
    'customer_name': customerName,
    'issue_date': issueDate.toIso8601String(),
    'due_date': dueDate.toIso8601String(),
    'status': status.name,
    'notes': notes,
    'order_id': orderId,
    'items': items.map((e) => e.toJson()).toList(),
    'total_amount': totalAmount,
  };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: json['id'],
    customerId: json['customer_id'] ?? json['customerId'],
    customerName: json['customer_name'] ?? json['customerName'],
    issueDate: DateTime.parse(json['issue_date'] ?? json['issueDate']),
    dueDate: DateTime.parse(json['due_date'] ?? json['dueDate']),
    items: (json['items'] as List).map((e) => InvoiceItem.fromJson(e)).toList(),
    status: InvoiceStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => InvoiceStatus.draft,
    ),
    notes: json['notes'],
    orderId: json['order_id'] ?? json['orderId'],
  );

  Invoice copyWith({
    String? id,
    String? customerId,
    String? customerName,
    DateTime? issueDate,
    DateTime? dueDate,
    List<InvoiceItem>? items,
    InvoiceStatus? status,
    String? notes,
    String? orderId,
  }) {
    return Invoice(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      orderId: orderId ?? this.orderId,
    );
  }
}

class FinancialTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String description;
  final String? referenceId; // e.g., Invoice ID or Expense ID
  final ExpenseCategory? category; // Only for expenses

  FinancialTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    this.referenceId,
    this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'date': date.toIso8601String(),
    'description': description,
    'reference_id': referenceId,
    'category': category?.name,
  };

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) =>
      FinancialTransaction(
        id: json['id'],
        type: TransactionType.values.firstWhere((e) => e.name == json['type']),
        amount: json['amount'].toDouble(),
        date: DateTime.parse(json['date']),
        description: json['description'],
        referenceId: json['reference_id'] ?? json['referenceId'],
        category: json['category'] != null
            ? ExpenseCategory.values.firstWhere(
                (e) => e.name == json['category'],
              )
            : null,
      );
}
