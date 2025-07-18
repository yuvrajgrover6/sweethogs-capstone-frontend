import 'package:get/get.dart';
import '../models/analytics_models.dart';
import '../services/analytics_service.dart';
import '../utils/custom_snackbar.dart';

class AnalyticsController extends GetxController {
  // Observable variables
  final Rx<PatientStats?> _patientStats = Rx<PatientStats?>(null);
  final Rx<PatientAnalytics?> _patientAnalytics = Rx<PatientAnalytics?>(null);
  final RxBool _isLoadingStats = false.obs;
  final RxBool _isLoadingAnalytics = false.obs;
  final RxString _errorMessage = ''.obs;

  // Services
  final AnalyticsService _analyticsService = AnalyticsService();

  // Getters
  PatientStats? get patientStats => _patientStats.value;
  PatientAnalytics? get patientAnalytics => _patientAnalytics.value;
  bool get isLoadingStats => _isLoadingStats.value;
  bool get isLoadingAnalytics => _isLoadingAnalytics.value;
  String get errorMessage => _errorMessage.value;
  bool get isLoading => _isLoadingStats.value || _isLoadingAnalytics.value;
  bool get hasData => _patientStats.value != null && _patientAnalytics.value != null;

  @override
  void onInit() {
    super.onInit();
    loadAllAnalytics();
  }

  /// Load all analytics data
  Future<void> loadAllAnalytics() async {
    await Future.wait([
      loadPatientStats(),
      loadPatientAnalytics(),
    ]);
  }

  /// Load patient statistics
  Future<void> loadPatientStats() async {
    try {
      _isLoadingStats.value = true;
      _errorMessage.value = '';
      
      final stats = await _analyticsService.getPatientStats();
      _patientStats.value = stats;
    } catch (e) {
      _errorMessage.value = e.toString();
      CustomSnackbar.error('Failed to load patient statistics');
    } finally {
      _isLoadingStats.value = false;
    }
  }

  /// Load patient analytics
  Future<void> loadPatientAnalytics() async {
    try {
      _isLoadingAnalytics.value = true;
      _errorMessage.value = '';
      
      final analytics = await _analyticsService.getPatientAnalytics();
      _patientAnalytics.value = analytics;
    } catch (e) {
      _errorMessage.value = e.toString();
      CustomSnackbar.error('Failed to load patient analytics');
    } finally {
      _isLoadingAnalytics.value = false;
    }
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await loadAllAnalytics();
  }

  /// Get risk level based on readmission percentage
  String getRiskLevel() {
    if (_patientAnalytics.value == null) return 'Unknown';
    
    final readmissionRate = double.tryParse(_patientAnalytics.value!.kpis.readmissionPercentage) ?? 0;
    
    if (readmissionRate >= 60) return 'High Risk';
    if (readmissionRate >= 40) return 'Medium Risk';
    return 'Low Risk';
  }

  /// Get risk color based on readmission percentage
  String getRiskColor() {
    if (_patientAnalytics.value == null) return '#6B7280';
    
    final readmissionRate = double.tryParse(_patientAnalytics.value!.kpis.readmissionPercentage) ?? 0;
    
    if (readmissionRate >= 60) return '#EF4444'; // Red
    if (readmissionRate >= 40) return '#F59E0B'; // Orange
    return '#10B981'; // Green
  }

  /// Get top diagnosis
  String getTopDiagnosis() {
    if (_patientAnalytics.value?.charts.diagnosisDistribution.isEmpty ?? true) {
      return 'No data';
    }
    
    final topDiagnosis = _patientAnalytics.value!.charts.diagnosisDistribution.first;
    return '${topDiagnosis.label} (${topDiagnosis.value} cases)';
  }

  /// Get gender distribution for quick display
  Map<String, dynamic> getGenderBreakdown() {
    if (_patientAnalytics.value?.charts.genderDistribution.isEmpty ?? true) {
      return {'male': 0, 'female': 0, 'malePercent': '0%', 'femalePercent': '0%'};
    }
    
    final genderData = _patientAnalytics.value!.charts.genderDistribution;
    int male = 0, female = 0;
    String malePercent = '0%', femalePercent = '0%';
    
    for (final item in genderData) {
      if (item.label.toLowerCase() == 'male') {
        male = item.value;
        malePercent = item.percentage ?? '0%';
      } else if (item.label.toLowerCase() == 'female') {
        female = item.value;
        femalePercent = item.percentage ?? '0%';
      }
    }
    
    return {
      'male': male,
      'female': female,
      'malePercent': malePercent,
      'femalePercent': femalePercent,
    };
  }

  /// Get diabetes medication statistics
  Map<String, dynamic> getDiabetesBreakdown() {
    if (_patientAnalytics.value?.charts.diabetesDistribution.isEmpty ?? true) {
      return {'withMeds': 0, 'withoutMeds': 0, 'percentage': '0%'};
    }
    
    final diabetesData = _patientAnalytics.value!.charts.diabetesDistribution;
    int withMeds = 0, withoutMeds = 0;
    String percentage = '0%';
    
    for (final item in diabetesData) {
      if (item.label.toLowerCase() == 'yes') {
        withMeds = item.value;
        percentage = item.percentage ?? '0%';
      } else if (item.label.toLowerCase() == 'no') {
        withoutMeds = item.value;
      }
    }
    
    return {
      'withMeds': withMeds,
      'withoutMeds': withoutMeds,
      'percentage': percentage,
    };
  }

  /// Clear data
  void clearData() {
    _patientStats.value = null;
    _patientAnalytics.value = null;
    _errorMessage.value = '';
  }
}
