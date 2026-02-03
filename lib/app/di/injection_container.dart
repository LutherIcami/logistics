import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../features/admin/data/repositories/driver_repository.dart';
import '../../features/admin/data/repositories/vehicle_repository.dart';
import '../../features/driver/data/repositories/trip_repository.dart';
import '../../features/customer/data/repositories/order_repository.dart';
import '../../features/customer/data/repositories/customer_repository.dart';
import '../../features/admin/data/repositories/supabase_driver_repository.dart';
import '../../features/admin/data/repositories/supabase_vehicle_repository.dart';
import '../../features/driver/data/repositories/supabase_trip_repository.dart';
import '../../features/customer/data/repositories/supabase_order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/data/repositories/supabase_auth_repository.dart';
import '../../features/admin/data/repositories/finance_repository.dart';
import '../../features/admin/data/repositories/supabase_finance_repository.dart';
import '../../features/admin/data/repositories/reports_repository.dart';
import '../../features/admin/data/repositories/supabase_reports_repository.dart';
import '../../features/admin/data/repositories/settings_repository.dart';
import '../../features/admin/data/repositories/supabase_settings_repository.dart';
import '../../features/common/domain/repositories/notification_repository.dart';
import '../../features/common/data/repositories/supabase_notification_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(sl()));

  // Features
  // Auth
  sl.registerLazySingleton<AuthRepository>(() => SupabaseAuthRepository(sl()));
  sl.registerFactory(() => AuthProvider(sl()));

  // Admin - Drivers
  sl.registerLazySingleton<DriverRepository>(
    () => SupabaseDriverRepository(sl()),
  );

  // Admin - Vehicles
  sl.registerLazySingleton<VehicleRepository>(
    () => SupabaseVehicleRepository(sl()),
  );

  // Driver - Trips
  sl.registerLazySingleton<TripRepository>(() => SupabaseTripRepository(sl()));

  // Customer - Orders
  sl.registerLazySingleton<OrderRepository>(
    () => SupabaseOrderRepository(sl()),
  );
  sl.registerLazySingleton<CustomerRepository>(
    () => SupabaseCustomerRepository(sl()),
  );

  // Admin - Finance
  sl.registerLazySingleton<FinanceRepository>(
    () => SupabaseFinanceRepository(sl()),
  );

  // Admin - Reports
  sl.registerLazySingleton<ReportsRepository>(
    () => SupabaseReportsRepository(sl()),
  );

  // Admin - Settings
  sl.registerLazySingleton<SettingsRepository>(
    () => SupabaseSettingsRepository(sl()),
  );

  // Common - Notifications
  sl.registerLazySingleton<NotificationRepository>(
    () => SupabaseNotificationRepository(sl()),
  );

  // Repositories
  // ...
  // Data Sources
  // ...
}
