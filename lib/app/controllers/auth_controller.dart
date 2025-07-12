import 'dart:developer';
import 'package:get/get.dart';
import '../data/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Reactive variables
  final RxBool _isLoading = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _rememberMe = false.obs;
  final RxBool _biometricEnabled = false.obs;

  // Getters - Reactive
  RxBool get isLoadingRx => _isLoading;
  RxBool get isLoggedInRx => _isLoggedIn;
  Rx<UserModel?> get currentUserRx => _currentUser;
  RxString get errorMessageRx => _errorMessage;
  RxBool get rememberMeRx => _rememberMe;
  RxBool get biometricEnabledRx => _biometricEnabled;

  // Getters - Non-reactive (for convenience)
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  UserModel? get currentUser => _currentUser.value;
  String get errorMessage => _errorMessage.value;
  bool get rememberMe => _rememberMe.value;
  bool get biometricEnabled => _biometricEnabled.value;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  // Initialize authentication state
  void _initializeAuth() async {
    _isLoggedIn.value = _authRepository.isLoggedIn();
    _rememberMe.value = _authRepository.getRememberMe();
    _biometricEnabled.value = _authRepository.isBiometricEnabled();

    if (_isLoggedIn.value) {
      // Check if token is valid/not expired
      if (!_authRepository.hasValidSession()) {
        // Try to refresh token if available
        final refreshSuccess = await refreshToken();
        if (!refreshSuccess) {
          // If refresh fails, logout user
          await logout();
          return;
        }
      }
      await _loadUserProfile();
    }
  }

  // Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final user = await _authRepository.getUserProfile();
      if (user != null) {
        _currentUser.value = user;
      }
    } catch (e) {
      log('Error loading user profile: $e');
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (response.success) {
        _isLoggedIn.value = true;
        _rememberMe.value = rememberMe;

        // Load user profile
        await _loadUserProfile();

        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navigate to home page
        Get.offAllNamed(AppRoutes.home);

        return true;
      } else {
        _errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      log('Login error: $e');
      _errorMessage.value = 'Login failed. Please try again.';
      Get.snackbar(
        'Error',
        'Login failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (response.success) {
        // Check if auto-login after registration
        if (response.body?.accessToken != null) {
          _isLoggedIn.value = true;
          await _loadUserProfile();

          Get.snackbar(
            'Success',
            'Registration successful!',
            snackPosition: SnackPosition.BOTTOM,
          );

          // Navigate to home page after auto-login
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.snackbar(
            'Success',
            'Registration successful! Please login.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }

        return true;
      } else {
        _errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      log('Register error: $e');
      _errorMessage.value = 'Registration failed. Please try again.';
      Get.snackbar(
        'Error',
        'Registration failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading.value = true;

      await _authRepository.logout();

      _isLoggedIn.value = false;
      _currentUser.value = null;
      _errorMessage.value = '';

      Get.snackbar(
        'Success',
        'Logged out successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to login page
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      log('Logout error: $e');
      // Force logout even if remote call fails
      _isLoggedIn.value = false;
      _currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      log('Attempting to refresh token...');
      final success = await _authRepository.refreshToken();
      if (!success) {
        log('Refresh token failed - logging out user');
        await logout();
      } else {
        log('Token refreshed successfully');
      }
      return success;
    } catch (e) {
      log('Refresh token error: $e');
      await logout();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
      );

      if (response.success && response.data != null) {
        _currentUser.value = response.data;

        Get.snackbar(
          'Success',
          'Profile updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      } else {
        _errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      log('Update profile error: $e');
      _errorMessage.value = 'Profile update failed. Please try again.';
      Get.snackbar(
        'Error',
        'Profile update failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Forgot password
  Future<bool> forgotPassword({required String email}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.forgotPassword(email: email);

      if (response.success) {
        Get.snackbar(
          'Success',
          'Password reset email sent!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      log('Forgot password error: $e');
      _errorMessage.value = 'Failed to send reset email. Please try again.';
      Get.snackbar(
        'Error',
        'Failed to send reset email. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Password reset successful!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      log('Reset password error: $e');
      _errorMessage.value = 'Password reset failed. Please try again.';
      Get.snackbar(
        'Error',
        'Password reset failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Password changed successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      log('Change password error: $e');
      _errorMessage.value = 'Password change failed. Please try again.';
      Get.snackbar(
        'Error',
        'Password change failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Verify email
  Future<bool> verifyEmail({required String token}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.verifyEmail(token: token);

      if (response.success) {
        // Reload user profile to reflect verification status
        await _loadUserProfile();

        Get.snackbar(
          'Success',
          'Email verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      log('Verify email error: $e');
      _errorMessage.value = 'Email verification failed. Please try again.';
      Get.snackbar(
        'Error',
        'Email verification failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Resend verification email
  Future<bool> resendVerificationEmail() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.resendVerificationEmail();

      if (response.success) {
        Get.snackbar(
          'Success',
          'Verification email sent!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      log('Resend verification email error: $e');
      _errorMessage.value =
          'Failed to send verification email. Please try again.';
      Get.snackbar(
        'Error',
        'Failed to send verification email. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _authRepository.setBiometricEnabled(enabled);
      _biometricEnabled.value = enabled;
    } catch (e) {
      log('Set biometric enabled error: $e');
    }
  }

  // Check authentication state
  bool hasValidSession() {
    return _authRepository.hasValidSession();
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage.value = '';
  }

  // Set remember me
  void setRememberMe(bool remember) {
    _rememberMe.value = remember;
  }

  // Periodic token validation (call this periodically in your app)
  Future<void> validateSession() async {
    if (_isLoggedIn.value && !_authRepository.hasValidSession()) {
      final refreshSuccess = await refreshToken();
      if (!refreshSuccess) {
        await logout();
      }
    }
  }

  // Check if session is about to expire (within 5 minutes)
  bool isSessionAboutToExpire() {
    final expiryTime = _authRepository.getTokenExpiryTime();
    if (expiryTime == null) return true;

    final fiveMinutesFromNow = DateTime.now().add(Duration(minutes: 5));
    return expiryTime.isBefore(fiveMinutesFromNow);
  }

  // Proactive token refresh (call when session is about to expire)
  Future<void> proactiveTokenRefresh() async {
    if (_isLoggedIn.value && isSessionAboutToExpire()) {
      await refreshToken();
    }
  }

  // Test method to verify refresh token rotation (for debugging/testing)
  Future<Map<String, dynamic>> testRefreshTokenRotation() async {
    final Map<String, dynamic> testResults = {};

    try {
      final initialRefreshToken = _authRepository.getRefreshToken();
      testResults['initialRefreshToken'] =
          initialRefreshToken?.substring(0, 10) ?? 'null';

      // First refresh
      final firstRefresh = await refreshToken();
      testResults['firstRefreshSuccess'] = firstRefresh;

      final secondRefreshToken = _authRepository.getRefreshToken();
      testResults['secondRefreshToken'] =
          secondRefreshToken?.substring(0, 10) ?? 'null';

      // Check if tokens are different (rotation working)
      testResults['tokensRotated'] = initialRefreshToken != secondRefreshToken;

      log('Refresh token rotation test results: $testResults');
      return testResults;
    } catch (e) {
      log('Refresh token rotation test error: $e');
      testResults['error'] = e.toString();
      return testResults;
    }
  }

  // Public getter for testing purposes
  AuthRepository get authRepository => _authRepository;
}
