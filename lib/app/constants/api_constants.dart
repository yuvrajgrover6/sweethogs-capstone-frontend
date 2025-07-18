import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use different URLs for different platforms
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000' // For web development
      : 'http://10.0.2.2:3000'; // For Android emulator (iOS simulator uses localhost)

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String refreshToken = '$baseUrl/auth/refresh';
  static const String logout = '$baseUrl/auth/logout';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String changePassword = '$baseUrl/auth/change-password';
  static const String verifyEmail = '$baseUrl/auth/verify-email';
  static const String resendVerification = '$baseUrl/auth/resend-verification';

  // User endpoints
  static const String profile = '$baseUrl/user/profile';
  static const String updateProfile = '$baseUrl/user/update';

  // Readmission prediction endpoints
  static const String readmissionTest = '$baseUrl/readmission/test';
  static const String readmissionPredict = '$baseUrl/readmission/predict';
  static const String readmissionPredictBatch =
      '$baseUrl/readmission/predict/batch';
  static const String readmissionModelInfo = '$baseUrl/readmission/model-info';
  static const String readmissionGeneratePdf = '$baseUrl/readmission/generate-pdf';

  // Headers
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // Timeouts
  static const int connectTimeout = 60000;
  static const int receiveTimeout = 60000;
  static const int sendTimeout = 60000;
}
