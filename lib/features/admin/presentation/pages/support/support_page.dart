import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../base_module_page.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    const email = 'support@trucklogistics.com';
    const subject = 'Support Request';
    const body = 'Please describe your issue here';

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
    const url = 'tel:$phoneNumber';

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
    return BaseModulePage(
      title: 'Concierge Terminal',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeroSection(),
          const SizedBox(height: 32),
          _buildSupportSection(
            options: [
              _SupportOptionData(
                icon: Icons.forum_rounded,
                title: 'Intelligence Exchange',
                subtitle: 'Real-time assistant chat',
                color: Colors.blue,
                onTap: () => _showComingSoon(context, 'Live chat'),
              ),
              _SupportOptionData(
                icon: Icons.alternate_email_rounded,
                title: 'Data Correspondence',
                subtitle: 'support@logistics.com',
                color: Colors.teal,
                onTap: () => _launchEmail(context),
              ),
              _SupportOptionData(
                icon: Icons.support_agent_rounded,
                title: 'Voice Liaison',
                subtitle: '+254 700 000 000',
                color: Colors.indigo,
                onTap: () => _launchPhone(context),
              ),
              _SupportOptionData(
                icon: Icons.auto_stories_rounded,
                title: 'Knowledge Base',
                subtitle: 'System protocols & documentation',
                color: Colors.orange,
                onTap: () => _showComingSoon(context, 'FAQs'),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildSystemStatus(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.hub_rounded, size: 60, color: Color(0xFF1E293B)),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Command Support',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Operational assistance is available 24/7.',
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildSupportSection({required List<_SupportOptionData> options}) {
    return Container(
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
      child: Column(
        children: options.asMap().entries.map((entry) {
          final isLast = entry.key == options.length - 1;
          final option = entry.value;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: option.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(option.icon, color: option.color, size: 24),
                ),
                title: Text(
                  option.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  option.subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFFE2E8F0),
                ),
                onTap: option.onTap,
              ),
              if (!isLast)
                Divider(height: 1, color: Colors.grey[100], indent: 72),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Systems Operational',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Uptime: 99.98% over last 30 days',
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature is being initialized...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _SupportOptionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _SupportOptionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
