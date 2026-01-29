class SystemSettings {
  final double baseOrderRate;
  final double distanceRate;
  final double weightRate;
  final bool enableRegistration;
  final int maintenanceThresholdDays;
  final String currency;
  final String driverDownloadLink;

  SystemSettings({
    this.baseOrderRate = 2000.0,
    this.distanceRate = 25.0,
    this.weightRate = 0.5,
    this.enableRegistration = true,
    this.maintenanceThresholdDays = 30,
    this.currency = 'KES',
    this.driverDownloadLink = 'https://your-app-link.com/download',
  });

  Map<String, dynamic> toJson() {
    return {
      'baseOrderRate': baseOrderRate,
      'distanceRate': distanceRate,
      'weightRate': weightRate,
      'enableRegistration': enableRegistration,
      'maintenanceThresholdDays': maintenanceThresholdDays,
      'currency': currency,
      'driverDownloadLink': driverDownloadLink,
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
      driverDownloadLink:
          json['driverDownloadLink'] ?? 'https://your-app-link.com/download',
    );
  }

  SystemSettings copyWith({
    double? baseOrderRate,
    double? distanceRate,
    double? weightRate,
    bool? enableRegistration,
    int? maintenanceThresholdDays,
    String? currency,
    String? driverDownloadLink,
  }) {
    return SystemSettings(
      baseOrderRate: baseOrderRate ?? this.baseOrderRate,
      distanceRate: distanceRate ?? this.distanceRate,
      weightRate: weightRate ?? this.weightRate,
      enableRegistration: enableRegistration ?? this.enableRegistration,
      maintenanceThresholdDays:
          maintenanceThresholdDays ?? this.maintenanceThresholdDays,
      currency: currency ?? this.currency,
      driverDownloadLink: driverDownloadLink ?? this.driverDownloadLink,
    );
  }
}
