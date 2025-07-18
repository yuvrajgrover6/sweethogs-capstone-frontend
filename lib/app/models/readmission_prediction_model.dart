import 'package:flutter/material.dart';

/// API Response models for readmission prediction service

/// Base API response structure
class ReadmissionApiResponse {
  final int code;
  final String message;
  final ReadmissionPredictionResult body;

  const ReadmissionApiResponse({
    required this.code,
    required this.message,
    required this.body,
  });

  factory ReadmissionApiResponse.fromJson(Map<String, dynamic> json) {
    return ReadmissionApiResponse(
      code: json['code'] ?? 200,
      message: json['message'] ?? '',
      body: ReadmissionPredictionResult.fromJson(json['body'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message, 'body': body.toJson()};
  }
}

/// Batch prediction API response
class ReadmissionBatchApiResponse {
  final int code;
  final String message;
  final BatchPredictionResult body;

  const ReadmissionBatchApiResponse({
    required this.code,
    required this.message,
    required this.body,
  });

  factory ReadmissionBatchApiResponse.fromJson(Map<String, dynamic> json) {
    return ReadmissionBatchApiResponse(
      code: json['code'] ?? 200,
      message: json['message'] ?? '',
      body: BatchPredictionResult.fromJson(json['body'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message, 'body': body.toJson()};
  }
}

/// Model info API response
class ModelInfoResponse {
  final int code;
  final String message;
  final ModelInfo body;

  const ModelInfoResponse({
    required this.code,
    required this.message,
    required this.body,
  });

  factory ModelInfoResponse.fromJson(Map<String, dynamic> json) {
    return ModelInfoResponse(
      code: json['code'] ?? 200,
      message: json['message'] ?? '',
      body: ModelInfo.fromJson(json['body'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message, 'body': body.toJson()};
  }
}

/// Single prediction result
class ReadmissionPredictionResult {
  final int confidenceScore;
  final String? remedy;

  const ReadmissionPredictionResult({
    required this.confidenceScore,
    this.remedy,
  });

  factory ReadmissionPredictionResult.fromJson(Map<String, dynamic> json) {
    return ReadmissionPredictionResult(
      confidenceScore: json['confidence_score'] ?? 0,
      remedy: json['remedy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence_score': confidenceScore,
      if (remedy != null) 'remedy': remedy,
    };
  }

  /// Convert to percentage string
  String get percentage => '$confidenceScore%';

  /// Get risk level based on confidence score
  String get riskLevel {
    if (confidenceScore >= 60) return 'High';
    if (confidenceScore >= 30) return 'Medium';
    return 'Low';
  }

  /// Get risk color based on confidence score
  Color get riskColor {
    if (confidenceScore >= 60) return const Color(0xFFDC2626); // Red
    if (confidenceScore >= 30) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFF10B981); // Green
  }

  /// Convert to ReadmissionPrediction for UI compatibility
  ReadmissionPrediction toReadmissionPrediction(String patientId) {
    final probability = confidenceScore / 100.0;

    List<String> riskFactors = [];
    String recommendation = '';

    // Use remedy from API if available, otherwise generate based on score
    if (remedy != null && remedy!.isNotEmpty) {
      recommendation = remedy!;
      // Generate appropriate risk factors based on score
      if (confidenceScore >= 70) {
        riskFactors = [
          'Very high readmission risk detected',
          'Multiple risk factors present',
          'Requires immediate intervention',
        ];
      } else if (confidenceScore >= 50) {
        riskFactors = [
          'High readmission risk detected',
          'Several risk factors identified',
          'Close monitoring needed',
        ];
      } else if (confidenceScore >= 30) {
        riskFactors = [
          'Moderate readmission risk',
          'Some risk factors present',
          'Standard care with education',
        ];
      } else {
        riskFactors = [
          'Low readmission risk',
          'Minimal risk factors identified',
          'Standard care protocols',
        ];
      }
    } else {
      // Generate risk factors and recommendations based on score (fallback)
      if (confidenceScore >= 70) {
        riskFactors = [
          'Very high readmission risk detected',
          'Multiple risk factors present',
          'Requires immediate intervention',
        ];
        recommendation =
            'Immediate intervention required. Consider discharge planning team consultation and enhanced follow-up care.';
      } else if (confidenceScore >= 50) {
        riskFactors = [
          'High readmission risk detected',
          'Several risk factors identified',
          'Close monitoring needed',
        ];
        recommendation =
            'Close monitoring recommended. Schedule follow-up within 48-72 hours of discharge.';
      } else if (confidenceScore >= 30) {
        riskFactors = [
          'Moderate readmission risk',
          'Some risk factors present',
          'Standard care with education',
        ];
        recommendation =
            'Standard follow-up care with additional patient education on medication compliance.';
      } else {
        riskFactors = [
          'Low readmission risk',
          'Minimal risk factors identified',
          'Standard care protocols',
        ];
        recommendation =
            'Standard discharge protocol. Regular follow-up as scheduled.';
      }
    }

    return ReadmissionPrediction(
      patientId: patientId,
      probability: probability,
      riskLevel: riskLevel,
      riskFactors: riskFactors,
      recommendation: recommendation,
      timestamp: DateTime.now(),
    );
  }
}

/// Batch prediction result
class BatchPredictionResult {
  final List<ReadmissionPredictionResult> predictions;
  final int totalPatients;

  const BatchPredictionResult({
    required this.predictions,
    required this.totalPatients,
  });

  factory BatchPredictionResult.fromJson(Map<String, dynamic> json) {
    final predictionsList = json['predictions'] as List? ?? [];
    return BatchPredictionResult(
      predictions: predictionsList
          .map((p) => ReadmissionPredictionResult.fromJson(p))
          .toList(),
      totalPatients: json['total_patients'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'predictions': predictions.map((p) => p.toJson()).toList(),
      'total_patients': totalPatients,
    };
  }
}

/// Model information
class ModelInfo {
  final String modelVersion;
  final String modelType;
  final String description;
  final ModelFeatures features;
  final RiskThresholds riskThresholds;
  final AccuracyMetrics accuracyMetrics;

  const ModelInfo({
    required this.modelVersion,
    required this.modelType,
    required this.description,
    required this.features,
    required this.riskThresholds,
    required this.accuracyMetrics,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      modelVersion: json['model_version'] ?? '',
      modelType: json['model_type'] ?? '',
      description: json['description'] ?? '',
      features: ModelFeatures.fromJson(json['features'] ?? {}),
      riskThresholds: RiskThresholds.fromJson(json['risk_thresholds'] ?? {}),
      accuracyMetrics: AccuracyMetrics.fromJson(json['accuracy_metrics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_version': modelVersion,
      'model_type': modelType,
      'description': description,
      'features': features.toJson(),
      'risk_thresholds': riskThresholds.toJson(),
      'accuracy_metrics': accuracyMetrics.toJson(),
    };
  }
}

/// Model features
class ModelFeatures {
  final List<String> demographicFactors;
  final List<String> clinicalFactors;
  final List<String> medicationFactors;
  final List<String> utilizationFactors;
  final List<String> labFactors;

  const ModelFeatures({
    required this.demographicFactors,
    required this.clinicalFactors,
    required this.medicationFactors,
    required this.utilizationFactors,
    required this.labFactors,
  });

  factory ModelFeatures.fromJson(Map<String, dynamic> json) {
    return ModelFeatures(
      demographicFactors: List<String>.from(json['demographic_factors'] ?? []),
      clinicalFactors: List<String>.from(json['clinical_factors'] ?? []),
      medicationFactors: List<String>.from(json['medication_factors'] ?? []),
      utilizationFactors: List<String>.from(json['utilization_factors'] ?? []),
      labFactors: List<String>.from(json['lab_factors'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'demographic_factors': demographicFactors,
      'clinical_factors': clinicalFactors,
      'medication_factors': medicationFactors,
      'utilization_factors': utilizationFactors,
      'lab_factors': labFactors,
    };
  }
}

/// Risk thresholds
class RiskThresholds {
  final String lowRisk;
  final String mediumRisk;
  final String highRisk;

  const RiskThresholds({
    required this.lowRisk,
    required this.mediumRisk,
    required this.highRisk,
  });

  factory RiskThresholds.fromJson(Map<String, dynamic> json) {
    return RiskThresholds(
      lowRisk: json['low_risk'] ?? '',
      mediumRisk: json['medium_risk'] ?? '',
      highRisk: json['high_risk'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'low_risk': lowRisk,
      'medium_risk': mediumRisk,
      'high_risk': highRisk,
    };
  }
}

/// Accuracy metrics
class AccuracyMetrics {
  final String sensitivity;
  final String specificity;
  final String aucRoc;
  final String precision;
  final String recall;

  const AccuracyMetrics({
    required this.sensitivity,
    required this.specificity,
    required this.aucRoc,
    required this.precision,
    required this.recall,
  });

  factory AccuracyMetrics.fromJson(Map<String, dynamic> json) {
    return AccuracyMetrics(
      sensitivity: json['sensitivity'] ?? '',
      specificity: json['specificity'] ?? '',
      aucRoc: json['auc_roc'] ?? '',
      precision: json['precision'] ?? '',
      recall: json['recall'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensitivity': sensitivity,
      'specificity': specificity,
      'auc_roc': aucRoc,
      'precision': precision,
      'recall': recall,
    };
  }
}

/// Existing ReadmissionPrediction class for UI compatibility
class ReadmissionPrediction {
  final String patientId;
  final double probability;
  final String riskLevel;
  final List<String> riskFactors;
  final String recommendation;
  final DateTime timestamp;

  const ReadmissionPrediction({
    required this.patientId,
    required this.probability,
    required this.riskLevel,
    required this.riskFactors,
    required this.recommendation,
    required this.timestamp,
  });

  String get probabilityPercentage =>
      '${(probability * 100).toStringAsFixed(1)}%';

  Color get riskColor {
    if (probability >= 0.7) return const Color(0xFFDC2626); // Red
    if (probability >= 0.4) return const Color(0xFFF59E0B); // Orange
    if (probability >= 0.2) return const Color(0xFFFCD34D); // Yellow
    return const Color(0xFF10B981); // Green
  }
}
