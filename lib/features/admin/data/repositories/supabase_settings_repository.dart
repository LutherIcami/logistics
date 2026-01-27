import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/settings_model.dart';
import 'settings_repository.dart';

class SupabaseSettingsRepository implements SettingsRepository {
  final SupabaseClient client;

  SupabaseSettingsRepository(this.client);

  @override
  Future<SystemSettings> getSystemSettings() async {
    try {
      final response = await client
          .from('system_settings')
          .select()
          .eq('id', 1)
          .single();
      return SystemSettings.fromJson(response);
    } catch (e) {
      // Return default if table/row doesn't exist yet or query fails
      return SystemSettings();
    }
  }

  @override
  Future<void> updateSystemSettings(SystemSettings settings) async {
    try {
      await client.from('system_settings').upsert({
        'id': 1,
        ...settings.toJson(),
      });
    } catch (e) {
      throw Exception('Failed to update system settings: $e');
    }
  }
}
