# SweetHogs Capstone Frontend

A Flutter application with clean MVC architecture using GetX for state management and comprehensive authentication with JWT and refresh token support.

## Features

- **Clean MVC Architecture**: Organized code structure with clear separation of concerns
- **GetX State Management**: Reactive state management with GetX
- **JWT Authentication**: Complete authentication flow with JWT and refresh tokens
- **Local & Remote Data Sources**: Separated data handling for offline and online operations
- **Automatic Token Refresh**: Seamless token refresh handling
- **Comprehensive Auth Flow**: Login, register, forgot password, change password, email verification
- **Responsive UI**: Modern Material Design UI components
- **Error Handling**: Comprehensive error handling and user feedback

## Project Structure

```
lib/
├── app/
│   ├── constants/
│   │   ├── api_constants.dart          # API endpoints and configuration
│   │   └── storage_constants.dart      # Storage keys and constants
│   ├── controllers/
│   │   └── auth_controller.dart        # Authentication controller (GetX)
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   └── auth_local_datasource.dart   # Local storage operations
│   │   │   └── remote/
│   │   │       └── auth_remote_datasource.dart  # API calls
│   │   └── repositories/
│   │       └── auth_repository.dart     # Data repository layer
│   ├── models/
│   │   ├── auth_model.dart             # Authentication model
│   │   ├── user_model.dart             # User model
│   │   └── api_response_model.dart     # API response models
│   ├── routes/
│   │   └── app_routes.dart             # Route definitions
│   ├── services/
│   │   └── api_service.dart            # HTTP service with interceptors
│   ├── views/
│   │   ├── auth/
│   │   │   └── login_view.dart         # Login screen
│   │   └── home/
│   │       └── home_view.dart          # Home screen
│   └── utils/                          # Utility functions
└── main.dart                           # App entry point
```

## Architecture Overview

### MVC Pattern
- **Model**: Data models with JSON serialization
- **View**: UI components and screens
- **Controller**: Business logic and state management using GetX

### Data Layer
- **Remote Data Source**: Handles API calls using Dio
- **Local Data Source**: Manages local storage using GetStorage
- **Repository**: Combines local and remote data sources

### Authentication Flow
1. User enters credentials
2. AuthController processes login request
3. AuthRepository coordinates between local and remote data sources
4. API service handles HTTP requests with automatic token refresh
5. Tokens are stored locally for persistence
6. User state is managed reactively with GetX

## Key Components

### ApiService
- Singleton HTTP service using Dio
- Automatic JWT token attachment
- Token refresh interceptor
- Error handling and retry logic

### AuthController
- Reactive state management with GetX
- Complete authentication methods
- User session management
- Error handling and user feedback

### AuthRepository
- Combines local and remote data sources
- Handles token persistence
- Manages user profile caching
- Provides unified data access interface

## Configuration

### API Configuration
Update `lib/app/constants/api_constants.dart` with your API endpoints:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

### Storage Configuration
Local storage keys are defined in `lib/app/constants/storage_constants.dart`

## Usage

### Authentication Methods

```dart
// Login
final authController = Get.find<AuthController>();
await authController.login(
  email: 'user@example.com',
  password: 'password123',
  rememberMe: true,
);

// Register
await authController.register(
  email: 'user@example.com',
  password: 'password123',
  firstName: 'John',
  lastName: 'Doe',
);

// Logout
await authController.logout();

// Check authentication status
bool isLoggedIn = authController.isLoggedIn;
UserModel? user = authController.currentUser;
```

### Token Management
- Access tokens are automatically attached to requests
- Refresh tokens are used for automatic token renewal
- Token expiry is handled seamlessly
- Users are redirected to login when tokens expire

## Dependencies

- **get**: State management and dependency injection
- **dio**: HTTP client for API calls
- **get_storage**: Local storage solution
- **json_annotation**: JSON serialization annotations
- **build_runner**: Code generation for JSON serialization

## Getting Started

1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Generate JSON serialization code: `dart run build_runner build`
4. Update API endpoints in `api_constants.dart`
5. Run the app: `flutter run`

## Build Commands

```bash
# Get dependencies
flutter pub get

# Generate code
dart run build_runner build

# Run the app
flutter run

# Build for web
flutter build web

# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

## API Integration

The app expects the following API endpoints:

- `POST /auth/login` - User authentication
- `POST /auth/register` - User registration
- `POST /auth/refresh` - Token refresh
- `POST /auth/logout` - User logout
- `GET /user/profile` - Get user profile
- `PUT /user/update` - Update user profile
- `POST /auth/forgot-password` - Forgot password
- `POST /auth/reset-password` - Reset password

## Error Handling

- Network errors are handled gracefully
- User-friendly error messages
- Automatic retry for failed requests
- Offline capability with local data caching

## Security Features

- JWT token-based authentication
- Automatic token refresh
- Secure local storage
- Request/response interceptors for security headers
- Session management with automatic logout

## Contributing

1. Follow the established architecture patterns
2. Use GetX for state management
3. Implement proper error handling
4. Add comprehensive documentation
5. Test thoroughly before submitting

## License

This project is licensed under the MIT License.
