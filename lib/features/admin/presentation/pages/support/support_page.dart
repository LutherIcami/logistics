import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    final email = 'support@trucklogistics.com';
    final subject = 'Support Request';
    final body = 'Please describe your issue here';

    final url =
        'mailto:$email?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(body)}';

    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch email client')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('An error occurred')));
      }
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    const phoneNumber = '+254700000000';
    final url = 'tel:$phoneNumber';

    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch phone app')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('An error occurred')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Center'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Need help? We\'re here for you!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildSupportOption(
              context: context,
              icon: Icons.chat_bubble_outline,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Live chat will be available soon'),
                  ),
                );
              },
            ),
            const Divider(),
            _buildSupportOption(
              context: context,
              icon: Icons.email_outlined,
              title: 'Email Us',
              subtitle: 'support@trucklogistics.com',
              onTap: () => _launchEmail(context),
            ),
            const Divider(),
            _buildSupportOption(
              context: context,
              icon: Icons.phone_in_talk_outlined,
              title: 'Call Us',
              subtitle: '+254 700 000 000',
              onTap: () => _launchPhone(context),
            ),
            const Divider(),
            _buildSupportOption(
              context: context,
              icon: Icons.help_outline,
              title: 'FAQs',
              subtitle: 'Find answers to common questions',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('FAQs will be available soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 32, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }
}
