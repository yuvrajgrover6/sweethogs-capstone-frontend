import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/storage_constants.dart';
import '../../../models/user_model.dart';
import '../../../models/api_response_model.dart';
import '../../../models/login_response_model.dart';
import '../../../services/api_service.dart';

class AuthRemoteDataSource {
  final ApiService _apiService = ApiService();

  // Login
  Future<ApiResponseModel<LoginResponseModel>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      print('Logging in with email: $email, rememberMe: $rememberMe');
      print('Using API endpoint: ${ApiConstants.login}');

      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password, 'rememberMe': rememberMe},
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return ApiResponseModel<LoginResponseModel>.fromJson(
        response.data!,
        (json) => LoginResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      log('Login error: $e');
      rethrow;
    }
  }

  // Register
  Future<ApiResponseModel<LoginResponseModel>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return ApiResponseModel<LoginResponseModel>.fromJson(
        response.data!,
        (json) => LoginResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      log('Register error: $e');
      rethrow;
    }
  }

  // Refresh token
  Future<ApiResponseModel<LoginResponseModel>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      log('RemoteDataSource: Attempting refresh token...');
      final response = await _apiService.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      log('RemoteDataSource: Refresh token response received');
      return ApiResponseModel<LoginResponseModel>.fromJson(
        response.data!,
        (json) => LoginResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      log('Refresh token error: $e');

      // For 401 errors (invalid/expired refresh token), return proper error
      if (e is DioException && e.response?.statusCode == 401) {
        log('Refresh token returned 401 - token is invalid');
        return ApiResponseModel<LoginResponseModel>(
          code: 401,
          message: 'Refresh token is invalid or expired',
        );
      }

      // For other errors, return failure
      return ApiResponseModel<LoginResponseModel>(
        code: 500,
        message: 'Failed to refresh token: ${e.toString()}',
      );
    }
  }

  // Logout
  Future<ApiResponseModel<void>> logout() async {
    try {
      // Get refresh token for logout request (backend requires it for proper invalidation)
      final refreshToken = GetStorage().read(StorageConstants.refreshToken);

      final response = await _apiService.post(
        ApiConstants.logout,
        data: refreshToken != null ? {'refreshToken': refreshToken} : null,
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return ApiResponseModel<void>.fromJson(response.data!, (json) {});
    } catch (e) {
      log('Logout error: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<ApiResponseModel<UserModel>> getUserProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.profile);

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return ApiResponseModel<UserModel>.fromJson(
        response.data!,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      log('Get user profile error: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<ApiResponseModel<UserModel>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
      if (dateOfBirth != null) {
        data['dateOfBirth'] = dateOfBirth.toIso8601String();
      }

      final response = await _apiService.put(
        ApiConstants.updateProfile,
        data: data,
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return ApiResponseModel<UserModel>.fromJson(
        response.data!,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      log('Update user profile error: $e');
      rethrow;
    }
  }

  // Forgot password
  Future<ApiResponseModel<void>> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return ApiResponseModel<void>.fromJson(response.data!, (json) {});
    } catch (e) {
      log('Forgot password error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<ApiResponseModel<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.resetPassword,
        data: {'token': token, 'newPassword': newPassword},
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return ApiResponseModel<void>.fromJson(response.data!, (json) {});
    } catch (e) {
      log('Reset password error: $e');
      rethrow;
    }
  }

  // Change password
  Future<ApiResponseModel<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return ApiResponseModel<void>.fromJson(response.data!, (json) {});
    } catch (e) {
      log('Change password error: $e');
      rethrow;
    }
  }

  // Verify email
  Future<ApiResponseModel<void>> verifyEmail({required String token}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.verifyEmail,
        data: {'token': token},
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return ApiResponseModel<void>.fromJson(response.data!, (json) {});
    } catch (e) {
      log('Verify email error: $e');
      rethrow;
    }
  }

  // Resend verification email
  Future<ApiResponseModel<void>> resendVerificationEmail() async {
    try {
      final response = await _apiService.post(ApiConstants.resendVerification);

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return ApiResponseModel<void>.fromJson(response.data!, (json) {});
    } catch (e) {
      log('Resend verification email error: $e');
      rethrow;
    }
  }
}
