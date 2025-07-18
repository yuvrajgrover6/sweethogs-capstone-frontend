import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../constants/storage_constants.dart';
import '../../../models/user_model.dart';
import '../../../models/auth_model.dart';

class AuthLocalDataSource {
  final GetStorage _storage = GetStorage();

  // Token management
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(StorageConstants.accessToken, accessToken);
    await _storage.write(StorageConstants.refreshToken, refreshToken);
  }

  Future<void> saveAuthData(AuthModel authModel) async {
    await _storage.write(StorageConstants.accessToken, authModel.accessToken);
    await _storage.write(StorageConstants.refreshToken, authModel.refreshToken);
    await _storage.write(
      StorageConstants.tokenExpiryTime,
      authModel.expiresAt.toIso8601String(),
    );
  }

  String? getAccessToken() {
    return _storage.read(StorageConstants.accessToken);
  }

  String? getRefreshToken() {
    return _storage.read(StorageConstants.refreshToken);
  }

  DateTime? getTokenExpiryTime() {
    final expiryString = _storage.read(StorageConstants.tokenExpiryTime);
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null;
  }

  bool isTokenExpired() {
    final expiryTime = getTokenExpiryTime();
    // If no expiry time is set, consider token invalid
    if (expiryTime == null) {
      return true;
    }
    return DateTime.now().isAfter(expiryTime);
  }

  // User profile management
  Future<void> saveUserProfile(UserModel user) async {
    await _storage.write(
      StorageConstants.userProfile,
      jsonEncode(user.toJson()),
    );
  }

  UserModel? getUserProfile() {
    final userJson = _storage.read(StorageConstants.userProfile);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Authentication state
  Future<void> setLoggedIn(bool isLoggedIn) async {
    await _storage.write(StorageConstants.isLoggedIn, isLoggedIn);
  }

  bool isLoggedIn() {
    return _storage.read(StorageConstants.isLoggedIn) ?? false;
  }

  // Remember me functionality
  Future<void> setRememberMe(bool rememberMe) async {
    await _storage.write(StorageConstants.rememberMe, rememberMe);
  }

  bool getRememberMe() {
    return _storage.read(StorageConstants.rememberMe) ?? false;
  }

  // Biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(StorageConstants.biometricEnabled, enabled);
  }

  bool isBiometricEnabled() {
    return _storage.read(StorageConstants.biometricEnabled) ?? false;
  }

  // Clear auth data (preserves remember me and biometric settings)
  Future<void> clearAuthData() async {
    await _storage.remove(StorageConstants.accessToken);
    await _storage.remove(StorageConstants.refreshToken);
    await _storage.remove(StorageConstants.tokenExpiryTime);
    
    // If remember me is enabled, keep user logged in and preserve profile
    final rememberMe = getRememberMe();
    if (!rememberMe) {
      await _storage.remove(StorageConstants.userProfile);
      await _storage.write(StorageConstants.isLoggedIn, false);
    }
    // Note: When remember me is enabled, we keep isLoggedIn=true and userProfile
  }

  // Clear all auth data including user preferences (for complete logout)
  Future<void> clearAllAuthData() async {
    await _storage.remove(StorageConstants.accessToken);
    await _storage.remove(StorageConstants.refreshToken);
    await _storage.remove(StorageConstants.userProfile);
    await _storage.remove(StorageConstants.tokenExpiryTime);
    await _storage.write(StorageConstants.isLoggedIn, false);
    await _storage.remove(StorageConstants.rememberMe);
    await _storage.remove(StorageConstants.biometricEnabled);
  }

  // Theme and preferences
  Future<void> saveThemeMode(String themeMode) async {
    await _storage.write(StorageConstants.themeMode, themeMode);
  }

  String? getThemeMode() {
    return _storage.read(StorageConstants.themeMode);
  }

  Future<void> saveLanguage(String language) async {
    await _storage.write(StorageConstants.language, language);
  }

  String? getLanguage() {
    return _storage.read(StorageConstants.language);
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    await _storage.write(StorageConstants.onboardingCompleted, completed);
  }

  bool isOnboardingCompleted() {
    return _storage.read(StorageConstants.onboardingCompleted) ?? false;
  }

  // Check if user has valid session
  bool hasValidSession() {
    final accessToken = getAccessToken();
    final isLoggedIn = this.isLoggedIn();
    final isExpired = isTokenExpired();

    // For valid session, we need a valid token that's not expired
    return accessToken != null && isLoggedIn && !isExpired;
  }

  // Check if user should remain logged in (for UI purposes)
  bool shouldStayLoggedIn() {
    final isLoggedIn = this.isLoggedIn();
    final rememberMe = getRememberMe();
    
    // If remember me is enabled and user was logged in, keep them logged in
    return rememberMe && isLoggedIn;
  }
}
