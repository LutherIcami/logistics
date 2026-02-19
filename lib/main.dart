import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'app/app_router.dart';
import 'app/di/injection_container.dart' as di;
import 'core/constants/app_constants.dart';

void main() async {
  debugPrint('MAIN: App starting...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('MAIN: Widgets initialized');

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  debugPrint('MAIN: Supabase initialized');

  // CRITICAL: Start listening for the recovery signal IMMEDIATELY
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    debugPrint('AUTH_DEBUG: Event: ${data.event}');
    if (data.event == AuthChangeEvent.passwordRecovery) {
      debugPrint('AUTH_DEBUG: RECOVERY SIGNAL RECEIVED! Waiting for router...');
      Future.delayed(const Duration(milliseconds: 1000), () {
        debugPrint('AUTH_DEBUG: Navigating to /reset-password now!');
        appRouter.go('/reset-password');
      });
    }
  });

  await di.init();
  debugPrint('MAIN: DI initialized');

  runApp(const App());
}
