import 'package:flutter/material.dart';
import '../../domain/models/settings_model.dart';
import '../../data/repositories/settings_repository.dart';
import '../../../../app/di/injection_container.dart' as di;

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;

  bool _isLoading = false;
  String? _error;
  SystemSettings _systemSettings = SystemSettings();

  // Local UI settings
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _language = 'English';

  bool get isLoading => _isLoading;
  String? get error => _error;
  SystemSettings get systemSettings => _systemSettings;
  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;

  SettingsProvider() : _repository = di.sl<SettingsRepository>() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _systemSettings = await _repository.getSystemSettings();
      // In a real app, we'd load local UI settings from shared_preferences
      _error = null;
    } catch (e) {
      _error = 'Failed to load settings';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSystemSettings(SystemSettings newSettings) async {
    try {
      await _repository.updateSystemSettings(newSettings);
      _systemSettings = newSettings;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update system settings';
      notifyListeners();
      return false;
    }
  }

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
    // In a real app, save to shared_preferences
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }
}
