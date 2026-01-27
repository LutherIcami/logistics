import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/customer_order_provider.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerOrderProvider>(
      builder: (context, provider, _) {
        final customer = provider.currentCustomer;
        if (customer == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header with gradient
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.teal.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Avatar with initials
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(customer.companyName ?? customer.name),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Company/Customer Name
                      Text(
                        customer.companyName ?? customer.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (customer.companyName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          customer.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Account Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              customer.companyName != null
                                  ? Icons.business_rounded
                                  : Icons.person_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              customer.companyName != null
                                  ? 'Business Account'
                                  : 'Individual Account',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Location
                      if (customer.city != null || customer.country != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${customer.city ?? ''}, ${customer.country ?? ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Orders',
                      value: '${customer.totalOrders}',
                      icon: Icons.shopping_bag_rounded,
                      color: Colors.blue,
                      suffix: 'total',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Spent',
                      value:
                          'KES ${(customer.totalSpent / 1000).toStringAsFixed(0)}k',
                      icon: Icons.payments_rounded,
                      color: Colors.green,
                      suffix: 'lifetime',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Active',
                      value: '${provider.activeOrdersCount}',
                      icon: Icons.local_shipping_rounded,
                      color: Colors.orange,
                      suffix: 'in progress',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Contact Information Section
              _SectionHeader(
                title: 'Contact Information',
                icon: Icons.contact_mail_rounded,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _ProfileInfoTile(
                        icon: Icons.email_rounded,
                        label: 'Email Address',
                        value: customer.email,
                        iconColor: Colors.red,
                      ),
                      const Divider(height: 1, indent: 56),
                      _ProfileInfoTile(
                        icon: Icons.phone_rounded,
                        label: 'Phone Number',
                        value: customer.phone,
                        iconColor: Colors.green,
                      ),
                      if (customer.address != null) ...[
                        const Divider(height: 1, indent: 56),
                        _ProfileInfoTile(
                          icon: Icons.home_rounded,
                          label: 'Street Address',
                          value: customer.address!,
                          iconColor: Colors.purple,
                        ),
                      ],
                      if (customer.city != null ||
                          customer.country != null) ...[
                        const Divider(height: 1, indent: 56),
                        _ProfileInfoTile(
                          icon: Icons.public_rounded,
                          label: 'City / Country',
                          value:
                              '${customer.city ?? 'N/A'}, ${customer.country ?? 'N/A'}',
                          iconColor: Colors.blue,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Account Information Section
              _SectionHeader(
                title: 'Account Details',
                icon: Icons.account_circle_rounded,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _ProfileInfoTile(
                        icon: Icons.calendar_month_rounded,
                        label: 'Member Since',
                        value: DateFormat(
                          'MMMM dd, yyyy',
                        ).format(customer.joinDate),
                        iconColor: Colors.teal,
                      ),
                      if (customer.companyName != null) ...[
                        const Divider(height: 1, indent: 56),
                        _ProfileInfoTile(
                          icon: Icons.business_center_rounded,
                          label: 'Company Name',
                          value: customer.companyName!,
                          iconColor: Colors.indigo,
                        ),
                      ],
                      const Divider(height: 1, indent: 56),
                      _ProfileInfoTile(
                        icon: Icons.verified_user_rounded,
                        label: 'Account Status',
                        value: 'Verified',
                        iconColor: Colors.green,
                        trailing: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Edit Profile Button
              FilledButton.icon(
                onPressed: () => context.push('/customer/profile/edit'),
                icon: const Icon(Icons.edit_rounded),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? suffix;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          if (suffix != null)
            Text(
              suffix!,
              style: TextStyle(fontSize: 9, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Widget? trailing;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
