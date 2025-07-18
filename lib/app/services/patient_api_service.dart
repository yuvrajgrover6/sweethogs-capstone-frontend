import 'package:dio/dio.dart';
import 'package:get/get.dart' as GetX;
import '../models/patient_model.dart';
import '../controllers/auth_controller.dart';
import '../utils/custom_snackbar.dart';

class PatientApiService {
  late Dio _dio;

  PatientApiService() {
    _dio = Dio();
    _dio.options.baseUrl = 'http://localhost:3000';
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };

    // Add token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add JWT token if available
          try {
            final authController = GetX.Get.find<AuthController>();
            final token = authController.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            // AuthController not found or no token available
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired, handle based on remember me setting
            try {
              final authController = GetX.Get.find<AuthController>();
              if (authController.rememberMe) {
                // For remember me users, show a different message and redirect to login
                // without clearing all their data
                CustomSnackbar.authRequired('Session expired. Please login to continue.');
                // Navigate to login but keep remember me state
                GetX.Get.offAllNamed('/login');
              } else {
                // For non-remember me users, full logout
                CustomSnackbar.authRequired('Session expired. Please login again.');
                authController.logout();
              }
            } catch (e) {
              // Handle case where AuthController is not available
              CustomSnackbar.authRequired('Session expired. Please login again.');
              GetX.Get.offAllNamed('/login');
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Get all patients with optional filtering and pagination
  Future<PatientsResponse> getPatients({
    int page = 1,
    int limit = 10,
    String? search,
    String? gender,
    String? ageRange,
    String? diabetesMed,
    String? readmitted,
    String? sortBy,
    String? sortOrder,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      // Add optional filters
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;
      if (ageRange != null && ageRange.isNotEmpty) queryParams['age_range'] = ageRange;
      if (diabetesMed != null && diabetesMed.isNotEmpty) queryParams['diabetesMed'] = diabetesMed;
      if (readmitted != null && readmitted.isNotEmpty) queryParams['readmitted'] = readmitted;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;
      if (sortOrder != null && sortOrder.isNotEmpty) queryParams['sort_order'] = sortOrder;
      if (dateFrom != null && dateFrom.isNotEmpty) queryParams['date_from'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) queryParams['date_to'] = dateTo;

      final response = await _dio.get('/patients', queryParameters: queryParams);
      return PatientsResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get patient by ID
  Future<PatientModel> getPatientById(String id) async {
    try {
      final response = await _dio.get('/patients/$id');
      final apiResponse = ApiResponse.fromJson(response.data);
      return PatientModel.fromApiJson(apiResponse.body['patient']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get patient by encounter ID
  Future<PatientModel> getPatientByEncounterId(int encounterId) async {
    try {
      final response = await _dio.get('/patients/encounter/$encounterId');
      final apiResponse = ApiResponse.fromJson(response.data);
      return PatientModel.fromApiJson(apiResponse.body['patient']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get patient by patient number
  Future<PatientModel> getPatientByPatientNumber(int patientNumber) async {
    try {
      final response = await _dio.get('/patients/patient-number/$patientNumber');
      final apiResponse = ApiResponse.fromJson(response.data);
      return PatientModel.fromApiJson(apiResponse.body['patient']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new patient
  Future<PatientModel> createPatient(Map<String, dynamic> patientData) async {
    try {
      final response = await _dio.post('/patients', data: patientData);
      final apiResponse = ApiResponse.fromJson(response.data);
      return PatientModel.fromApiJson(apiResponse.body['patient']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update existing patient
  Future<PatientModel> updatePatient(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put('/patients/$id', data: updates);
      final apiResponse = ApiResponse.fromJson(response.data);
      return PatientModel.fromApiJson(apiResponse.body['patient']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete patient
  Future<void> deletePatient(String id) async {
    try {
      await _dio.delete('/patients/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get patient statistics
  Future<PatientStats> getPatientStats() async {
    try {
      final response = await _dio.get('/patients/stats');
      final apiResponse = ApiResponse.fromJson(response.data);
      return PatientStats.fromJson(apiResponse.body['stats']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Import sample data
  Future<void> importSampleData() async {
    try {
      await _dio.post('/patients/import-sample');
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message'];
        }
        return 'HTTP ${error.response!.statusCode}: ${error.response!.statusMessage}';
      }
      return 'Network error: ${error.message}';
    }
    return error.toString();
  }
}

// Response models for API integration
class PatientsResponse {
  final int code;
  final String message;
  final PatientsBody body;

  PatientsResponse({
    required this.code,
    required this.message,
    required this.body,
  });

  factory PatientsResponse.fromJson(Map<String, dynamic> json) {
    return PatientsResponse(
      code: json['code'],
      message: json['message'],
      body: PatientsBody.fromJson(json['body']),
    );
  }
}

class PatientsBody {
  final List<PatientModel> patients;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PatientsBody({
    required this.patients,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PatientsBody.fromJson(Map<String, dynamic> json) {
    return PatientsBody(
      patients: (json['patients'] as List)
          .map((patientJson) => PatientModel.fromApiJson(patientJson))
          .toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['total_pages'],
    );
  }
}

class ApiResponse {
  final int code;
  final String message;
  final Map<String, dynamic> body;

  ApiResponse({
    required this.code,
    required this.message,
    required this.body,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'],
      message: json['message'],
      body: json['body'],
    );
  }
}

class PatientStats {
  final int totalPatients;
  final Map<String, int> byGender;
  final Map<String, int> byAgeGroup;
  final Map<String, int> byDiabetesMedication;
  final Map<String, int> byReadmission;
  final double averageHospitalStay;
  final double averageMedications;

  PatientStats({
    required this.totalPatients,
    required this.byGender,
    required this.byAgeGroup,
    required this.byDiabetesMedication,
    required this.byReadmission,
    required this.averageHospitalStay,
    required this.averageMedications,
  });

  factory PatientStats.fromJson(Map<String, dynamic> json) {
    return PatientStats(
      totalPatients: json['total_patients'],
      byGender: Map<String, int>.from(json['by_gender']),
      byAgeGroup: Map<String, int>.from(json['by_age_group']),
      byDiabetesMedication: Map<String, int>.from(json['by_diabetes_medication']),
      byReadmission: Map<String, int>.from(json['by_readmission']),
      averageHospitalStay: (json['average_hospital_stay'] as num).toDouble(),
      averageMedications: (json['average_medications'] as num).toDouble(),
    );
  }
}
