import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType {
  success,
  error,
  warning,
  info,
  loading,
}

class CustomSnackbar {
  // Primary theme color
  static const Color _primaryColor = Color(0xff0098B9);
  
  // Color configurations for different types
  static const Map<SnackbarType, Map<String, dynamic>> _configs = {
    SnackbarType.success: {
      'color': Color(0xFF10B981),
      'icon': Icons.check_circle,
      'title': 'Success',
    },
    SnackbarType.error: {
      'color': Color(0xFFDC2626),
      'icon': Icons.error,
      'title': 'Error',
    },
    SnackbarType.warning: {
      'color': Color(0xFFF59E0B),
      'icon': Icons.warning,
      'title': 'Warning',
    },
    SnackbarType.info: {
      'color': _primaryColor,
      'icon': Icons.info,
      'title': 'Info',
    },
    SnackbarType.loading: {
      'color': Color(0xFF6B7280),
      'icon': Icons.hourglass_empty,
      'title': 'Loading',
    },
  };

  /// Show a custom snackbar with advanced styling
  static void show({
    required String message,
    SnackbarType type = SnackbarType.info,
    String? title,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.TOP,
    bool isDismissible = true,
    VoidCallback? onTap,
    TextButton? mainButton,
  }) {
    final config = _configs[type]!;
    final Color themeColor = config['color'];
    
    Get.snackbar(
      title ?? config['title'],
      message,
      titleText: _buildTitle(
        title ?? config['title'],
        themeColor,
      ),
      messageText: _buildMessage(message, themeColor),
      snackPosition: position,
      backgroundColor: _buildBackgroundColor(themeColor),
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      duration: duration,
      isDismissible: isDismissible,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 600),
      borderColor: themeColor,
      borderWidth: 2, // Increased border width for better visibility
      leftBarIndicatorColor: themeColor,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon ?? config['icon'],
          color: themeColor,
          size: 24, // Slightly larger icon
        ),
      ),
      shouldIconPulse: type == SnackbarType.loading,
      mainButton: mainButton,
      onTap: onTap != null ? (_) => onTap() : null,
      boxShadows: [
        BoxShadow(
          color: themeColor.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Success snackbar
  static void success(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.TOP,
    VoidCallback? onTap,
  }) {
    show(
      message: message,
      type: SnackbarType.success,
      title: title,
      duration: duration,
      position: position,
      onTap: onTap,
    );
  }

  /// Error snackbar
  static void error(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 6),
    SnackPosition position = SnackPosition.TOP,
    VoidCallback? onTap,
  }) {
    show(
      message: message,
      type: SnackbarType.error,
      title: title,
      duration: duration,
      position: position,
      onTap: onTap,
    );
  }

  /// Warning snackbar
  static void warning(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 5),
    SnackPosition position = SnackPosition.TOP,
    VoidCallback? onTap,
  }) {
    show(
      message: message,
      type: SnackbarType.warning,
      title: title,
      duration: duration,
      position: position,
      onTap: onTap,
    );
  }

  /// Info snackbar
  static void info(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.TOP,
    VoidCallback? onTap,
  }) {
    show(
      message: message,
      type: SnackbarType.info,
      title: title,
      duration: duration,
      position: position,
      onTap: onTap,
    );
  }

  /// Loading snackbar with indefinite duration
  static void loading(
    String message, {
    String? title,
    SnackPosition position = SnackPosition.TOP,
  }) {
    show(
      message: message,
      type: SnackbarType.loading,
      title: title ?? 'Loading',
      duration: const Duration(seconds: 30), // Long duration for loading
      position: position,
      isDismissible: false,
      icon: Icons.hourglass_empty,
    );
  }

  /// API-specific snackbars for common scenarios
  
  /// API connection success
  static void apiConnected(String message) {
    show(
      message: message,
      type: SnackbarType.success,
      title: 'API Connected',
      icon: Icons.cloud_done,
      duration: const Duration(seconds: 4),
    );
  }

  /// API connection failed
  static void apiConnectionFailed(String message) {
    show(
      message: message,
      type: SnackbarType.error,
      title: 'API Connection Failed',
      icon: Icons.cloud_off,
      duration: const Duration(seconds: 6),
    );
  }

  /// Validation error
  static void validationError(String message) {
    show(
      message: message,
      type: SnackbarType.warning,
      title: 'Validation Error',
      icon: Icons.warning_amber,
      duration: const Duration(seconds: 7),
    );
  }

  /// Authentication required
  static void authRequired(String message) {
    show(
      message: message,
      type: SnackbarType.warning,
      title: 'Authentication Required',
      icon: Icons.lock,
      duration: const Duration(seconds: 5),
    );
  }

  /// Feature coming soon
  static void comingSoon(String message) {
    show(
      message: message,
      type: SnackbarType.info,
      title: 'Coming Soon',
      icon: Icons.schedule,
      duration: const Duration(seconds: 3),
    );
  }

  /// Prediction completed
  static void predictionCompleted(String message) {
    show(
      message: message,
      type: SnackbarType.success,
      title: 'Prediction Completed',
      icon: Icons.analytics,
      duration: const Duration(seconds: 4),
    );
  }

  /// Prediction failed
  static void predictionFailed(String message) {
    show(
      message: message,
      type: SnackbarType.error,
      title: 'Prediction Failed',
      icon: Icons.error_outline,
      duration: const Duration(seconds: 6),
    );
  }

  /// Data loaded successfully
  static void dataLoaded(String message) {
    show(
      message: message,
      type: SnackbarType.success,
      title: 'Data Loaded',
      icon: Icons.download_done,
      duration: const Duration(seconds: 3),
    );
  }

  /// Dismiss all snackbars
  static void dismissAll() {
    Get.closeAllSnackbars();
  }

  // Helper methods for building custom widgets
  static Widget _buildTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static Widget _buildMessage(String message, Color color) {
    return Text(
      message,
      style: TextStyle(
        color: Colors.grey[700], // Darker grey for even better readability
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w500, // Slightly bolder for better visibility
      ),
    );
  }

  static Color _buildBackgroundColor(Color themeColor) {
    // Create a very light tint of the theme color on white background
    return Color.lerp(Colors.white, themeColor, 0.05) ?? Colors.white;
  }
}

/// Extension for easy access to snackbars
extension SnackbarExtension on GetInterface {
  /// Quick access to custom snackbars
  void showCustomSnackbar({
    required String message,
    SnackbarType type = SnackbarType.info,
    String? title,
  }) {
    CustomSnackbar.show(message: message, type: type, title: title);
  }
}
