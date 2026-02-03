import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../base_module_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _downloadLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>().systemSettings;
      _downloadLinkController.text = settings.driverDownloadLink;
    });
  }

  @override
  void dispose() {
    _downloadLinkController.dispose();
    super.dispose();
  }

  Future<void> _saveSystemSettings() async {
    final provider = context.read<SettingsProvider>();
    final newSettings = provider.systemSettings.copyWith(
      driverDownloadLink: _downloadLinkController.text.trim(),
    );

    final success = await provider.updateSystemSettings(newSettings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'System configuration synchronized'
                : 'Failed to update system settings',
          ),
          backgroundColor: success ? Colors.green[600] : Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseModulePage(
      title: 'Console Core',
      child: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSectionTitle('Platform Configuration'),
              const SizedBox(height: 16),
              _buildSettingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Driver Application Distribution',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Define the binary repository for onboarded flight staff.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _downloadLinkController,
                        decoration: const InputDecoration(
                          hintText: 'https://cdn.logistics.com/driver-v1.apk',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          prefixIcon: Icon(
                            Icons.link_rounded,
                            size: 20,
                            color: Colors.blue,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: provider.isLoading
                            ? null
                            : _saveSystemSettings,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                        label: const Text('Update Repository Link'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Interface Preferences'),
              const SizedBox(height: 16),
              _buildSettingsCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Global Notifications',
                      subtitle: 'Push alerts for critical fleet events',
                      value: provider.notificationsEnabled,
                      icon: Icons.notifications_active_rounded,
                      color: Colors.orange,
                      onChanged: provider.setNotificationsEnabled,
                    ),
                    Divider(height: 1, color: Colors.grey[100], indent: 60),
                    _buildSwitchTile(
                      title: 'High Contrast Mode',
                      subtitle: 'Optimize for low-light environments',
                      value: provider.darkMode,
                      icon: Icons.dark_mode_rounded,
                      color: Colors.indigo,
                      onChanged: provider.setDarkMode,
                    ),
                    Divider(height: 1, color: Colors.grey[100], indent: 60),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: _buildIconFrame(
                        Icons.language_rounded,
                        Colors.teal,
                      ),
                      title: const Text(
                        'System Language',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        provider.language,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xFFE2E8F0),
                      ),
                      onTap: () => _showLanguageDialog(provider),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('System Information'),
              const SizedBox(height: 16),
              _buildSettingsCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: _buildIconFrame(Icons.verified_rounded, Colors.blue),
                  title: const Text(
                    'About Logistics Pro',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Version 1.2.4 (Stable Build)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  trailing: const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                  onTap: () => _showAboutDialog(context),
                ),
              ),
              const SizedBox(height: 60),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(24),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildIconFrame(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
      ),
      secondary: _buildIconFrame(icon, color),
      activeThumbColor: const Color(0xFF1E293B),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Logistics Pro',
      applicationVersion: '1.2.4',
      applicationIcon: _buildIconFrame(
        Icons.local_shipping_rounded,
        Colors.blue,
      ),
      applicationLegalese:
          'Copyright © 2024 Logos Logistics. All rights reserved.',
    );
  }

  void _showLanguageDialog(SettingsProvider provider) {
    final languages = ['English', 'Swahili', 'French', 'Spanish'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Display Language',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: RadioGroup<String>(
            groupValue: provider.language,
            onChanged: (String? value) {
              if (value != null) {
                provider.setLanguage(value);
                Navigator.pop(context);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: languages
                  .map(
                    (lang) => RadioListTile<String>(
                      title: Text(lang, style: const TextStyle(fontSize: 15)),
                      value: lang,
                      activeColor: Colors.blue,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
