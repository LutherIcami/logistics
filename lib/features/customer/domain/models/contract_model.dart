class Contract {
  final String id;
  final String customerId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'Active', 'Expired', 'Pending', 'Terminated'
  final double value;
  final String? termsAndConditions;
  final DateTime? signedDate;
  final List<String>? attachments;

  Contract({
    required this.id,
    required this.customerId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.value,
    this.termsAndConditions,
    this.signedDate,
    this.attachments,
  });

  bool get isActive {
    final now = DateTime.now();
    return status == 'Active' &&
        now.isAfter(startDate) &&
        now.isBefore(endDate);
  }

  Contract copyWith({
    String? id,
    String? customerId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? value,
    String? termsAndConditions,
    DateTime? signedDate,
    List<String>? attachments,
  }) {
    return Contract(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      value: value ?? this.value,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      signedDate: signedDate ?? this.signedDate,
      attachments: attachments ?? this.attachments,
    );
  }
}
