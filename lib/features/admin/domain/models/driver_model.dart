class Driver {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String status; // 'active', 'on_leave', 'inactive'
  final double rating;
  final int totalTrips;
  final String? currentLocation;
  final String? currentVehicle;
  final DateTime joinDate;
  final String? profileImage;
  final Map<String, dynamic>? additionalInfo;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.licenseNumber,
    this.licenseExpiry,
    this.status = 'active',
    this.rating = 0.0,
    this.totalTrips = 0,
    this.currentLocation,
    this.currentVehicle,
    required this.joinDate,
    this.profileImage,
    this.additionalInfo,
  });

  // Convert Driver object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry,
      'status': status,
      'rating': rating,
      'total_trips': totalTrips,
      'current_location': currentLocation,
      'current_vehicle': currentVehicle,
      'join_date': joinDate.toIso8601String(),
      'profile_image': profileImage,
      'additional_info': additionalInfo,
    };
  }

  // Create Driver object from JSON
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      licenseNumber: json['license_number'] ?? json['licenseNumber'],
      licenseExpiry: json['license_expiry'] ?? json['licenseExpiry'],
      status: json['status'] ?? 'active',
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalTrips: json['total_trips'] ?? json['totalTrips'] ?? 0,
      currentLocation: json['current_location'] ?? json['currentLocation'],
      currentVehicle: json['current_vehicle'] ?? json['currentVehicle'],
      joinDate: DateTime.parse(
        json['join_date'] ??
            json['joinDate'] ??
            DateTime.now().toIso8601String(),
      ),
      profileImage: json['profile_image'] ?? json['profileImage'],
      additionalInfo: json['additional_info'] ?? json['additionalInfo'],
    );
  }

  // Create a copy of the driver with some updated fields
  Driver copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? licenseNumber,
    String? licenseExpiry,
    String? status,
    double? rating,
    int? totalTrips,
    String? currentLocation,
    String? currentVehicle,
    DateTime? joinDate,
    String? profileImage,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      currentLocation: currentLocation ?? this.currentLocation,
      currentVehicle: currentVehicle ?? this.currentVehicle,
      joinDate: joinDate ?? this.joinDate,
      profileImage: profileImage ?? this.profileImage,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Helper methods
  bool get isActive => status == 'active';
  bool get isOnLeave => status == 'on_leave';
  bool get isInactive => status == 'inactive';

  String get statusDisplayText {
    switch (status) {
      case 'active':
        return 'Active';
      case 'on_leave':
        return 'On Leave';
      case 'inactive':
        return 'Inactive';
      default:
        return status;
    }
  }

  String get statusDisplayEmoji {
    switch (status) {
      case 'active':
        return '🟢';
      case 'on_leave':
        return '🟡';
      case 'inactive':
        return '🔴';
      default:
        return '⚪';
    }
  }

  // Calculate driver level based on trips and rating
  String get driverLevel {
    if (totalTrips >= 100 && rating >= 4.5) return 'Elite';
    if (totalTrips >= 50 && rating >= 4.0) return 'Professional';
    if (totalTrips >= 10) return 'Experienced';
    return 'New';
  }
}
