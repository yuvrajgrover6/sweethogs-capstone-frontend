import 'package:flutter/material.dart';

/// Utility class for API-related operations and validations
class ApiUtils {
  /// Get risk level information based on confidence score
  static Map<String, dynamic> getRiskLevel(int score) {
    if (score >= 60) {
      return {
        'level': 'HIGH',
        'color': const Color(0xFFDC2626),
        'text': 'High Risk',
        'icon': Icons.warning,
        'backgroundColor': const Color(0xFFDC2626).withOpacity(0.1),
      };
    } else if (score >= 30) {
      return {
        'level': 'MEDIUM',
        'color': const Color(0xFFF59E0B),
        'text': 'Medium Risk',
        'icon': Icons.info_outline,
        'backgroundColor': const Color(0xFFF59E0B).withOpacity(0.1),
      };
    } else {
      return {
        'level': 'LOW',
        'color': const Color(0xFF10B981),
        'text': 'Low Risk',
        'icon': Icons.check_circle_outline,
        'backgroundColor': const Color(0xFF10B981).withOpacity(0.1),
      };
    }
  }

  /// Get user-friendly error message from API errors
  static String getApiErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Authentication required. Please login again.';
    } else if (errorString.contains('400') || errorString.contains('validation')) {
      return 'Invalid patient data. Please check all required fields.';
    } else if (errorString.contains('500') || errorString.contains('server')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('connection') || errorString.contains('network')) {
      return 'Unable to connect to server. Please check if the backend is running on localhost:3000';
    } else if (errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else {
      return 'Unable to get prediction from API: ${error.toString()}';
    }
  }

  /// Validate age range format
  static bool isValidAgeRange(String age) {
    final agePattern = RegExp(r'^\[(\d+)-(\d+)\)$');
    return agePattern.hasMatch(age);
  }

  /// Validate gender value
  static bool isValidGender(String gender) {
    return ['Male', 'Female'].contains(gender);
  }

  /// Validate medication values
  static bool isValidMedicationValue(String value) {
    return ['Down', 'Steady', 'Up', 'No'].contains(value);
  }

  /// Validate A1C result values
  static bool isValidA1CResult(String value) {
    return ['>7', '>8', 'Norm', 'None'].contains(value);
  }

  /// Validate glucose serum values
  static bool isValidGlucoseSerum(String value) {
    return ['>200', '>300', 'Norm', 'None'].contains(value);
  }

  /// Validate diabetes medication values
  static bool isValidDiabetesMed(String value) {
    return ['Yes', 'No'].contains(value);
  }

  /// Validate change values
  static bool isValidChange(String value) {
    return ['No', 'Ch'].contains(value);
  }

  /// Get formatted confidence percentage
  static String formatConfidencePercentage(int score) {
    return '$score%';
  }

  /// Get risk badge widget
  static Widget getRiskBadge(int score) {
    final riskInfo = getRiskLevel(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: riskInfo['color'],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            riskInfo['icon'],
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            riskInfo['text'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Get risk color indicator
  static Widget getRiskColorIndicator(int score) {
    final riskInfo = getRiskLevel(score);
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: riskInfo['color'],
        shape: BoxShape.circle,
      ),
    );
  }

  /// Format remedy text for display
  static String formatRemedyText(String? remedy) {
    if (remedy == null || remedy.isEmpty) {
      return 'No specific recommendations available at this time.';
    }
    return remedy;
  }

  /// Validate numeric ranges
  static bool isValidRange(int value, int min, int max) {
    return value >= min && value <= max;
  }

  /// Convert diagnosis code to display format
  static String formatDiagnosisCode(String code) {
    if (code.isEmpty || code == '?') {
      return 'Not specified';
    }
    return code;
  }
}
