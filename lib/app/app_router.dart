import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/home/presentation/pages/home_page.dart';

import '../features/admin/presentation/pages/admin_dashboard.dart';
import '../features/admin/presentation/pages/drivers/drivers_page.dart';
import '../features/admin/presentation/pages/drivers/driver_detail_page.dart';
import '../features/admin/presentation/pages/drivers/driver_form_page.dart';
import '../features/admin/presentation/pages/fleet_management/fleet_dashboard_page.dart';
import '../features/admin/presentation/pages/fleet_management/fleet_maintenance_page.dart';
import '../features/admin/presentation/pages/fleet_management/vehicles/vehicles_list_page.dart';
import '../features/admin/presentation/pages/fleet_management/vehicles/vehicle_detail_page.dart';
import '../features/admin/presentation/pages/fleet_management/vehicles/vehicle_form_page.dart';
import '../features/admin/presentation/pages/fleet_management/record_fuel_log_page.dart';
import '../features/admin/presentation/pages/fleet_management/record_maintenance_log_page.dart';
import '../features/admin/presentation/pages/shipments/shipments_page.dart';
import '../features/admin/presentation/pages/shipments/shipment_detail_page.dart';
import '../features/admin/presentation/pages/shipments/shipment_form_page.dart';
import '../features/admin/presentation/pages/shipments/assign_driver_page.dart';
import '../features/admin/presentation/pages/customers/customers_page.dart';
import '../features/admin/presentation/pages/customers/customer_detail_page.dart';
import '../features/admin/presentation/pages/customers/customer_form_page.dart';
import '../features/admin/presentation/pages/finance/finance_page.dart';
import '../features/admin/presentation/pages/finance/invoices/invoices_list_page.dart';
import '../features/admin/presentation/pages/finance/invoices/invoice_form_page.dart';
import '../features/admin/presentation/pages/finance/invoices/invoice_detail_page.dart';
import '../features/admin/presentation/pages/finance/invoices/order_selection_page.dart';
import '../features/admin/presentation/pages/finance/transactions_list_page.dart';
import '../features/admin/presentation/pages/finance/transaction_form_page.dart';
import '../features/admin/presentation/pages/reports/reports_page.dart';
import '../features/admin/presentation/pages/reports/financial_report_page.dart';
import '../features/admin/presentation/pages/reports/shipment_analytics_page.dart';
import '../features/admin/presentation/pages/reports/driver_performance_page.dart';
import '../features/admin/presentation/pages/notifications/admin_notifications_page.dart';
import '../features/admin/presentation/pages/settings/settings_page.dart';
import '../features/admin/presentation/pages/support/support_page.dart';
import '../features/driver/presentation/pages/driver_dashboard.dart';
import '../features/driver/presentation/pages/trips/trip_detail_page.dart';
import '../features/driver/presentation/pages/profile/driver_edit_form_page.dart';
import '../features/driver/presentation/pages/fleet/fuel_report_page.dart';
import '../features/driver/presentation/pages/fleet/maintenance_report_page.dart';
import '../features/customer/presentation/pages/customer_dashboard.dart';
import '../features/customer/presentation/pages/orders/order_detail_page.dart';
import '../features/customer/presentation/pages/orders/new_order_form_page.dart';
import '../features/customer/presentation/pages/profile/customer_edit_form_page.dart';

