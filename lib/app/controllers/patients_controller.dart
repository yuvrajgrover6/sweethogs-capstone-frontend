import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../models/readmission_prediction_model.dart';
import '../services/readmission_service.dart';

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

  // Services
  final ReadmissionService _readmissionService = ReadmissionService();

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

  // Predict readmission for a patient using real API
  Future<void> predictReadmission(PatientModel patient) async {
    try {
      _isAnalyzing.value = true;

      // Call the real API service
      final response = await _readmissionService.predictSinglePatient(patient);

      // Convert API response to ReadmissionPrediction for UI
      final prediction = response.body.toReadmissionPrediction(
        patient.patientId,
      );

      _predictions[patient.patientId] = prediction;

      Get.dialog(
        _buildPredictionDialog(patient, prediction),
        barrierDismissible: true,
      );

      Get.snackbar(
        'Success',
        'Readmission prediction completed',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        'Prediction Failed',
        'Unable to get prediction from API: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    } finally {
      _isAnalyzing.value = false;
    }
  }

  // Test API connection
  Future<void> testApiConnection() async {
    try {
      _isAnalyzing.value = true;

      final response = await _readmissionService.testPrediction();

      Get.snackbar(
        'API Connected',
        'Test prediction successful: ${response.body.percentage}',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        icon: const Icon(Icons.cloud_done, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        'API Connection Failed',
        'Failed to connect to API: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.cloud_off, color: Colors.red),
      );
    } finally {
      _isAnalyzing.value = false;
    }
  }

  // Get model information
  Future<void> getModelInfo() async {
    try {
      _isAnalyzing.value = true;

      // Show static model information dialog
      Get.dialog(_buildStaticModelInfoDialog(), barrierDismissible: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get model info: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    } finally {
      _isAnalyzing.value = false;
    }
  }

  // Batch prediction for multiple patients
  Future<void> predictBatchReadmission(List<PatientModel> patients) async {
    try {
      if (patients.isEmpty) {
        Get.snackbar(
          'Warning',
          'No patients selected for batch prediction',
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
        );
        return;
      }

      if (patients.length > 100) {
        Get.snackbar(
          'Error',
          'Maximum 100 patients allowed per batch',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }

      _isAnalyzing.value = true;

      final response = await _readmissionService.predictBatchPatients(patients);

      // Store predictions for each patient
      for (
        int i = 0;
        i < patients.length && i < response.body.predictions.length;
        i++
      ) {
        final patient = patients[i];
        final predictionResult = response.body.predictions[i];
        _predictions[patient.patientId] = predictionResult
            .toReadmissionPrediction(patient.patientId);
      }

      Get.snackbar(
        'Success',
        'Batch prediction completed for ${response.body.totalPatients} patients',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to predict batch readmission: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    } finally {
      _isAnalyzing.value = false;
    }
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
                        'Readmission Prediction (30 days)',
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
                          'Confidence Score',
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
                        const SizedBox(height: 4),
                        Text(
                          'Likelihood of readmission within 30 days',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
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

            // Contributing Factors
            Text(
              'Contributing Factors',
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

  // Build static model info dialog
  Widget _buildStaticModelInfoDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Model Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Readmission Prediction Model v2.1',
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

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This machine learning model predicts the likelihood of hospital readmission within 30 days for diabetic patients. The model provides a confidence score (0-100%) indicating the probability of readmission, not a risk calculation. Higher scores indicate higher likelihood of readmission.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),

                    // Confidence Score Thresholds
                    Text(
                      'Confidence Score Thresholds',
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
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _buildThresholdRow(
                            'Low Likelihood',
                            '< 30%',
                            Colors.green,
                          ),
                          const SizedBox(height: 8),
                          _buildThresholdRow(
                            'Medium Likelihood',
                            '30% - 60%',
                            Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          _buildThresholdRow(
                            'High Likelihood',
                            '> 60%',
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Model Performance Metrics
                    Text(
                      'Model Performance Metrics',
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
                      child: Column(
                        children: [
                          _buildMetricRow('Accuracy', '85.2%'),
                          _buildMetricRow('Sensitivity', '78.9%'),
                          _buildMetricRow('Specificity', '89.1%'),
                          _buildMetricRow('AUC-ROC', '0.84'),
                          _buildMetricRow('Precision', '76.3%'),
                          _buildMetricRow('F1-Score', '77.6%'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Key Features
                    Text(
                      'Key Features Used by Model',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureSection('Patient Demographics', [
                      'Age',
                      'Gender',
                      'Race',
                    ]),
                    _buildFeatureSection('Clinical Factors', [
                      'Length of Stay',
                      'Number of Diagnoses',
                      'Number of Procedures',
                      'Medical Specialty',
                    ]),
                    _buildFeatureSection('Medication History', [
                      'Number of Medications',
                      'Diabetes Medication',
                      'Medication Changes',
                    ]),
                    _buildFeatureSection('Healthcare Utilization', [
                      'Previous Inpatient Visits',
                      'Emergency Visits',
                      'Outpatient Visits',
                    ]),
                    _buildFeatureSection('Lab Results', [
                      'HbA1c Results',
                      'Glucose Serum Test',
                      'A1C Test Results',
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(String title, List<String> features) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: features
                .map(
                  (feature) => Chip(
                    label: Text(feature, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.grey[100],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}
