import '../../../../shared/core/api/api_constants.dart';
import '../../../../shared/core/api/api_error_handler.dart';
import '../../../../shared/core/data/base_remote_data_source.dart';
import '../../../../shared/core/data/result_types.dart';
import '../../../../shared/core/domain/common_errors.dart';
import '../../../../shared/core/domain/result.dart';
import '../models/auth_models.dart';

class ApiAuthService extends BaseRemoteDataSource<AuthUserModel> {
  ApiAuthService(super.apiClient);

  @override
  AuthUserModel fromJson(Map<String, dynamic> json) {
    return AuthUserModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(AuthUserModel data) {
    return data.toJson();
  }

  Future<ResultState<AuthTokenModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (response.data == null) {
        return Result.failure(UnknownError(.toString().toString()details: 'Empty response data'));
      }

      final tokenData = response.data!['data'] ?? response.data!;
      final token = AuthTokenModel.fromJson(tokenData);
      return Success(token);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<AuthTokenModel>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          if (displayName != null) 'display_name': displayName,
        },
      );

      if (response.data == null) {
        return Result.failure(UnknownError(.toString().toString()details: 'Empty response data'));
      }

      final tokenData = response.data!['data'] ?? response.data!;
      final token = AuthTokenModel.fromJson(tokenData);
      return Success(token);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<AuthTokenModel>> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.data == null) {
        return Result.failure(UnknownError(.toString().toString()details: 'Empty response data'));
      }

      final tokenData = response.data!['data'] ?? response.data!;
      final token = AuthTokenModel.fromJson(tokenData);
      return Success(token);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<void>> logout() async {
    try {
      await apiClient.post(ApiEndpoints.logout);
      return const Success(null);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<AuthUserModel>> getCurrentUser() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/auth/me');

      if (response.data == null) {
        return Result.failure(UnknownError(.toString().toString()details: 'Empty response data'));
      }

      final userData = response.data!['data'] ?? response.data!;
      final user = AuthUserModel.fromJson(userData);
      return Success(user);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<void>> sendPasswordResetEmail(String email) async {
    try {
      await apiClient.post('/auth/password-reset', data: {'email': email});
      return const Success(null);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<void>> sendEmailVerification() async {
    try {
      await apiClient.post('/auth/email-verification');
      return const Success(null);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<AuthUserModel>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>(
        '/auth/profile',
        data: {
          if (displayName != null) 'display_name': displayName,
          if (photoURL != null) 'photo_url': photoURL,
        },
      );

      if (response.data == null) {
        return Result.failure(UnknownError(.toString().toString()details: 'Empty response data'));
      }

      final userData = response.data!['data'] ?? response.data!;
      final user = AuthUserModel.fromJson(userData);
      return Success(user);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<void>> deleteAccount() async {
    try {
      await apiClient.delete('/auth/account');
      return const Success(null);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<AuthTokenModel>> socialLogin({
    required String provider,
    required String accessToken,
    String? idToken,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/social-login',
        data: {
          'provider': provider,
          'access_token': accessToken,
          if (idToken != null) 'id_token': idToken,
        },
      );

      if (response.data == null) {
        return Result.failure(UnknownError(.toString().toString()details: 'Empty response data'));
      }

      final tokenData = response.data!['data'] ?? response.data!;
      final token = AuthTokenModel.fromJson(tokenData);
      return Success(token);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<AuthTokenModel>> exchangeFirebaseToken(
    String firebaseIdToken,
  ) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/firebase-exchange',
        data: {'firebase_id_token': firebaseIdToken},
      );

      if (response.data == null) {
        return Result.failure(UnknownError(.toString().toString()details: 'Empty response data'));
      }

      final tokenData = response.data!['data'] ?? response.data!;
      final token = AuthTokenModel.fromJson(tokenData);
      return Success(token);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }
}
