import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseModulePage extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showBackButton;
  final String? backRoute;

  const BaseModulePage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showBackButton = true,
    this.backRoute = '/admin',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(backRoute ?? '/admin'),
              )
            : null,
        actions: [
          ...?actions,
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/admin'),
          ),
        ],
      ),
      body: child,
    );
  }
}
