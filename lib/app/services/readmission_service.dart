import 'dart:developer';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/patient_model.dart';
import '../models/readmission_prediction_model.dart';
import 'api_service.dart';

class ReadmissionService {
  static final ReadmissionService _instance = ReadmissionService._internal();
  late final ApiService _apiService;

  factory ReadmissionService() {
    return _instance;
  }

  ReadmissionService._internal() {
    _apiService = ApiService();
  }

  /// Test prediction endpoint (public)
  /// Returns a test prediction for endpoint verification
  Future<ReadmissionApiResponse> testPrediction() async {
    try {
      log('Calling test prediction endpoint...');

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.readmissionTest,
      );

      if (response.statusCode == 200 && response.data != null) {
        return ReadmissionApiResponse.fromJson(response.data!);
      } else {
        throw Exception(
          'Failed to get test prediction: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      log('DioException in testPrediction: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      log('Exception in testPrediction: $e');
      throw Exception('Failed to get test prediction: $e');
    }
  }

  /// Predict readmission for a single patient (protected)
  /// Requires authentication
  Future<ReadmissionApiResponse> predictSinglePatient(
    PatientModel patient,
  ) async {
    try {
      log('Calling single patient prediction for ${patient.patientId}...');

      final requestBody = {'patientData': patient.toApiJson()};

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.readmissionPredict,
        data: requestBody,
      );

      if (response.statusCode == 200 && response.data != null) {
        return ReadmissionApiResponse.fromJson(response.data!);
      } else {
        throw Exception(
          'Failed to predict readmission: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      log('DioException in predictSinglePatient: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      log('Exception in predictSinglePatient: $e');
      throw Exception('Failed to predict readmission: $e');
    }
  }

  /// Predict readmission for multiple patients (protected)
  /// Requires authentication, max 100 patients
  Future<ReadmissionBatchApiResponse> predictBatchPatients(
    List<PatientModel> patients,
  ) async {
    try {
      if (patients.length > 100) {
        throw Exception('Maximum 100 patients allowed per batch request');
      }

      log('Calling batch prediction for ${patients.length} patients...');

      final requestBody = {
        'patientsData': patients.map((patient) => patient.toApiJson()).toList(),
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.readmissionPredictBatch,
        data: requestBody,
      );

      if (response.statusCode == 200 && response.data != null) {
        return ReadmissionBatchApiResponse.fromJson(response.data!);
      } else {
        throw Exception(
          'Failed to predict batch readmission: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      log('DioException in predictBatchPatients: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      log('Exception in predictBatchPatients: $e');
      throw Exception('Failed to predict batch readmission: $e');
    }
  }

  /// Get model information (protected)
  /// Returns information about the prediction model
  Future<ModelInfoResponse> getModelInfo() async {
    try {
      log('Calling model info endpoint...');

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.readmissionModelInfo,
      );

      if (response.statusCode == 200 && response.data != null) {
        return ModelInfoResponse.fromJson(response.data!);
      } else {
        throw Exception('Failed to get model info: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('DioException in getModelInfo: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      log('Exception in getModelInfo: $e');
      throw Exception('Failed to get model info: $e');
    }
  }

  /// Handle Dio exceptions and convert to meaningful error messages
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return Exception('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Exception('Server response timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        switch (statusCode) {
          case 400:
            return Exception(
              'Invalid patient data: ${_extractErrorMessage(data)}',
            );
          case 401:
            return Exception('Authentication required. Please login again.');
          case 403:
            return Exception('Access denied. Insufficient permissions.');
          case 404:
            return Exception('Prediction service not found.');
          case 500:
            return Exception('Server error. Please try again later.');
          default:
            return Exception(
              'Server error (${statusCode}): ${_extractErrorMessage(data)}',
            );
        }
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception(
          'Unable to connect to server. Please check if the backend is running on localhost:3000',
        );
      case DioExceptionType.badCertificate:
        return Exception('SSL certificate error.');
      case DioExceptionType.unknown:
        return Exception('Network error: ${e.message}');
    }
  }

  /// Extract error message from API response
  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Unknown error';

    try {
      if (data is Map<String, dynamic>) {
        // Check for API error structure
        if (data['message'] != null) {
          return data['message'].toString();
        }

        // Check for validation errors
        if (data['body'] != null && data['body']['validationErrors'] != null) {
          final errors = data['body']['validationErrors'] as List;
          if (errors.isNotEmpty) {
            return errors.map((e) => e['message']).join(', ');
          }
        }

        return data.toString();
      }

      return data.toString();
    } catch (e) {
      return 'Error parsing server response';
    }
  }
}
