import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> _languages = ['English', 'Swahili', 'French', 'Spanish'];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'General Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: settingsProvider.notificationsEnabled,
            onChanged: (bool value) {
              settingsProvider.setNotificationsEnabled(value);
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settingsProvider.darkMode,
            onChanged: (bool value) {
              settingsProvider.setDarkMode(value);
            },
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(settingsProvider.language),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(settingsProvider),
          ),

          if (isAdmin) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'System Configuration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Base Order Rate'),
              subtitle: Text(
                'KES ${settingsProvider.systemSettings.baseOrderRate}',
              ),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: () => _editSystemSetting(
                'Base Order Rate',
                settingsProvider.systemSettings.baseOrderRate.toString(),
                (val) => settingsProvider.updateSystemSettings(
                  settingsProvider.systemSettings.copyWith(
                    baseOrderRate: double.tryParse(val),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.straighten),
              title: const Text('Distance Rate (per km)'),
              subtitle: Text(
                'KES ${settingsProvider.systemSettings.distanceRate}',
              ),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: () => _editSystemSetting(
                'Distance Rate',
                settingsProvider.systemSettings.distanceRate.toString(),
                (val) => settingsProvider.updateSystemSettings(
                  settingsProvider.systemSettings.copyWith(
                    distanceRate: double.tryParse(val),
                  ),
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Enable Public Registration'),
              subtitle: const Text('Allow new users to sign up'),
              value: settingsProvider.systemSettings.enableRegistration,
              onChanged: (bool value) {
                settingsProvider.updateSystemSettings(
                  settingsProvider.systemSettings.copyWith(
                    enableRegistration: value,
                  ),
                );
              },
            ),
          ],

          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Account Security',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile Settings'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile settings coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset link sent to email'),
                ),
              );
            },
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About App'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Logistics Pro',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.local_shipping, size: 48),
                children: [const Text('Complete Logistics Management System.')],
              );
            },
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().logout();
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Logout'),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _showLanguageDialog(SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                return RadioListTile<String>(
                  title: Text(language),
                  value: language,
                  groupValue: provider.language,
                  onChanged: (String? value) {
                    if (value != null) {
                      provider.setLanguage(value);
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _editSystemSetting(
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: title,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }
}
