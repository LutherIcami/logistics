import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/fleet_models.dart';
import '../../providers/vehicle_provider.dart';
import '../base_module_page.dart';

class VehicleDiagnosticsPage extends StatefulWidget {
  const VehicleDiagnosticsPage({super.key});

  @override
  State<VehicleDiagnosticsPage> createState() => _VehicleDiagnosticsPageState();
}

class _VehicleDiagnosticsPageState extends State<VehicleDiagnosticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseModulePage(
      title: 'Vehicle Diagnostics',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => context.push('/admin/fleet/diagnostics/report'),
          tooltip: 'Report Issue',
        ),
      ],
      child: Consumer<VehicleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = provider.diagnosticReports;

          if (reports.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildDiagnosticCard(report);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.green[200]),
          const SizedBox(height: 16),
          Text(
            'All systems clear',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No vehicle issues reported.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/admin/fleet/diagnostics/report'),
            icon: const Icon(Icons.add),
            label: const Text('Report New Issue'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticCard(DiagnosticReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showReportDetails(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      report.vehicleRegistration,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  _buildStatusBadge(report.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.issueDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSeverityIndicator(report.severity),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(report.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DiagnosticStatus status) {
    Color color;
    switch (status) {
      case DiagnosticStatus.reported:
        color = Colors.orange;
      case DiagnosticStatus.inReview:
        color = Colors.blue;
      case DiagnosticStatus.scheduled:
        color = Colors.purple;
      case DiagnosticStatus.resolved:
        color = Colors.green;
      case DiagnosticStatus.dismissed:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSeverityIndicator(DiagnosticSeverity severity) {
    Color color;
    switch (severity) {
      case DiagnosticSeverity.low:
        color = Colors.green;
      case DiagnosticSeverity.medium:
        color = Colors.orange;
      case DiagnosticSeverity.high:
        color = Colors.red;
      case DiagnosticSeverity.critical:
        color = Colors.purple[900]!;
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          severity.name.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showReportDetails(DiagnosticReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ReportDetailsSheet(report: report),
    );
  }
}

class _ReportDetailsSheet extends StatelessWidget {
  final DiagnosticReport report;

  const _ReportDetailsSheet({required this.report});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        top: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Issue Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow('Vehicle', report.vehicleRegistration),
          _buildInfoRow('Reported By', report.reporterName),
          _buildInfoRow(
            'Date',
            DateFormat('MMMM dd, yyyy - hh:mm a').format(report.date),
          ),
          _buildInfoRow('Odometer', '${report.odometer.toStringAsFixed(0)} km'),
          const SizedBox(height: 24),
          const Text(
            'Issue Description',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            report.issueDescription,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          if (report.notes != null && report.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Additional Notes',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(report.notes!),
          ],
          const SizedBox(height: 32),
          if (report.status != DiagnosticStatus.resolved)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(
                    '/admin/fleet/maintenance/record?reportId=${report.id}&vehicleId=${report.vehicleId}',
                  );
                },
                icon: const Icon(Icons.build),
                label: const Text('Schedule for Repair'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
