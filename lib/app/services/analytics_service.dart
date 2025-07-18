import 'package:dio/dio.dart';
import 'package:get/get.dart' as GetX;
import '../models/analytics_models.dart';
import '../controllers/auth_controller.dart';
import '../utils/custom_snackbar.dart';

class AnalyticsService {
  late Dio _dio;

  AnalyticsService() {
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
                CustomSnackbar.authRequired('Session expired. Please login to continue.');
                GetX.Get.offAllNamed('/login');
              } else {
                CustomSnackbar.authRequired('Session expired. Please login again.');
                authController.logout();
              }
            } catch (e) {
              CustomSnackbar.authRequired('Session expired. Please login again.');
              GetX.Get.offAllNamed('/login');
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Get patient statistics
  Future<PatientStats> getPatientStats() async {
    try {
      final response = await _dio.get('/patients/stats');
      final statsResponse = PatientStatsResponse.fromJson(response.data);
      return statsResponse.body;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get patient analytics
  Future<PatientAnalytics> getPatientAnalytics() async {
    try {
      final response = await _dio.get('/patients/analytics');
      final analyticsResponse = PatientAnalyticsResponse.fromJson(response.data);
      return analyticsResponse.body;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle API errors
  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          switch (statusCode) {
            case 400:
              return 'Invalid request. Please try again.';
            case 401:
              return 'Authentication required. Please login.';
            case 403:
              return 'Access denied. You don\'t have permission to view analytics.';
            case 404:
              return 'Analytics data not found.';
            case 500:
              return 'Server error. Please try again later.';
            default:
              return 'Analytics request failed (Code: $statusCode)';
          }
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.unknown:
          return 'Network error. Please check your connection.';
        default:
          return 'An unexpected error occurred while fetching analytics.';
      }
    }
    return 'Failed to load analytics data: ${error.toString()}';
  }
}
