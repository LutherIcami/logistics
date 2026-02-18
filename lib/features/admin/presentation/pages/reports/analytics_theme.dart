import 'package:flutter/material.dart';

/// Centralized theme and styling constants for all analytics pages
class AnalyticsTheme {
  // Color Palette - Modern, vibrant, and professional
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color primaryOrange = Color(0xFFF59E0B);
  static const Color primaryRed = Color(0xFFEF4444);
  static const Color primaryTeal = Color(0xFF14B8A6);
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color primaryCyan = Color(0xFF06B6D4);

  // Status Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusConfirmed = Color(0xFF3B82F6);
  static const Color statusInTransit = Color(0xFF8B5CF6);
  static const Color statusDelivered = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);

  // Neutral Colors
  static const Color backgroundGray = Color(0xFFF8FAFC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMedium = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Chart Colors - Harmonious palette
  static final List<Color> chartColors = [
    primaryBlue,
    primaryPurple,
    primaryGreen,
    primaryOrange,
    primaryTeal,
    primaryIndigo,
    primaryPink,
    primaryCyan,
  ];

  // Expense Category Colors
  static const Map<String, Color> expenseColors = {
    'fuel': Color(0xFFF59E0B),
    'maintenance': Color(0xFFEF4444),
    'salaries': Color(0xFF3B82F6),
    'insurance': Color(0xFF8B5CF6),
    'other': Color(0xFF6B7280),
  };

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textDark,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  static const TextStyle bodyLarge = TextStyle(fontSize: 16, color: textMedium);

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textMedium,
  );

  static const TextStyle bodySmall = TextStyle(fontSize: 12, color: textLight);

  static const TextStyle labelBold = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: textLight,
    letterSpacing: 1.2,
  );

  // Helper Methods
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'confirmed':
        return statusConfirmed;
      case 'in_transit':
      case 'in transit':
        return statusInTransit;
      case 'delivered':
        return statusDelivered;
      case 'cancelled':
        return statusCancelled;
      default:
        return textLight;
    }
  }

  static Color getExpenseColor(String category) {
    return expenseColors[category.toLowerCase()] ?? textLight;
  }

  static Color getRatingColor(double rating) {
    if (rating >= 4.5) return primaryGreen;
    if (rating >= 4.0) return primaryBlue;
    if (rating >= 3.5) return primaryOrange;
    return primaryRed;
  }

  static String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'KES ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'KES ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return 'KES ${amount.toStringAsFixed(0)}';
  }

  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
}
