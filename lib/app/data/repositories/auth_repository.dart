import 'dart:developer';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../../models/user_model.dart';
import '../../models/api_response_model.dart';
import '../../models/login_response_model.dart';
import '../../models/auth_model.dart';

class AuthRepository {
  final AuthLocalDataSource _localDataSource = AuthLocalDataSource();
  final AuthRemoteDataSource _remoteDataSource = AuthRemoteDataSource();

  // Login
  Future<ApiResponseModel<LoginResponseModel>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (response.success && response.body != null) {
        final loginData = response.body!;

        // Save tokens with expiry time
        if (loginData.expiresAt != null) {
          await _localDataSource.saveAuthData(
            AuthModel(
              accessToken: loginData.accessToken,
              refreshToken: loginData.refreshToken,
              expiresAt: loginData.expiresAt!,
            ),
          );
        } else {
          await _localDataSource.saveTokens(
            loginData.accessToken,
            loginData.refreshToken,
          );
        }

        // Create and save full user profile from login user data
        // Note: For full profile, we'll need to fetch it separately
        // But for now, save what we have from login response
        final basicUser = UserModel(
          id: loginData.user.id,
          email: loginData.user.email,
          firstName: '', // These will be filled when we fetch full profile
          lastName: '',
          role: loginData.user.role,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 0,
        );
        await _localDataSource.saveUserProfile(basicUser);

        // Update authentication state
        await _localDataSource.setLoggedIn(true);
        await _localDataSource.setRememberMe(rememberMe);
      }

      return response;
    } catch (e) {
      log('Login repository error: $e');
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
      final response = await _remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (response.success && response.body != null) {
        final loginData = response.body!;

        // Save tokens (auto login after registration)
        if (loginData.expiresAt != null) {
          await _localDataSource.saveAuthData(
            AuthModel(
              accessToken: loginData.accessToken,
              refreshToken: loginData.refreshToken,
              expiresAt: loginData.expiresAt!,
            ),
          );
        } else {
          await _localDataSource.saveTokens(
            loginData.accessToken,
            loginData.refreshToken,
          );
        }
        await _localDataSource.setLoggedIn(true);

        // Create and save basic user profile
        final basicUser = UserModel(
          id: loginData.user.id,
          email: loginData.user.email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          role: loginData.user.role,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 0,
        );
        await _localDataSource.saveUserProfile(basicUser);
      }

      return response;
    } catch (e) {
      log('Register repository error: $e');
      rethrow;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = _localDataSource.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );

      if (response.success && response.body != null) {
        final loginData = response.body!;

        if (loginData.expiresAt != null) {
          await _localDataSource.saveAuthData(
            AuthModel(
              accessToken: loginData.accessToken,
              refreshToken: loginData.refreshToken,
              expiresAt: loginData.expiresAt!,
            ),
          );
        } else {
          await _localDataSource.saveTokens(
            loginData.accessToken,
            loginData.refreshToken,
          );
        }
        return true;
      }

      return false;
    } catch (e) {
      log('Refresh token repository error: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call remote logout if user is logged in
      if (_localDataSource.isLoggedIn()) {
        try {
          await _remoteDataSource.logout();
        } catch (e) {
          log('Remote logout error: $e');
          // Continue with local logout even if remote fails
        }
      }

      // Clear local data
      await _localDataSource.clearAuthData();
    } catch (e) {
      log('Logout repository error: $e');
      // Always clear local data even if remote logout fails
      await _localDataSource.clearAuthData();
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile() async {
    try {
      // First check local storage
      final localUser = _localDataSource.getUserProfile();

      // If user is logged in, try to get fresh data from remote
      if (_localDataSource.isLoggedIn() && !_localDataSource.isTokenExpired()) {
        try {
          final response = await _remoteDataSource.getUserProfile();
          if (response.success && response.data != null) {
            await _localDataSource.saveUserProfile(response.data!);
            return response.data;
          }
        } catch (e) {
          log('Get user profile remote error: $e');
          // Return local data if remote fails
        }
      }

      return localUser;
    } catch (e) {
      log('Get user profile repository error: $e');
      return _localDataSource.getUserProfile();
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
      final response = await _remoteDataSource.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
      );

      if (response.success && response.data != null) {
        await _localDataSource.saveUserProfile(response.data!);
      }

      return response;
    } catch (e) {
      log('Update user profile repository error: $e');
      rethrow;
    }
  }

  // Forgot password
  Future<ApiResponseModel<void>> forgotPassword({required String email}) async {
    try {
      return await _remoteDataSource.forgotPassword(email: email);
    } catch (e) {
      log('Forgot password repository error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<ApiResponseModel<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      return await _remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
    } catch (e) {
      log('Reset password repository error: $e');
      rethrow;
    }
  }

  // Change password
  Future<ApiResponseModel<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      log('Change password repository error: $e');
      rethrow;
    }
  }

  // Verify email
  Future<ApiResponseModel<void>> verifyEmail({required String token}) async {
    try {
      return await _remoteDataSource.verifyEmail(token: token);
    } catch (e) {
      log('Verify email repository error: $e');
      rethrow;
    }
  }

  // Resend verification email
  Future<ApiResponseModel<void>> resendVerificationEmail() async {
    try {
      return await _remoteDataSource.resendVerificationEmail();
    } catch (e) {
      log('Resend verification email repository error: $e');
      rethrow;
    }
  }

  // Local data access methods
  bool isLoggedIn() {
    return _localDataSource.isLoggedIn();
  }

  bool hasValidSession() {
    return _localDataSource.hasValidSession();
  }

  bool isTokenExpired() {
    return _localDataSource.isTokenExpired();
  }

  String? getAccessToken() {
    return _localDataSource.getAccessToken();
  }

  String? getRefreshToken() {
    return _localDataSource.getRefreshToken();
  }

  bool getRememberMe() {
    return _localDataSource.getRememberMe();
  }

  DateTime? getTokenExpiryTime() {
    return _localDataSource.getTokenExpiryTime();
  }

  bool isBiometricEnabled() {
    return _localDataSource.isBiometricEnabled();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _localDataSource.setBiometricEnabled(enabled);
  }

  // Theme and preferences
  Future<void> saveThemeMode(String themeMode) async {
    await _localDataSource.saveThemeMode(themeMode);
  }

  String? getThemeMode() {
    return _localDataSource.getThemeMode();
  }

  Future<void> saveLanguage(String language) async {
    await _localDataSource.saveLanguage(language);
  }

  String? getLanguage() {
    return _localDataSource.getLanguage();
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    await _localDataSource.setOnboardingCompleted(completed);
  }

  bool isOnboardingCompleted() {
    return _localDataSource.isOnboardingCompleted();
  }
}
