import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import 'app_router.dart';
import '../features/admin/presentation/providers/driver_provider.dart';
import '../features/admin/presentation/providers/vehicle_provider.dart';
import '../features/driver/presentation/providers/driver_trip_provider.dart';
import '../features/customer/presentation/providers/customer_order_provider.dart';
import '../features/admin/presentation/providers/admin_customer_provider.dart';
import '../features/admin/presentation/providers/shipment_provider.dart';
import '../features/admin/presentation/providers/finance_provider.dart';
import '../features/admin/presentation/providers/reports_provider.dart';
import '../features/admin/presentation/providers/settings_provider.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'di/injection_container.dart' as di;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('APP_DEBUG: Building App widget...');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(
          create: (_) => DriverProvider()..loadInitialDrivers(),
        ),
        ChangeNotifierProvider(
          create: (_) => VehicleProvider()..loadInitialVehicles(),
        ),
        ChangeNotifierProvider(create: (_) => DriverTripProvider()),
        ChangeNotifierProvider(create: (_) => CustomerOrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminCustomerProvider()),
        ChangeNotifierProvider(create: (_) => ShipmentProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp.router(
        title: 'Flutter App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
