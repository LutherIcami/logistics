import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/profile_completion_banner.dart';

class BaseModulePage extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showBackButton;
  final String? backRoute;
  final Widget? floatingActionButton;

  const BaseModulePage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showBackButton = true,
    this.backRoute = '/admin',
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => context.go(backRoute ?? '/admin'),
              )
            : null,
        actions: [
          ...?actions,
          IconButton(
            icon: const Icon(Icons.dashboard_rounded),
            onPressed: () => context.go('/admin'),
            tooltip: 'Dashboard',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          const ProfileCompletionBanner(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
