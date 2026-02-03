import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/customer_order_provider.dart';
import 'notifications/customer_notifications_page.dart';
import 'orders/orders_list_page.dart';
import 'tracking/tracking_page.dart';
import 'invoices/invoices_page.dart';
import 'support/support_page.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<CustomerOrderProvider>().initializeCustomer(
          authProvider.user!.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerOrderProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(context, provider),
        ],
        body: _buildMainContent(context, provider),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Tracking',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Invoices',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent_outlined),
            selectedIcon: Icon(Icons.support_agent),
            label: 'Support',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/customer/orders/new'),
              icon: const Icon(Icons.add),
              label: const Text('New Order'),
              backgroundColor: const Color(0xFF0891B2),
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildAppBar(BuildContext context, CustomerOrderProvider provider) {
    final authProvider = Provider.of<AuthProvider>(context);
    final authUser = authProvider.user;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0891B2),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  size: 200,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.teal.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'CUSTOMER PORTAL',
                        style: TextStyle(
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome back,',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    Text(
                      provider.currentCustomer?.name ?? 'Valued Customer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        _buildNotificationAction(provider, authProvider, authUser),
        IconButton(
          icon: const Icon(
            Icons.power_settings_new_rounded,
            color: Colors.redAccent,
          ),
          onPressed: () {
            context.read<AuthProvider>().logout();
            context.go('/login');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    CustomerOrderProvider provider,
  ) {
    if (provider.isLoading && provider.currentCustomer == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.currentCustomer == null) {
      return _buildErrorState(context, provider);
    }

    return _buildBodyContent(context, provider);
  }

  Widget _buildNotificationAction(
    CustomerOrderProvider provider,
    AuthProvider authProvider,
    dynamic authUser,
  ) {
    int unreadCount = provider.unreadNotificationCount;
    if (authUser != null &&
        !authUser.isProfileComplete &&
        !authProvider.isNotificationRead('profile-incomplete')) {
      unreadCount++;
    }

    return IconButton(
      icon: Badge(
        label: Text('$unreadCount'),
        isLabelVisible: unreadCount > 0,
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.notifications_none_rounded,
          color: Colors.white70,
        ),
      ),
      onPressed: () {
        setState(() => _currentIndex = 5);
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    CustomerOrderProvider provider,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Flexible(
            child: Text(
              'Error: ${provider.error}',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.user != null) {
                provider.initializeCustomer(authProvider.user!.id);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    CustomerOrderProvider provider,
  ) {
    switch (_currentIndex) {
      case 0:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _buildDashboardView(context, provider),
        );
      case 1:
        return const OrdersListPage();
      case 2:
        return const TrackingPage();
      case 3:
        return const InvoicesPage();
      case 4:
        return const SupportPage();
      case 5:
        return const CustomerNotificationsPage();
      default:
        return _buildDashboardView(context, provider);
    }
  }

  Widget _buildDashboardView(
    BuildContext context,
    CustomerOrderProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Overview'),
        const SizedBox(height: 16),
        _buildStatsGrid(provider),
        const SizedBox(height: 32),

        _buildSectionTitle('Quick Actions'),
        const SizedBox(height: 16),
        _buildQuickActions(context, provider),
        const SizedBox(height: 32),

        // Active Shipment Preview
        if (provider.activeOrders.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Active Shipments'),
              TextButton(
                onPressed: () => setState(() => _currentIndex = 2),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ActiveShipmentCard(order: provider.activeOrders.first),
          const SizedBox(height: 32),
        ],

        // Recent Orders
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Recent Orders'),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.orders.isEmpty)
          _buildEmptyOrdersState()
        else
          ...provider.orders
              .take(3)
              .map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OrderCard(order: order),
                ),
              ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
        letterSpacing: 1.5,
      ),
    );
  }

  // NOTE: removed _buildWelcomeCard as logic moved to AppBar

  Widget _buildStatsGrid(CustomerOrderProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatCard(
            title: 'Active Orders',
            value: '${provider.activeOrdersCount}',
            icon: Icons.local_shipping_outlined,
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          _StatCard(
            title: 'Pending',
            value: '${provider.pendingOrdersCount}',
            icon: Icons.pending_actions_outlined,
            color: Colors.orange,
          ),
          const SizedBox(width: 16),
          _StatCard(
            title: 'Total Spent',
            value: 'KES ${(provider.totalSpent / 1000).toStringAsFixed(1)}k',
            icon: Icons.account_balance_wallet_outlined,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    CustomerOrderProvider provider,
  ) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: 'New Order',
            icon: Icons.add_circle_outline,
            color: Colors.teal,
            onTap: () => context.push('/customer/orders/new'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            title: 'Track',
            icon: Icons.gps_fixed,
            color: Colors.blue,
            onTap: () => setState(() => _currentIndex = 2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            title: 'Invoices',
            icon: Icons.receipt_long_outlined,
            color: Colors.deepPurple,
            onTap: () => setState(() => _currentIndex = 3),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyOrdersState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first order to get started',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/customer/orders/new'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Order'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0891B2),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveShipmentCard extends StatelessWidget {
  final dynamic order;

  const _ActiveShipmentCard({required this.order});

  @override
  Widget build(BuildContext context) {
    // Determine status colors matching typical admin styles
    Color statusColor;
    if (order.isInTransit) {
      statusColor = Colors.blue;
    } else if (order.isPending) {
      statusColor = Colors.orange;
    } else if (order.isDelivered) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.statusDisplayText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Order #${order.id}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (order.estimatedDelivery != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatETA(order.estimatedDelivery!),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // Timeline-like view
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LocationRow(
                        icon: Icons.circle,
                        color: Colors.blue,
                        text: order.pickupLocation,
                        isStart: true,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        height: 16,
                        width: 2,
                        color: Colors.grey[200],
                      ),
                      _LocationRow(
                        icon: Icons.location_on,
                        color: Colors.red,
                        text: order.deliveryLocation,
                        isStart: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => context.push('/customer/orders/${order.id}'),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF0891B2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatETA(DateTime eta) {
    final diff = eta.difference(DateTime.now());
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final bool isStart;

  const _LocationRow({
    required this.icon,
    required this.color,
    required this.text,
    required this.isStart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final dynamic order;

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (order.isDelivered) {
      statusColor = Colors.green;
    } else if (order.isCancelled) {
      statusColor = Colors.red;
    } else if (order.isPending) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.blue;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFF64748B),
          ),
        ),
        title: Text(
          order.cargoType,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontFamily: 'Inter',
            ),
            children: [
              TextSpan(
                text:
                    '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id} • ',
              ),
              TextSpan(
                text: order.statusDisplayText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[300]),
        onTap: () => context.push('/customer/orders/${order.id}'),
      ),
    );
  }
}
