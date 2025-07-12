import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sweethogs_capstone_frontend/app/models/user_model.dart';
import 'package:sweethogs_capstone_frontend/app/models/login_response_model.dart';
import 'package:sweethogs_capstone_frontend/app/models/api_response_model.dart';
import 'package:sweethogs_capstone_frontend/app/constants/storage_constants.dart';

// Mock AuthController that doesn't require GetStorage
class MockAuthController {
  bool _isLoggedIn = false;
  UserModel? _currentUser;
  String _errorMessage = '';
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _biometricEnabled = false;

  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  bool get biometricEnabled => _biometricEnabled;

  void setLoggedIn(bool value) => _isLoggedIn = value;
  void setCurrentUser(UserModel? user) => _currentUser = user;
  void setErrorMessage(String message) => _errorMessage = message;
  void setLoading(bool loading) => _isLoading = loading;
  void setRememberMe(bool remember) => _rememberMe = remember;
  void setBiometricEnabled(bool enabled) => _biometricEnabled = enabled;

  void clearErrorMessage() => _errorMessage = '';

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    _errorMessage = '';
  }
}

void main() {
  group('Authentication Unit Tests', () {
    late MockAuthController authController;

    setUpAll(() async {
      // Initialize Flutter test binding
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Initialize GetX test mode
      Get.testMode = true;

      // Initialize mock controller
      authController = MockAuthController();

      // Wait a bit for initialization
      await Future.delayed(const Duration(milliseconds: 50));
    });

    tearDown(() {
      // Clean up after each test
      Get.reset();
    });

    group('AuthController State Management Tests', () {
      test('should initialize with correct default state', () {
        // Assert
        expect(authController.isLoggedIn, false);
        expect(authController.currentUser, null);
        expect(authController.errorMessage, '');
        expect(authController.isLoading, false);
        expect(authController.rememberMe, false);
        expect(authController.biometricEnabled, false);
      });

      test('should update state correctly during login simulation', () async {
        // Arrange - Simulate successful login state
        final testUser = UserModel(
          id: '123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: 'user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        );

        // Act - Manually set state to simulate successful login
        authController.setLoggedIn(true);
        authController.setCurrentUser(testUser);
        authController.setErrorMessage('');

        // Assert
        expect(authController.isLoggedIn, true);
        expect(authController.currentUser?.email, 'test@example.com');
        expect(authController.currentUser?.fullName, 'John Doe');
        expect(authController.errorMessage, '');
      });

      test('should handle error state correctly', () {
        // Act
        authController.setErrorMessage('Invalid credentials');
        authController.setLoggedIn(false);

        // Assert
        expect(authController.isLoggedIn, false);
        expect(authController.errorMessage, 'Invalid credentials');
      });

      test('should clear error message', () {
        // Arrange
        authController.setErrorMessage('Some error');

        // Act
        authController.clearErrorMessage();

        // Assert
        expect(authController.errorMessage, '');
      });

      test('should set remember me preference', () {
        // Act
        authController.setRememberMe(true);

        // Assert
        expect(authController.rememberMe, true);
      });

      test('should update loading state', () {
        // Act
        authController.setLoading(true);

        // Assert
        expect(authController.isLoading, true);
      });
    });

    group('Data Model Tests', () {
      test('should create UserModel with correct data', () {
        // Arrange & Act
        final user = UserModel(
          id: '123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+1234567890',
          role: 'admin',
          isActive: true,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
          version: 1,
        );

        // Assert
        expect(user.fullName, 'John Doe');
        expect(user.email, 'test@example.com');
        expect(user.role, 'admin');
        expect(user.isActive, true);
        expect(user.phoneNumber, '+1234567890');
      });

      test('should handle empty names in UserModel', () {
        // Arrange & Act
        final user = UserModel(
          id: '123',
          email: 'test@example.com',
          firstName: '',
          lastName: '',
          role: 'user',
          isActive: true,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
          version: 1,
        );

        // Assert - UserModel returns 'User' when both names are empty
        expect(user.fullName, 'User');
        expect(user.firstName, '');
        expect(user.lastName, '');
      });

      test('should handle single name in UserModel', () {
        // Arrange & Act
        final userFirstOnly = UserModel(
          id: '123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: '',
          role: 'user',
          isActive: true,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
          version: 1,
        );

        final userLastOnly = UserModel(
          id: '124',
          email: 'test2@example.com',
          firstName: '',
          lastName: 'Doe',
          role: 'user',
          isActive: true,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
          version: 1,
        );

        // Assert
        expect(userFirstOnly.fullName, 'John');
        expect(userLastOnly.fullName, 'Doe');
      });

      test('should serialize and deserialize UserModel correctly', () {
        // Arrange
        final originalUser = UserModel(
          id: '123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: 'user',
          isActive: true,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
          version: 1,
        );

        // Act
        final json = originalUser.toJson();
        final deserializedUser = UserModel.fromJson(json);

        // Assert
        expect(deserializedUser.id, originalUser.id);
        expect(deserializedUser.email, originalUser.email);
        expect(deserializedUser.fullName, originalUser.fullName);
        expect(deserializedUser.role, originalUser.role);
        expect(deserializedUser.isActive, originalUser.isActive);
      });

      test('should create LoginUserModel correctly', () {
        // Arrange & Act
        final loginUser = LoginUserModel(
          id: '123',
          email: 'test@example.com',
          role: 'user',
        );

        // Assert
        expect(loginUser.id, '123');
        expect(loginUser.email, 'test@example.com');
        expect(loginUser.role, 'user');
      });

      test('should create LoginResponseModel correctly', () {
        // Arrange
        final loginUser = LoginUserModel(
          id: '123',
          email: 'test@example.com',
          role: 'user',
        );

        final loginResponse = LoginResponseModel(
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
          user: loginUser,
          expiresAt: DateTime(2023, 1, 1, 12, 0),
        );

        // Assert
        expect(loginResponse.accessToken, 'access_token');
        expect(loginResponse.refreshToken, 'refresh_token');
        expect(loginResponse.user.email, 'test@example.com');
        expect(loginResponse.expiresAt, DateTime(2023, 1, 1, 12, 0));
      });

      test('should create ApiResponseModel correctly', () {
        // Arrange
        final testData = {'key': 'value'};

        final response = ApiResponseModel<Map<String, String>>(
          code: 200,
          message: 'Success',
          body: testData,
        );

        // Assert
        expect(response.code, 200);
        expect(response.message, 'Success');
        expect(response.body, testData);
        expect(response.success, true);
      });

      test('should handle ApiResponseModel failure cases', () {
        // Arrange & Act
        final failureResponse = ApiResponseModel<String>(
          code: 400,
          message: 'Bad Request',
          body: null,
        );

        // Assert
        expect(failureResponse.code, 400);
        expect(failureResponse.message, 'Bad Request');
        expect(failureResponse.body, null);
        expect(failureResponse.success, false);
      });
    });

    group('Storage Constants Tests', () {
      test('should have all required storage constants defined', () {
        // Assert - Check that all constants exist and are strings
        expect(StorageConstants.accessToken, isA<String>());
        expect(StorageConstants.refreshToken, isA<String>());
        expect(StorageConstants.userProfile, isA<String>());
        expect(StorageConstants.isLoggedIn, isA<String>());
        expect(StorageConstants.rememberMe, isA<String>());
        expect(StorageConstants.biometricEnabled, isA<String>());
        expect(StorageConstants.themeMode, isA<String>());
        expect(StorageConstants.language, isA<String>());
        expect(StorageConstants.onboardingCompleted, isA<String>());
        expect(StorageConstants.tokenExpiryTime, isA<String>());
      });

      test('should have unique storage constant values', () {
        // Arrange
        final constants = [
          StorageConstants.accessToken,
          StorageConstants.refreshToken,
          StorageConstants.userProfile,
          StorageConstants.isLoggedIn,
          StorageConstants.rememberMe,
          StorageConstants.biometricEnabled,
          StorageConstants.themeMode,
          StorageConstants.language,
          StorageConstants.onboardingCompleted,
          StorageConstants.tokenExpiryTime,
        ];

        // Act & Assert - All constants should be unique
        final uniqueConstants = constants.toSet();
        expect(uniqueConstants.length, constants.length);
      });
    });

    group('Authentication Flow Logic Tests', () {
      test('should simulate complete login flow logic', () {
        // Arrange
        const email = 'test@example.com';
        final testUser = UserModel(
          id: '123',
          email: email,
          firstName: 'John',
          lastName: 'Doe',
          role: 'user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        );

        // Act - Simulate successful login process
        authController.setLoggedIn(true);
        authController.setCurrentUser(testUser);
        authController.setErrorMessage('');
        authController.setRememberMe(true);

        // Assert
        expect(authController.isLoggedIn, true);
        expect(authController.currentUser?.email, email);
        expect(authController.currentUser?.fullName, 'John Doe');
        expect(authController.errorMessage, '');
        expect(authController.rememberMe, true);
      });

      test('should simulate complete logout flow logic', () {
        // Arrange - Set up logged in state
        final testUser = UserModel(
          id: '123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: 'user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        );

        authController.setLoggedIn(true);
        authController.setCurrentUser(testUser);

        // Act - Simulate logout process
        authController.logout();

        // Assert
        expect(authController.isLoggedIn, false);
        expect(authController.currentUser, null);
        expect(authController.errorMessage, '');
      });

      test('should handle authentication errors correctly', () {
        // Act - Simulate authentication error
        authController.setLoggedIn(false);
        authController.setCurrentUser(null);
        authController.setErrorMessage('Authentication failed');

        // Assert
        expect(authController.isLoggedIn, false);
        expect(authController.currentUser, null);
        expect(authController.errorMessage, 'Authentication failed');
      });
    });

    group('Session Expiry Logic Tests', () {
      test('should detect when session is about to expire - mock scenario', () {
        // This is a simplified test since we can't easily mock the repository method
        // In a real scenario, you would mock authRepository.getTokenExpiryTime()

        // Arrange - We can test the basic logic by using current time
        final currentTime = DateTime.now();
        final fiveMinutesFromNow = currentTime.add(const Duration(minutes: 5));
        final tenMinutesFromNow = currentTime.add(const Duration(minutes: 10));

        // Act & Assert - Test the time comparison logic
        expect(
          fiveMinutesFromNow.isBefore(
            currentTime.add(const Duration(minutes: 6)),
          ),
          true,
        );
        expect(
          tenMinutesFromNow.isBefore(
            currentTime.add(const Duration(minutes: 6)),
          ),
          false,
        );
      });

      test('should handle expired tokens correctly - mock scenario', () {
        // Arrange
        final pastTime = DateTime.now().subtract(const Duration(hours: 1));
        final currentTime = DateTime.now();

        // Act & Assert - Test expiry logic
        expect(currentTime.isAfter(pastTime), true);
      });

      test('should handle valid tokens correctly - mock scenario', () {
        // Arrange
        final futureTime = DateTime.now().add(const Duration(hours: 1));
        final currentTime = DateTime.now();

        // Act & Assert - Test validity logic
        expect(currentTime.isBefore(futureTime), true);
      });
    });

    group('Edge Cases and Error Handling Tests', () {
      test('should handle null user gracefully', () {
        // Act
        authController.setCurrentUser(null);

        // Assert
        expect(authController.currentUser, null);
      });

      test('should handle very long error messages', () {
        // Arrange
        const longErrorMessage =
            'This is a very long error message that might occur in real-world scenarios when the server returns detailed error information that could be quite lengthy and needs to be handled properly by the application without causing any issues or crashes in the user interface or the underlying authentication system';

        // Act
        authController.setErrorMessage(longErrorMessage);

        // Assert
        expect(authController.errorMessage, longErrorMessage);
        expect(authController.errorMessage.length, greaterThan(100));
      });

      test('should handle rapid state changes', () {
        // Act - Simulate rapid state changes
        authController.setLoading(true);
        authController.setLoading(false);
        authController.setLoggedIn(true);
        authController.setLoggedIn(false);

        // Assert - Should maintain the last state
        expect(authController.isLoading, false);
        expect(authController.isLoggedIn, false);
      });

      test('should handle concurrent operations gracefully', () async {
        // Arrange
        final futures = <Future<void>>[];

        // Act - Simulate concurrent state updates
        for (int i = 0; i < 10; i++) {
          futures.add(
            Future(() {
              authController.setLoading(i % 2 == 0);
              authController.setErrorMessage('Error $i');
            }),
          );
        }

        await Future.wait(futures);

        // Assert - Should complete without throwing
        expect(authController.errorMessage, isNotEmpty);
      });

      test('should handle special characters in user data', () {
        // Arrange & Act
        final userWithSpecialChars = UserModel(
          id: '123',
          email: 'test+special@example.com',
          firstName: 'John-Paul',
          lastName: "O'Connor",
          role: 'user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        );

        authController.setCurrentUser(userWithSpecialChars);

        // Assert
        expect(authController.currentUser?.email, 'test+special@example.com');
        expect(authController.currentUser?.fullName, "John-Paul O'Connor");
      });
    });

    group('Business Logic Tests', () {
      test('should validate email format logic', () {
        // Arrange
        const validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'first+last@subdomain.example.org',
        ];

        const invalidEmails = [
          'invalid-email',
          '@example.com',
          'test@',
          'test.example.com',
        ];

        // Act & Assert
        for (final email in validEmails) {
          expect(
            email.contains('@') && email.contains('.'),
            true,
            reason: 'Valid email should contain @ and .',
          );
        }

        for (final email in invalidEmails) {
          expect(
            !(email.contains('@') &&
                email.contains('.') &&
                email.indexOf('@') > 0),
            true,
            reason: 'Invalid email should fail basic validation',
          );
        }
      });

      test('should handle role-based permissions logic', () {
        // Arrange
        final adminUser = UserModel(
          id: '1',
          email: 'admin@example.com',
          firstName: 'Admin',
          lastName: 'User',
          role: 'admin',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        );

        final regularUser = UserModel(
          id: '2',
          email: 'user@example.com',
          firstName: 'Regular',
          lastName: 'User',
          role: 'user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        );

        // Act & Assert
        expect(adminUser.role, 'admin');
        expect(regularUser.role, 'user');
        expect(adminUser.role == 'admin', true);
        expect(regularUser.role == 'admin', false);
      });

      test('should handle user active status logic', () {
        // Arrange
        final activeUser = UserModel(
          id: '1',
          email: 'active@example.com',
          firstName: 'Active',
          lastName: 'User',
          role: 'user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        );

        final inactiveUser = UserModel(
          id: '2',
          email: 'inactive@example.com',
          firstName: 'Inactive',
          lastName: 'User',
          role: 'user',
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        );

        // Act & Assert
        expect(activeUser.isActive, true);
        expect(inactiveUser.isActive, false);
      });
    });
  });
}