import '../features/chat/presentation/pages/chat_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
      routes: [
        GoRoute(
          path: 'chat/:orderId',
          builder: (context, state) => ChatPage(
            orderId: state.pathParameters['orderId']!,
            currentUserRole: 'admin',
          ),
        ),
        GoRoute(
          path: 'drivers',
          builder: (context, state) => const DriversPage(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const DriverFormPage(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  DriverDetailPage(driverId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: ':id/edit',
              builder: (context, state) =>
                  DriverFormPage(driverId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'fleet',
          builder: (context, state) => const FleetDashboardPage(),
          routes: [
            GoRoute(
              path: 'vehicles',
              builder: (context, state) => const VehiclesListPage(),
            ),
            GoRoute(
              path: 'maintenance',
              builder: (context, state) => const FleetMaintenancePage(),
              routes: [
                GoRoute(
                  path: 'record-fuel',
                  builder: (context, state) => const RecordFuelLogPage(),
                ),
                GoRoute(
                  path: 'record-service',
                  builder: (context, state) => const RecordMaintenanceLogPage(),
                ),
              ],
            ),
            GoRoute(
              path: 'vehicles/add',
              builder: (context, state) => const VehicleFormPage(),
            ),
            GoRoute(
              path: 'vehicles/:id',
              builder: (context, state) =>
                  VehicleDetailPage(vehicleId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'vehicles/:id/edit',
              builder: (context, state) =>
                  VehicleFormPage(vehicleId: state.pathParameters['id']!),
            ),
          ],
        ),
        // Shipments Routes
        GoRoute(
          path: 'shipments',
          builder: (context, state) => const ShipmentsPage(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const ShipmentFormPage(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => ShipmentDetailAdminPage(
                shipmentId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: ':id/edit',
              builder: (context, state) =>
                  ShipmentFormPage(shipmentId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: ':id/assign',
              builder: (context, state) =>
                  AssignDriverPage(shipmentId: state.pathParameters['id']!),
            ),
          ],
        ),
        // Customers Routes
        GoRoute(
          path: 'customers',
          builder: (context, state) => const CustomersPage(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const CustomerFormAdminPage(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => CustomerDetailAdminPage(
                customerId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: ':id/edit',
              builder: (context, state) => CustomerFormAdminPage(
                customerId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        // Finance Routes
        GoRoute(
          path: 'finance',
          builder: (context, state) => const FinancePage(),
          routes: [
            GoRoute(
              path: 'invoices',
              builder: (context, state) => const InvoicesListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const InvoiceFormPage(),
                ),
                GoRoute(
                  path: 'from-order',
                  builder: (context, state) => const OrderSelectionPage(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      InvoiceDetailPage(invoiceId: state.pathParameters['id']!),
                ),
              ],
            ),
            GoRoute(
              path: 'transactions',
              builder: (context, state) => const TransactionsListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const TransactionFormPage(),
                ),
              ],
            ),
          ],
        ),
        // Reports Routes
        GoRoute(
          path: 'reports',
          builder: (context, state) => const ReportsPage(),
          routes: [
            GoRoute(
              path: 'financial',
              builder: (context, state) => const FinancialReportPage(),
            ),
            GoRoute(
              path: 'shipments',
              builder: (context, state) => const ShipmentAnalyticsPage(),
            ),
            GoRoute(
              path: 'driver-performance',
              builder: (context, state) => const DriverPerformancePage(),
            ),
          ],
        ),
        // Notifications
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const AdminNotificationsPage(),
        ),
        // Settings Routes
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
        // Support Routes
        GoRoute(
          path: 'support',
          builder: (context, state) => const SupportPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/driver',
      builder: (context, state) => const DriverDashboard(),
      routes: [
        GoRoute(
          path: 'trips/:id',
          builder: (context, state) =>
              TripDetailPage(tripId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'chat/:orderId',
          builder: (context, state) => ChatPage(
            orderId: state.pathParameters['orderId']!,
            currentUserRole: 'driver',
          ),
        ),
        GoRoute(
          path: 'profile/edit',
          builder: (context, state) => const DriverEditFormPage(),
        ),
        GoRoute(
          path: 'fuel-report',
          builder: (context, state) => const FuelReportPage(),
        ),
        GoRoute(
          path: 'maintenance-report',
          builder: (context, state) => const MaintenanceReportPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/customer',
      builder: (context, state) => const CustomerDashboard(),
      routes: [
        GoRoute(
          path: 'orders/new',
          builder: (context, state) => const NewOrderFormPage(),
        ),
        GoRoute(
          path: 'orders/:id',
          builder: (context, state) =>
              OrderDetailPage(orderId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'chat/:orderId',
          builder: (context, state) => ChatPage(
            orderId: state.pathParameters['orderId']!,
            currentUserRole: 'customer',
          ),
        ),
        GoRoute(
          path: 'profile/edit',
          builder: (context, state) => const CustomerEditFormPage(),
        ),
      ],
    ),
  ],
);
