import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'admin', 'driver', 'customer'
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, fullName, role, avatarUrl];
}
