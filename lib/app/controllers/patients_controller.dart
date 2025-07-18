import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../models/readmission_prediction_model.dart';
import '../services/readmission_service.dart';
import '../services/patient_api_service.dart';
import '../constants/api_constants.dart';
import '../utils/custom_snackbar.dart';

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
  final PatientApiService _patientApiService = PatientApiService();

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

  // Load patients from API
  Future<void> loadPatients() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      print('Fetching patients from API... Page: ${_currentPage.value}, Limit: ${_itemsPerPage.value}, Filter: ${_selectedFilter.value}');
      
      // For risk-based filters, we need to load more data to account for client-side filtering
      int requestLimit = _itemsPerPage.value;
      bool isRiskFilter = _selectedFilter.value.contains('risk');
      
      if (isRiskFilter) {
        // Load more data to account for client-side filtering
        requestLimit = (_itemsPerPage.value * 3).clamp(10, 100); // Load 3x to ensure we have enough data
      }
      
      // Prepare filter parameters based on selected filter
      String? diabetesMed;
      String? readmitted;
      
      switch (_selectedFilter.value) {
        case 'diabetes_med':
          diabetesMed = 'Yes';
          break;
        case 'readmitted':
          readmitted = '>30';
          break;
        default:
          break; // No specific API filter for risk levels, these are computed
      }
      
      final apiResponse = await _patientApiService.getPatients(
        page: _currentPage.value,
        limit: requestLimit,
        search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
        diabetesMed: diabetesMed,
        readmitted: readmitted,
      );

      print('API Response received: ${apiResponse.body.patients.length} patients for page ${apiResponse.body.page}');
      print('Total patients in database: ${apiResponse.body.total}, Total pages: ${apiResponse.body.totalPages}');
      
      List<PatientModel> patients = apiResponse.body.patients;
      
      // Apply client-side filtering for risk levels (since API doesn't support these)
      if (_selectedFilter.value == 'high_risk') {
        patients = patients.where((p) => p.riskLevel == 'High').toList();
      } else if (_selectedFilter.value == 'medium_risk') {
        patients = patients.where((p) => p.riskLevel == 'Medium').toList();
      } else if (_selectedFilter.value == 'low_risk') {
        patients = patients.where((p) => p.riskLevel == 'Low' || p.riskLevel == 'Very Low').toList();
      }
      
      // For risk filters, limit to requested page size
      if (isRiskFilter) {
        int startIndex = 0;
        int endIndex = _itemsPerPage.value.clamp(0, patients.length);
        patients = patients.sublist(startIndex, endIndex);
      }
      
      _allPatients.value = patients;
      _filteredPatients.value = patients;
      
      // Update pagination with API response (server-side pagination)
      _currentPagination.value = PatientPagination(
        patients: patients,
        currentPage: apiResponse.body.page,
        totalPages: apiResponse.body.totalPages,
        totalItems: apiResponse.body.total,
        itemsPerPage: _itemsPerPage.value, // Use the actual requested items per page
      );

      if (patients.isNotEmpty) {
        print('Loaded ${patients.length} patients (Page ${apiResponse.body.page} of ${apiResponse.body.totalPages})');
        } else {
        CustomSnackbar.info('No patients found');
      }
    } catch (e) {
      print('Error loading patients: $e');
      _errorMessage.value = 'Failed to connect to API: ${e.toString()}';
      _allPatients.value = [];
      _filteredPatients.value = [];
      _currentPagination.value = PatientPagination(
        patients: [],
        currentPage: 1,
        totalPages: 1,
        totalItems: 0,
        itemsPerPage: _itemsPerPage.value,
      );
      CustomSnackbar.error('No data available. Please check your connection and try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  // Search patients
  void searchPatients(String query) {
    _searchQuery.value = query;
    _currentPage.value = 1; // Reset to first page
    loadPatients(); // Reload from API with search
  }

  // Apply filter
  void applyFilter(String filter) {
    _selectedFilter.value = filter;
    _currentPage.value = 1; // Reset to first page
    loadPatients(); // Reload from API with filter
  }



  // Change page
  void changePage(int page) {
    if (page >= 1 && page <= (currentPagination?.totalPages ?? 1)) {
      _currentPage.value = page;
      loadPatients(); // Reload from API with new page
    }
  }

  // Change items per page
  void changeItemsPerPage(int itemsPerPage) {
    _itemsPerPage.value = itemsPerPage;
    _currentPage.value = 1; // Reset to first page
    loadPatients(); // Reload from API with new items per page
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

      // Debug patient data
      debugPatientData(patient);

      // Validate patient data before API call
      final validationErrors = patient.validateApiFields();
      if (validationErrors.isNotEmpty) {
        CustomSnackbar.validationError(
          'Patient data incomplete:\n${validationErrors.join('\n')}',
        );
        return;
      }

      // Debug: Log the API payload
      final apiPayload = patient.toApiJson();
      print('API Payload for ${patient.patientId}: $apiPayload');

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

      CustomSnackbar.predictionCompleted('Readmission prediction completed');
    } catch (e) {
      CustomSnackbar.predictionFailed(_getApiErrorMessage(e));
    } finally {
      _isAnalyzing.value = false;
    }
  }

  // Helper method to get user-friendly error messages
  String _getApiErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    print('Full error details: $error'); // Debug logging
    
    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Authentication required. Please login again.';
    } else if (errorString.contains('400') || errorString.contains('validation')) {
      return 'Invalid patient data. Please check all required fields.\nError details: $error';
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

  // Get risk level information for UI
  Map<String, dynamic> getRiskLevel(int score) {
    if (score >= 60) {
      return {
        'level': 'HIGH',
        'color': const Color(0xFFDC2626),
        'text': 'High Risk',
        'icon': Icons.warning,
      };
    } else if (score >= 30) {
      return {
        'level': 'MEDIUM', 
        'color': const Color(0xFFF59E0B),
        'text': 'Medium Risk',
        'icon': Icons.info_outline,
      };
    } else {
      return {
        'level': 'LOW',
        'color': const Color(0xFF10B981),
        'text': 'Low Risk',
        'icon': Icons.check_circle_outline,
      };
    }
  }

  // Debug method to test patient data
  void debugPatientData(PatientModel patient) {
    print('=== Patient Debug Info ===');
    print('Patient ID: ${patient.patientId}');
    print('Age: "${patient.age}"');
    print('Gender: "${patient.gender}"');
    print('Time in hospital: ${patient.timeInHospital}');
    print('Admission type: ${patient.admissionTypeId}');
    print('Discharge disposition: ${patient.dischargeDispositionId}');
    print('Admission source: ${patient.admissionSourceId}');
    print('Number of diagnoses: ${patient.numberDiagnoses}');
    print('API JSON: ${patient.toApiJson()}');
    print('Validation errors: ${patient.validateApiFields()}');
    print('=== End Debug Info ===');
  }

  // Test API connection
  Future<void> testApiConnection() async {
    try {
      _isAnalyzing.value = true;

      print('Testing API connection to ${ApiConstants.readmissionTest}');

      final response = await _readmissionService.testPrediction();

      CustomSnackbar.apiConnected(
        'Test prediction successful: ${response.body.percentage}${response.body.remedy != null ? '\nRecommendation: ${response.body.remedy}' : ''}',
      );
    } catch (e) {
      print('API connection test failed: $e');
      CustomSnackbar.apiConnectionFailed(_getApiErrorMessage(e));
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
      CustomSnackbar.error('Failed to get model info: ${e.toString()}');
    } finally {
      _isAnalyzing.value = false;
    }
  }

  // Batch prediction for multiple patients
  Future<void> predictBatchReadmission(List<PatientModel> patients) async {
    try {
      if (patients.isEmpty) {
        CustomSnackbar.warning('No patients selected for batch prediction');
        return;
      }

      if (patients.length > 100) {
        CustomSnackbar.error('Maximum 100 patients allowed per batch');
        return;
      }

      // Validate all patients before processing
      List<String> invalidPatients = [];
      for (int i = 0; i < patients.length; i++) {
        final validationErrors = patients[i].validateApiFields();
        if (validationErrors.isNotEmpty) {
          invalidPatients.add('Patient ${patients[i].patientId}: ${validationErrors.first}');
        }
      }

      if (invalidPatients.isNotEmpty) {
        CustomSnackbar.validationError(
          'Some patients have invalid data: ${invalidPatients.take(3).join(', ')}${invalidPatients.length > 3 ? '...' : ''}',
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

      CustomSnackbar.success(
        'Batch prediction completed for ${response.body.totalPatients} patients',
      );
    } catch (e) {
      CustomSnackbar.error(_getApiErrorMessage(e));
    } finally {
      _isAnalyzing.value = false;
    }
  }

  // Download prediction as PDF
  Future<void> downloadPredictionPdf(
    PatientModel patient,
    ReadmissionPrediction prediction,
  ) async {
    try {
      CustomSnackbar.info('Generating PDF report...');
      
      await _readmissionService.generatePredictionPdf(
        patient: patient,
        prediction: prediction,
      );
      
      CustomSnackbar.success('PDF report downloaded successfully');
    } catch (e) {
      CustomSnackbar.error('Failed to generate PDF: ${_getApiErrorMessage(e)}');
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
                  onPressed: () async {
                    Get.back(); // Close dialog first
                    await downloadPredictionPdf(patient, prediction);
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

  // Patient Management Methods
  
  // Create a new patient
  Future<bool> createPatient(PatientModel patient) async {
    try {
      _isLoading.value = true;
      
      await _patientApiService.createPatient(patient.toJson());
      
      // Refresh the patient list after creation
      await loadPatients();
      
      CustomSnackbar.success('Patient created successfully');
      return true;
    } catch (e) {
      CustomSnackbar.error('Failed to create patient: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Update an existing patient
  Future<bool> updatePatient(String patientId, PatientModel patient) async {
    try {
      _isLoading.value = true;
      
      await _patientApiService.updatePatient(patientId, patient.toJson());
      
      // Refresh the patient list after update
      await loadPatients();
      
      CustomSnackbar.success('Patient updated successfully');
      return true;
    } catch (e) {
      CustomSnackbar.error('Failed to update patient: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Delete a patient
  Future<bool> deletePatient(String patientId) async {
    try {
      _isLoading.value = true;
      
      await _patientApiService.deletePatient(patientId);
      
      // Refresh the patient list after deletion
      await loadPatients();
      
      CustomSnackbar.success('Patient deleted successfully');
      return true;
    } catch (e) {
      CustomSnackbar.error('Failed to delete patient: ${e.toString()}');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Get a single patient by ID
  Future<PatientModel?> getPatientById(String patientId) async {
    try {
      _isLoading.value = true;
      
      final patient = await _patientApiService.getPatientById(patientId);
      return patient;
    } catch (e) {
      CustomSnackbar.error('Failed to load patient: ${e.toString()}');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh data from API (renamed to avoid duplicate)
  Future<void> refreshPatientData() async {
    _currentPage.value = 1;
    _searchQuery.value = '';
    _selectedFilter.value = 'all';
    await loadPatients();
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}
