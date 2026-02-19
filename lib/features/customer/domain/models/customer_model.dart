class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? companyName;
  final String? address;
  final String? city;
  final String? country;
  final DateTime joinDate;
  final int totalOrders;
  final double totalSpent;
  final String? profileImage;
  final Map<String, dynamic>? additionalInfo;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.companyName,
    this.address,
    this.city,
    this.country,
    required this.joinDate,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.profileImage,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company_name': companyName,
      'address': address,
      'city': city,
      'country': country,
      'join_date': joinDate.toIso8601String(),
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'profile_image': profileImage,
      'additional_info': additionalInfo,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      companyName: json['company_name'] ?? json['companyName'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      joinDate: DateTime.parse(
        json['join_date'] ??
            json['joinDate'] ??
            DateTime.now().toIso8601String(),
      ),
      totalOrders: json['total_orders'] ?? json['totalOrders'] ?? 0,
      totalSpent: (json['total_spent'] ?? json['totalSpent'] ?? 0.0).toDouble(),
      profileImage: json['profile_image'] ?? json['profileImage'],
      additionalInfo: json['additional_info'] ?? json['additionalInfo'],
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? companyName,
    String? address,
    String? city,
    String? country,
    DateTime? joinDate,
    int? totalOrders,
    double? totalSpent,
    String? profileImage,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      joinDate: joinDate ?? this.joinDate,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      profileImage: profileImage ?? this.profileImage,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
