import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/driver_trip_provider.dart';
import 'trips/trips_list_page.dart';
import 'profile/driver_profile_page.dart';
import 'earnings/earnings_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'notifications/notifications_page.dart';
import '../../../../core/widgets/responsive.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    final tripProvider = Provider.of<DriverTripProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null &&
        tripProvider.currentDriver == null &&
        !tripProvider.isLoading &&
        tripProvider.error == null) {
      // Use microtask to avoid calling notifyListeners during build/dependencies change phase
      Future.microtask(
        () => tripProvider.setCurrentDriver(authProvider.user!.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<DriverTripProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final authUser = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFFF9800),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _getAppBarTitle(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
                  ),
                ),
              ),
            ),
            actions: [
              _buildNotificationAction(tripProvider, authProvider, authUser),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  context.go('/login');
                },
              ),
            ],
          ),
        ],
        body: _buildContent(tripProvider, authProvider),
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
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationAction(
    DriverTripProvider tripProvider,
    AuthProvider authProvider,
    dynamic authUser,
  ) {
    int unreadCount = tripProvider.unreadNotificationCount;
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
        child: const Icon(Icons.notifications_outlined, color: Colors.white),
      ),
      onPressed: () {
        setState(() => _currentIndex = 4);
      },
    );
  }

  Widget _buildContent(DriverTripProvider provider, AuthProvider authProvider) {
    // Show loading only if we're still initializing
    if (provider.isLoading &&
        provider.currentDriver == null &&
        provider.trips.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If there's an error and no data, show error screen
    if (provider.error != null &&
        provider.currentDriver == null &&
        provider.trips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${provider.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final authUser = authProvider.user;
                  if (authUser != null) {
                    provider.setCurrentDriver(authUser.id);
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Always show the body - it will handle null cases internally
    return _buildBody(context, provider);
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'My Trips';
      case 2:
        return 'Earnings';
      case 3:
        return 'Profile';
      case 4:
        return 'Notifications';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildBody(BuildContext context, DriverTripProvider provider) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardView(context, provider);
      case 1:
        return const TripsListPage();
      case 2:
        return const EarningsPage();
      case 3:
        return const DriverProfilePage();
      case 4:
        return const NotificationsPage();
      default:
        return _buildDashboardView(context, provider);
    }
  }

  Widget _buildDashboardView(
    BuildContext context,
    DriverTripProvider provider,
  ) {
    final driver = provider.currentDriver;
    final authProvider = context.read<AuthProvider>();

    if (driver == null) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final authUser = context.watch<AuthProvider>().user;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off_rounded,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Identity Not Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                provider.error ??
                    'We couldn\'t find your driver records. This usually happens if your account was not fully provisioned.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (authUser != null)
                FilledButton.icon(
                  onPressed: () {
                    provider.initializeDriverProfile(
                      authUser.fullName,
                      authUser.email,
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Initialize Driver Profile'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  if (authProvider.user != null) {
                    provider.setCurrentDriver(authProvider.user!.id);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Authorization'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              _buildWelcomeCard(driver),
              const SizedBox(height: 12),

              // Maintenance Alert
              if (provider.hasMaintenanceAlert) ...[
                _buildMaintenanceBanner(provider),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 24),

              // Quick Stats
              Text(
                'OVERVIEW',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatsGrid(provider, driver),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'QUICK ACTIONS',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(provider),
              const SizedBox(height: 24),

              // New Assignments (Pending Action)
              if (provider.assignedTrips.isNotEmpty) ...[
                Text(
                  'NEW MISSION',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ...provider.assignedTrips.map(
                  (trip) => _NewMissionCard(trip: trip),
                ),
                const SizedBox(height: 24),
              ],

              // Active Trip (In Transit)
              if (provider.inTransitTrips.isNotEmpty) ...[
                Text(
                  'ACTIVE TRIP',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _ActiveTripCard(trip: provider.inTransitTrips.first),
                const SizedBox(height: 24),
              ],

              // Recent Trips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT TRIPS',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (provider.trips.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No trips assigned yet'),
                  ),
                )
              else
                ...provider.trips.take(3).map((trip) => _TripCard(trip: trip)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(dynamic driver) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.orange.shade100,
                child: Text(
                  driver.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    driver.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: driver.status == 'active'
                                ? Colors.greenAccent
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                            boxShadow: driver.status == 'active'
                                ? [
                                    BoxShadow(
                                      color: Colors.greenAccent.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          driver.statusDisplayText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star, color: Colors.amber, size: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  driver.rating.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Rating',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceBanner(DriverTripProvider provider) {
    final vehicle = provider.assignedVehicle;
    if (vehicle == null) return const SizedBox.shrink();

    final urgency = vehicle.maintenanceUrgency;
    final isCritical = urgency == 'critical' || urgency == 'high';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical ? Colors.red.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCritical
                ? Icons.error_outline_rounded
                : Icons.warning_amber_rounded,
            color: isCritical ? Colors.red : Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCritical ? 'CRITICAL MAINTENANCE' : 'MAINTENANCE DUE',
                  style: TextStyle(
                    color: isCritical
                        ? Colors.red.shade900
                        : Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${vehicle.displayName} needs attention.',
                  style: TextStyle(
                    color: isCritical
                        ? Colors.red.shade700
                        : Colors.orange.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    isCritical ? 'Urgent Maintenance' : 'Maintenance Schedule',
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vehicle: ${vehicle.displayName}'),
                      if (vehicle.nextMaintenanceDate != null)
                        Text(
                          'Next Due: ${vehicle.nextMaintenanceDate.toString().split(' ')[0]}',
                        ),
                      if (vehicle.lastMaintenanceDate != null)
                        Text(
                          'Last Service: ${vehicle.lastMaintenanceDate.toString().split(' ')[0]}',
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Please visit the workshop immediately or contact dispatch over the phone.',
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        final Uri launchUri = Uri(
                          scheme: 'tel',
                          path: '0700000000',
                        ); // Replace with actual dispatch number
                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        }
                      },
                      icon: const Icon(Icons.call),
                      label: const Text('Call Dispatch'),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              'VIEW',
              style: TextStyle(
                color: isCritical ? Colors.red : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DriverTripProvider provider, dynamic driver) {
    var stats = [
      _StatCard(
        title: 'Active',
        value: '${provider.activeTrips}',
        icon: Icons.local_shipping,
        color: Colors.blue,
      ),
      _StatCard(
        title: 'Completed',
        value: '${provider.completedTrips.length}',
        icon: Icons.check_circle,
        color: Colors.green,
      ),
      _StatCard(
        title: 'This Week',
        value: 'KES ${(provider.weekEarnings / 1000).toStringAsFixed(1)}k',
        icon: Icons.attach_money,
        color: Colors.orange,
      ),
      _StatCard(
        title: 'Distance',
        value: '${provider.totalDistance.toStringAsFixed(0)} km',
        icon: Icons.straighten,
        color: Colors.purple,
      ),
    ];

    return Responsive(
      mobile: Column(
        children: [
          Row(
            children: [
              Expanded(child: stats[0]),
              const SizedBox(width: 12),
              Expanded(child: stats[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: stats[2]),
              const SizedBox(width: 12),
              Expanded(child: stats[3]),
            ],
          ),
        ],
      ),
      desktop: Row(
        children: stats
            .map(
              (s) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: s,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildQuickActions(DriverTripProvider provider) {
    var actions = [
      _ActionCard(
        title: 'Fuel Report',
        icon: Icons.local_gas_station_rounded,
        color: Colors.orange,
        onTap: () => context.push('/driver/fuel-report'),
      ),
      _ActionCard(
        title: 'Service/Repair',
        icon: Icons.build_rounded,
        color: Colors.blue,
        onTap: () => context.push('/driver/maintenance-report'),
      ),
      _ActionCard(
        title: 'Support',
        icon: Icons.headset_mic,
        color: Colors.green,
        onTap: () async {
          final Uri launchUri = Uri(scheme: 'tel', path: '0700000000');
          if (await canLaunchUrl(launchUri)) {
            await launchUrl(launchUri);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cannot launch dialer')),
              );
            }
          }
        },
      ),
    ];

    return Responsive(
      mobile: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: actions
              .map(
                (a) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(width: 120, child: a),
                ),
              )
              .toList(),
        ),
      ),
      desktop: Row(
        children: actions
            .map(
              (a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: a,
                ),
              ),
            )
            .toList(),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
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

class _ActiveTripCard extends StatelessWidget {
  final dynamic trip;

  const _ActiveTripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: InkWell(
        onTap: () => context.push('/driver/trips/${trip.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_shipping, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'In Transit',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          trip.customerName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/driver/trips/${trip.id}'),
                    icon: const Icon(Icons.navigation, size: 18),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To: ${trip.deliveryLocation}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (trip.estimatedDelivery != null)
                          Text(
                            'ETA: ${_formatETA(trip.estimatedDelivery!)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trip.estimatedEarnings != null)
                    Text(
                      'KES ${trip.estimatedEarnings!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatETA(DateTime eta) {
    final diff = eta.difference(DateTime.now());
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }
}

class _NewMissionCard extends StatelessWidget {
  final dynamic trip;

  const _NewMissionCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.orange.withValues(alpha: 0.2),
      color: const Color(0xFFFFF7ED),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFED7AA), width: 1),
      ),
      child: InkWell(
        onTap: () => context.push('/driver/trips/${trip.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'NEW ASSIGNMENT',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trip.estimatedEarnings != null)
                    Text(
                      'KES ${trip.estimatedEarnings!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                trip.customerName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'From: ${trip.pickupLocation}',
                      style: const TextStyle(color: Color(0xFF475569)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.flag, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'To: ${trip.deliveryLocation}',
                      style: const TextStyle(color: Color(0xFF475569)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push('/driver/trips/${trip.id}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => context.push('/driver/trips/${trip.id}'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Start Trip'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final dynamic trip;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/driver/trips/${trip.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      trip.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: trip.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trip.statusDisplayText,
                      style: TextStyle(
                        color: trip.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${trip.pickupLocation} → ${trip.deliveryLocation}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (trip.estimatedEarnings != null) ...[
                const SizedBox(height: 8),
                Text(
                  'KES ${trip.estimatedEarnings!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
