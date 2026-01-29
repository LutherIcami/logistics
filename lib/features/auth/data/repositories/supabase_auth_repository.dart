import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class SupabaseAuthRepository implements AuthRepository {
  final supabase.SupabaseClient client;

  SupabaseAuthRepository(this.client);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Left(ServerFailure('Login failed: User not found'));
      }

      final userProfile = await _getUserProfile(response.user!.id);
      return Right(userProfile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': role},
      );

      if (response.user == null) {
        return const Left(
          ServerFailure('Registration failed: User not created'),
        );
      }

      // Supabase triggers or manual insert can handle profile creation.
      // Assuming a 'profiles' table exists as discussed.
      await client.from('profiles').upsert({
        'id': response.user!.id,
        'full_name': fullName,
        'role': role,
      });

      return Right(
        UserEntity(
          id: response.user!.id,
          email: email,
          fullName: fullName,
          role: role,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> inviteDriver({
    required String email,
    required String fullName,
    String? downloadLink,
  }) async {
    try {
      final response = await client.functions.invoke(
        'welcome-driver',
        body: {
          'email': email,
          'name': fullName,
          'role': 'driver',
          'download_link': downloadLink,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return Right(data['userId'] as String);
      } else {
        return Left(ServerFailure(data['error'] ?? 'Failed to invite driver'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to invite driver: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await client.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return const Right(null);

      final userProfile = await _getUserProfile(user.id);
      return Right(userProfile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<UserEntity> _getUserProfile(String userId) async {
    try {
      final data = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }
}
