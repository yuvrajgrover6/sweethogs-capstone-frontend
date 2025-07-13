import 'package:flutter_test/flutter_test.dart';
import 'package:sweethogs_capstone_frontend/app/models/user_model.dart';
import 'package:sweethogs_capstone_frontend/app/models/login_response_model.dart';
import 'package:sweethogs_capstone_frontend/app/models/api_response_model.dart';
import 'package:sweethogs_capstone_frontend/app/constants/storage_constants.dart';

void main() {
  group('Authentication Unit Tests', () {
    setUpAll(() async {
      // Initialize Flutter test binding
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    group('Data Model Tests', () {
      test('should create UserModel with correct data', () {
        // Arrange & Act
        final user = UserModel(
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

        // Assert
        expect(user.id, '123');
        expect(user.email, 'test@example.com');
        expect(user.fullName, 'John Doe');
        expect(user.role, 'user');
        expect(user.isActive, true);
      });

      test('should handle empty names correctly', () {
        // Arrange & Act
        final user = UserModel(
          id: '123',
          email: 'test@example.com',
          firstName: '',
          lastName: '',
          role: 'user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        );

        // Assert
        expect(user.fullName, 'User');
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
        expect(response.success, true);
        expect(response.body, testData);
      });
    });

    group('Storage Constants Tests', () {
      test('should have all required storage constants defined', () {
        // Assert
        expect(StorageConstants.accessToken, isNotEmpty);
        expect(StorageConstants.refreshToken, isNotEmpty);
        expect(StorageConstants.userProfile, isNotEmpty);
        expect(StorageConstants.isLoggedIn, isNotEmpty);
        expect(StorageConstants.rememberMe, isNotEmpty);
        expect(StorageConstants.biometricEnabled, isNotEmpty);
        expect(StorageConstants.tokenExpiryTime, isNotEmpty);
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
    });
  });
}
