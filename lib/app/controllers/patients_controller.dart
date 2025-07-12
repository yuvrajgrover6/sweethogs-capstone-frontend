import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/patient_model.dart';

class PatientsController extends GetxController {
  // Observable variables
  final RxList<PatientModel> _allPatients = <PatientModel>[].obs;
  final RxList<PatientModel> _filteredPatients = <PatientModel>[].obs;
  final Rx<PatientPagination?> _currentPagination = Rx<PatientPagination?>(
    null,
  );
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedFilter = 'all'.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _itemsPerPage = 10.obs;
  final RxMap<String, ReadmissionPrediction> _predictions =
      <String, ReadmissionPrediction>{}.obs;
  final RxBool _isAnalyzing = false.obs;

  // Getters
  List<PatientModel> get allPatients => _allPatients;
  List<PatientModel> get filteredPatients => _filteredPatients;
  PatientPagination? get currentPagination => _currentPagination.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  String get selectedFilter => _selectedFilter.value;
  int get currentPage => _currentPage.value;
  int get itemsPerPage => _itemsPerPage.value;
  Map<String, ReadmissionPrediction> get predictions => _predictions;
  bool get isAnalyzing => _isAnalyzing.value;

  // Filter options
  final List<Map<String, String>> filterOptions = [
    {'value': 'all', 'label': 'All Patients'},
    {'value': 'high_risk', 'label': 'High Risk'},
    {'value': 'medium_risk', 'label': 'Medium Risk'},
    {'value': 'low_risk', 'label': 'Low Risk'},
    {'value': 'readmitted', 'label': 'Previously Readmitted'},
    {'value': 'diabetes_med', 'label': 'On Diabetes Medication'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadPatients();
  }

  // Load patients from JSON file
  Future<void> loadPatients() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Load JSON data from assets
      final String jsonString = await rootBundle.loadString(
        'assets/images/diabetic_data_sample.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      // Convert to PatientModel list
      final List<PatientModel> patients = jsonData
          .map((json) => PatientModel.fromJson(json))
          .toList();

      _allPatients.value = patients;
      _filteredPatients.value = patients;

      // Initialize pagination
      _updatePagination();

      Get.snackbar(
        'Success',
        'Loaded ${patients.length} patients successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      _errorMessage.value = 'Failed to load patients: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to load patients: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Search patients
  void searchPatients(String query) {
    _searchQuery.value = query;
    _currentPage.value = 1; // Reset to first page
    _applyFilters();
  }

  // Apply filter
  void applyFilter(String filter) {
    _selectedFilter.value = filter;
    _currentPage.value = 1; // Reset to first page
    _applyFilters();
  }

  // Apply search and filter logic
  void _applyFilters() {
    List<PatientModel> filtered = List.from(_allPatients);

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((patient) {
        return patient.patientId.toLowerCase().contains(query) ||
            patient.encounterIdDisplay.toLowerCase().contains(query) ||
            patient.race.toLowerCase().contains(query) ||
            patient.gender.toLowerCase().contains(query) ||
            patient.medicalSpecialty.toLowerCase().contains(query) ||
            patient.primaryDiagnosis.toLowerCase().contains(query);
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter.value) {
      case 'high_risk':
        filtered = filtered.where((p) => p.riskLevel == 'High').toList();
        break;
      case 'medium_risk':
        filtered = filtered.where((p) => p.riskLevel == 'Medium').toList();
        break;
      case 'low_risk':
        filtered = filtered
            .where((p) => p.riskLevel == 'Low' || p.riskLevel == 'Very Low')
            .toList();
        break;
      case 'readmitted':
        filtered = filtered.where((p) => p.readmitted != 'NO').toList();
        break;
      case 'diabetes_med':
        filtered = filtered.where((p) => p.diabetesMed == 'Yes').toList();
        break;
      default:
        break; // Show all
    }

    _filteredPatients.value = filtered;
    _updatePagination();
  }

  // Update pagination
  void _updatePagination() {
    final totalItems = _filteredPatients.length;
    final totalPages = (totalItems / _itemsPerPage.value).ceil();

    final startIndex = (_currentPage.value - 1) * _itemsPerPage.value;
    final endIndex = (startIndex + _itemsPerPage.value).clamp(0, totalItems);

    final currentPagePatients = _filteredPatients.sublist(startIndex, endIndex);

    _currentPagination.value = PatientPagination(
      patients: currentPagePatients,
      currentPage: _currentPage.value,
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: _itemsPerPage.value,
    );
  }

  // Change page
  void changePage(int page) {
    if (page >= 1 && page <= (currentPagination?.totalPages ?? 1)) {
      _currentPage.value = page;
      _updatePagination();
    }
  }

  // Change items per page
  void changeItemsPerPage(int itemsPerPage) {
    _itemsPerPage.value = itemsPerPage;
    _currentPage.value = 1; // Reset to first page
    _updatePagination();
  }

  // Go to next page
  void nextPage() {
    if (currentPagination?.hasNextPage ?? false) {
      changePage(_currentPage.value + 1);
    }
  }

  // Go to previous page
  void previousPage() {
    if (currentPagination?.hasPreviousPage ?? false) {
      changePage(_currentPage.value - 1);
    }
  }

  // Predict readmission for a patient
  Future<void> predictReadmission(PatientModel patient) async {
    try {
      _isAnalyzing.value = true;

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock prediction algorithm based on patient data
      final prediction = _generateMockPrediction(patient);

      _predictions[patient.patientId] = prediction;

      Get.dialog(
        _buildPredictionDialog(patient, prediction),
        barrierDismissible: true,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to predict readmission: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    } finally {
      _isAnalyzing.value = false;
    }
  }

  // Generate mock prediction based on patient data
  ReadmissionPrediction _generateMockPrediction(PatientModel patient) {
    double baseProbability = 0.1; // Base 10% chance
    List<String> riskFactors = [];

    // Age factor
    if (patient.age.contains('70-80') ||
        patient.age.contains('80-90') ||
        patient.age.contains('90-100')) {
      baseProbability += 0.3;
      riskFactors.add('Advanced age (${patient.displayAge})');
    } else if (patient.age.contains('60-70')) {
      baseProbability += 0.2;
      riskFactors.add('Senior age (${patient.displayAge})');
    }

    // Hospital stay duration
    if (patient.timeInHospital > 10) {
      baseProbability += 0.25;
      riskFactors.add(
        'Extended hospital stay (${patient.timeInHospital} days)',
      );
    } else if (patient.timeInHospital > 5) {
      baseProbability += 0.15;
      riskFactors.add('Long hospital stay (${patient.timeInHospital} days)');
    }

    // Previous admissions
    if (patient.numberInpatient > 0) {
      baseProbability += 0.2;
      riskFactors.add(
        'Previous inpatient admissions (${patient.numberInpatient})',
      );
    }

    if (patient.numberEmergency > 0) {
      baseProbability += 0.15;
      riskFactors.add('Previous emergency visits (${patient.numberEmergency})');
    }

    // Medication changes
    if (patient.change == 'Ch') {
      baseProbability += 0.1;
      riskFactors.add('Recent medication changes');
    }

    // Diabetes medication
    if (patient.diabetesMed == 'Yes') {
      baseProbability += 0.1;
      riskFactors.add('Currently on diabetes medication');
    }

    // Complex cases (many procedures/medications)
    if (patient.numProcedures > 3) {
      baseProbability += 0.1;
      riskFactors.add('Multiple procedures (${patient.numProcedures})');
    }

    if (patient.numMedications > 10) {
      baseProbability += 0.1;
      riskFactors.add('Multiple medications (${patient.numMedications})');
    }

    // Previous readmission
    if (patient.readmitted != 'NO') {
      baseProbability += 0.4;
      riskFactors.add('History of readmission');
    }

    // Clamp probability between 0 and 1
    final probability = baseProbability.clamp(0.0, 0.95);

    // Determine risk level and recommendation
    String riskLevel;
    String recommendation;

    if (probability >= 0.7) {
      riskLevel = 'Very High';
      recommendation =
          'Immediate intervention required. Consider discharge planning team consultation and enhanced follow-up care.';
    } else if (probability >= 0.5) {
      riskLevel = 'High';
      recommendation =
          'Close monitoring recommended. Schedule follow-up within 48-72 hours of discharge.';
    } else if (probability >= 0.3) {
      riskLevel = 'Moderate';
      recommendation =
          'Standard follow-up care with additional patient education on medication compliance.';
    } else {
      riskLevel = 'Low';
      recommendation =
          'Standard discharge protocol. Regular follow-up as scheduled.';
    }

    if (riskFactors.isEmpty) {
      riskFactors.add('No significant risk factors identified');
    }

    return ReadmissionPrediction(
      patientId: patient.patientId,
      probability: probability,
      riskLevel: riskLevel,
      riskFactors: riskFactors,
      recommendation: recommendation,
      timestamp: DateTime.now(),
    );
  }

  // Build prediction dialog
  Widget _buildPredictionDialog(
    PatientModel patient,
    ReadmissionPrediction prediction,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: prediction.riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: prediction.riskColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Readmission Risk Analysis',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Patient: ${patient.patientId}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Risk Score
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    prediction.riskColor.withOpacity(0.1),
                    prediction.riskColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: prediction.riskColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Readmission Probability',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prediction.probabilityPercentage,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: prediction.riskColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: prediction.riskColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      prediction.riskLevel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Risk Factors
            Text(
              'Risk Factors',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ...prediction.riskFactors.map(
              (factor) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 16,
                      color: Colors.orange[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        factor,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recommendation
            Text(
              'Recommendation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      prediction.recommendation,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Get.back(), child: Text('Close')),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement save/export functionality
                    Get.back();
                    Get.snackbar(
                      'Success',
                      'Prediction results saved to patient record',
                      backgroundColor: Colors.green.withOpacity(0.1),
                      colorText: Colors.green,
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save to Record'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Clear all data
  void clearData() {
    _allPatients.clear();
    _filteredPatients.clear();
    _predictions.clear();
    _currentPagination.value = null;
    _searchQuery.value = '';
    _selectedFilter.value = 'all';
    _currentPage.value = 1;
    _errorMessage.value = '';
  }

  // Refresh data
  Future<void> refreshData() async {
    clearData();
    await loadPatients();
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}
