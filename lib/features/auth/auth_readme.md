# Auth Feature - Clean Architecture

This document describes the refactored Auth feature following Clean Architecture principles.

## 🏗️ Architecture Overview

The Auth feature has been completely refactored to follow Clean Architecture with clear separation of concerns:

```
auth/
├── domain/                 # Business Logic Layer
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business use cases
├── data/                  # Data Access Layer
│   ├── datasources/       # Data source interfaces & implementations
│   └── repositories/      # Repository implementations
└── presentation/          # UI Layer
    ├── controllers/       # State management
    ├── providers/         # Dependency injection
    ├── screens/           # UI screens
    ├── widgets/           # Reusable UI components
    └── state/             # UI state models
```

## 📋 Domain Layer

### Entities (`domain/entities/auth_entities.dart`)

Core business entities:
- `AuthUser` - User authentication data
- `AuthToken` - JWT token information
- `AuthSession` - User session data
- `SocialProvider` - Social login providers
- `AuthenticationStatus` - Authentication state enum

### Use Cases

#### `AuthenticateUseCase` (`domain/usecases/authenticate_usecase.dart`)
Handles all authentication operations:
- Email/password login with validation
- Social login (Google, Apple, LINE)
- User registration with strong password validation
- Profile updates
- Password reset
- Email verification

#### `SessionManagementUseCase` (`domain/usecases/session_management_usecase.dart`)
Manages sessions and tokens:
- Session status checking
- Token refresh and validation
- Session expiration handling
- Auto-login management
- Multi-device session management

### Repository Interface (`domain/repositories/auth_repository.dart`)
Defines the contract for authentication operations.

## 💾 Data Layer

### Datasources (`data/datasources/`)

#### `AuthDatasource` Interface
Base interface for all auth data sources.

#### `AuthRemoteDatasource` Interface
Interface for remote authentication operations:
- Firebase authentication
- Social login integration
- Server token exchange

#### `AuthLocalDatasource` Interface
Interface for local authentication operations:
- Token storage
- User session caching
- Auto-login settings

#### Mock Implementations (`auth_mock_datasource.dart`)
- `AuthMockRemoteDatasource` - Mock remote operations for development
- `AuthMockLocalDatasource` - Mock local operations for testing

### Repository Implementation (`data/repositories/auth_repository_impl.dart`)
Clean implementation that coordinates between remote and local datasources:
- Offline-first approach
- Automatic fallback to local cache
- Proper error handling

## 🎨 Presentation Layer

### Controllers

#### `CleanAuthController` (`controllers/auth_controller_new.dart`)
Clean architecture controller using the new use cases:
- Reactive state management with Riverpod
- Comprehensive error handling
- Business logic delegation to use cases

#### Legacy `AuthController` (`controllers/auth_controller.dart`)
**⚠️ Deprecated** - Old controller to be phased out

### Providers (`providers/auth_providers.dart`)
Comprehensive dependency injection setup:
- Datasource providers
- Repository provider
- Use case providers
- Controller providers
- Computed state providers

### State Management

#### `AuthState` (in `auth_controller_new.dart`)
Clean state model for authentication:
- User information
- Loading states
- Error messages
- Authentication status

#### `AuthFormState` (`state/auth_form_state.dart`)
UI form state management for login/signup forms.

## 🚀 Usage Examples

### Basic Authentication

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(cleanAuthControllerProvider);
    final authController = ref.read(cleanAuthControllerProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          // Login form widgets
          ElevatedButton(
            onPressed: () async {
              final result = await authController.loginWithEmailPassword(
                email: email,
                password: password,
              );

              if (result.isSuccess) {
                // Navigate to home
              }
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

### Social Login

```dart
// Google login
final result = await authController.loginWithSocial(
  provider: SocialProvider.google,
);

// Apple login
final result = await authController.loginWithSocial(
  provider: SocialProvider.apple,
);
```

### Session Management

```dart
class AppStartup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(cleanAuthControllerProvider).when(
      loading: () => SplashScreen(),
      data: (authState) {
        if (authState.status == AuthenticationStatus.authenticated) {
          return HomeScreen();
        }
        return LoginScreen();
      },
      error: (error, stack) => ErrorScreen(),
    );
  }
}
```

## 🔄 Migration Guide

### From Old Controller to New Controller

1. **Replace provider imports:**
   ```dart
   // Old
   final authController = ref.read(authControllerProvider);

   // New
   final authController = ref.read(cleanAuthControllerProvider.notifier);
   ```

2. **Update method calls:**
   ```dart
   // Old
   await authController.login(password: password);

   // New
   await authController.loginWithEmailPassword(
     email: email,
     password: password,
   );
   ```

3. **Use computed providers:**
   ```dart
   // Current user
   final user = ref.watch(currentUserProvider);

   // Authentication status
   final isAuthenticated = ref.watch(isAuthenticatedProvider);

   // Loading state
   final isLoading = ref.watch(authLoadingProvider);
   ```

## 🧪 Testing Strategy

### Mock Datasources
Use the provided mock implementations for testing:
```dart
// Override providers in tests
container.read(authRemoteDatasourceProvider.overrideWithValue(
  MockAuthRemoteDatasource(),
));
```

### Unit Tests
Test each layer independently:
- **Use Cases**: Test business logic without dependencies
- **Repository**: Test data coordination logic
- **Controller**: Test state management

### Integration Tests
Test complete authentication flows using the mock datasources.

## 🔧 Configuration

### Development Mode
The auth system uses mock datasources by default for development:
- No external dependencies required
- Predictable test data
- Offline development support

### Production Mode
To switch to production:
1. Replace mock datasources with real implementations
2. Configure Firebase authentication
3. Set up proper error handling and logging

## 📚 Dependencies

### Required Packages
- `flutter_riverpod` - State management
- `firebase_auth` - Authentication backend
- `shared_preferences` - Local storage
- `flutter_secure_storage` - Secure token storage

### Architecture Principles Applied
- **Dependency Inversion**: Use interfaces for all dependencies
- **Single Responsibility**: Each class has one clear purpose
- **Open/Closed**: Easy to extend without modifying existing code
- **Interface Segregation**: Focused, cohesive interfaces
- **Don't Repeat Yourself**: Common functionality extracted

## 🚀 Future Enhancements

1. **Biometric Authentication**: Add fingerprint/face ID support
2. **Multi-Factor Authentication**: SMS/email verification
3. **Device Management**: Track and manage user devices
4. **Advanced Session Management**: Concurrent session limits
5. **OAuth 2.0**: Support for additional social providers

---

This refactored Auth feature provides a solid foundation for authentication with clear separation of concerns, comprehensive testing support, and easy extensibility.