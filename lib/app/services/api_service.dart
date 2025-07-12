import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';
import '../routes/app_routes.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;
  final GetStorage _storage = GetStorage();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {ApiConstants.contentType: 'application/json'},
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.read(StorageConstants.accessToken);
          if (token != null) {
            options.headers[ApiConstants.authorization] =
                '${ApiConstants.bearer} $token';
          }
          log('Request: ${options.method} ${options.uri}');
          log('Headers: ${options.headers}');
          log('Data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          log(
            'Response: ${response.statusCode} ${response.requestOptions.uri}',
          );
          log('Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) async {
          log(
            'Error: ${error.response?.statusCode} ${error.requestOptions.uri}',
          );
          log('Error message: ${error.message}');
          log('Error type: ${error.type}');

          // Handle connection errors specifically
          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            log(
              'Connection error detected. Check if backend server is running.',
            );
          }

          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            log('401 error detected, attempting token refresh...');
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request
              log('Token refreshed, retrying original request...');
              final originalRequest = error.requestOptions;
              final token = _storage.read(StorageConstants.accessToken);
              originalRequest.headers[ApiConstants.authorization] =
                  '${ApiConstants.bearer} $token';

              try {
                final response = await _dio.fetch(originalRequest);
                handler.resolve(response);
                return;
              } catch (e) {
                log('Retry failed after token refresh: $e');
              }
            } else {
              log('Token refresh failed, redirecting to login');
            }

            // If refresh fails, redirect to login
            _handleUnauthorized();
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _storage.read(StorageConstants.refreshToken);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            ApiConstants.authorization: '${ApiConstants.bearer} $refreshToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle response structure based on backend API
        String? newAccessToken;
        String? newRefreshToken;
        String? expiresAt;

        // Check if response has the expected structure
        if (data['body'] != null) {
          // Backend returns nested structure: {code, message, body: {accessToken, refreshToken, user}}
          final body = data['body'];
          newAccessToken = body['accessToken'];
          newRefreshToken = body['refreshToken'];
          expiresAt = body['expiresAt'];
        } else {
          // Direct structure: {accessToken, refreshToken, expiresAt}
          newAccessToken = data['accessToken'];
          newRefreshToken = data['refreshToken'];
          expiresAt = data['expiresAt'];
        }

        if (newAccessToken != null && newRefreshToken != null) {
          await _storage.write(StorageConstants.accessToken, newAccessToken);
          await _storage.write(StorageConstants.refreshToken, newRefreshToken);

          if (expiresAt != null) {
            await _storage.write(StorageConstants.tokenExpiryTime, expiresAt);
          }

          log('Tokens refreshed successfully');
          return true;
        } else {
          log('Invalid refresh response structure: $data');
          return false;
        }
      } else {
        log('Refresh token failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Token refresh failed: $e');
    }
    return false;
  }

  void _handleUnauthorized() {
    _storage.remove(StorageConstants.accessToken);
    _storage.remove(StorageConstants.refreshToken);
    _storage.remove(StorageConstants.userProfile);
    _storage.write(StorageConstants.isLoggedIn, false);

    // Navigate to login page
    getx.Get.offAllNamed(AppRoutes.login);
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}
