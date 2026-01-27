class Pricing {
  final String id;
  final String customerId;
  final String
  zoneName; // e.g., 'Nairobi Metro', 'Upcountry', or specific Route ID
  final double baseRate;
  final double perKmRate;
  final double perKgRate;
  final double waitingChargePerHour;
  final double discountPercentage;
  final DateTime effectiveDate;
  final bool isActive;

  Pricing({
    required this.id,
    required this.customerId,
    required this.zoneName,
    required this.baseRate,
    required this.perKmRate,
    required this.perKgRate,
    required this.waitingChargePerHour,
    this.discountPercentage = 0.0,
    required this.effectiveDate,
    this.isActive = true,
  });

  Pricing copyWith({
    String? id,
    String? customerId,
    String? zoneName,
    double? baseRate,
    double? perKmRate,
    double? perKgRate,
    double? waitingChargePerHour,
    double? discountPercentage,
    DateTime? effectiveDate,
    bool? isActive,
  }) {
    return Pricing(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      zoneName: zoneName ?? this.zoneName,
      baseRate: baseRate ?? this.baseRate,
      perKmRate: perKmRate ?? this.perKmRate,
      perKgRate: perKgRate ?? this.perKgRate,
      waitingChargePerHour: waitingChargePerHour ?? this.waitingChargePerHour,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
