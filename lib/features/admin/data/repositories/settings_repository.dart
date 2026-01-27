import '../../domain/models/settings_model.dart';

abstract class SettingsRepository {
  Future<SystemSettings> getSystemSettings();
  Future<void> updateSystemSettings(SystemSettings settings);
}
