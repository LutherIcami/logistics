class SystemSettings {
  final double baseOrderRate;
  final double distanceRate;
  final double weightRate;
  final bool enableRegistration;
  final int maintenanceThresholdDays;
  final String currency;

  SystemSettings({
    this.baseOrderRate = 2000.0,
    this.distanceRate = 25.0,
    this.weightRate = 0.5,
    this.enableRegistration = true,
    this.maintenanceThresholdDays = 30,
    this.currency = 'KES',
  });

  Map<String, dynamic> toJson() {
    return {
      'baseOrderRate': baseOrderRate,
      'distanceRate': distanceRate,
      'weightRate': weightRate,
      'enableRegistration': enableRegistration,
      'maintenanceThresholdDays': maintenanceThresholdDays,
      'currency': currency,
    };
  }

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    return SystemSettings(
      baseOrderRate: (json['baseOrderRate'] ?? 2000.0).toDouble(),
      distanceRate: (json['distanceRate'] ?? 25.0).toDouble(),
      weightRate: (json['weightRate'] ?? 0.5).toDouble(),
      enableRegistration: json['enableRegistration'] ?? true,
      maintenanceThresholdDays: json['maintenanceThresholdDays'] ?? 30,
      currency: json['currency'] ?? 'KES',
    );
  }

  SystemSettings copyWith({
    double? baseOrderRate,
    double? distanceRate,
    double? weightRate,
    bool? enableRegistration,
    int? maintenanceThresholdDays,
    String? currency,
  }) {
    return SystemSettings(
      baseOrderRate: baseOrderRate ?? this.baseOrderRate,
      distanceRate: distanceRate ?? this.distanceRate,
      weightRate: weightRate ?? this.weightRate,
      enableRegistration: enableRegistration ?? this.enableRegistration,
      maintenanceThresholdDays:
          maintenanceThresholdDays ?? this.maintenanceThresholdDays,
      currency: currency ?? this.currency,
    );
  }
}
