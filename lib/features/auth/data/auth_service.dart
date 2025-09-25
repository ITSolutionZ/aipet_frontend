import 'package:aipet_frontend/features/auth/domain/auth_token.dart';
import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:aipet_frontend/shared/shared.dart';

import 'repositories/firebase_auth_real_impl.dart';
import 'services/token_storage_service.dart';

/// 인증 관련 비즈니스 로직을 담당하는 서비스
/// Repository와 Storage를 조합하여 실제 인증 플로우 관리
class AuthService {
  final AuthRepository _repository;

  AuthService({AuthRepository? repository})
    : _repository = repository ?? FirebaseAuthRealImpl();

  /// 이메일/비밀번호 로그인
  Future<Result<AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _repository.signInWithEmailAndPassword(
        email,
        password,
      );

      if (result.isSuccess && result.dataOrNull != null) {
        // 백엔드 토큰 저장
        await _saveBackendTokenFromUser(result.dataOrNull!);
        return ResultFactory.success(result.dataOrNull!, 'ログインが完了しました');
      } else {
        return ResultFactory.failure('ログインに失敗しました: ${result.errorOrNull}');
      }
    } catch (error) {
      return ResultFactory.failure('ログインに失敗しました: ${error.toString()}');
    }
  }

  /// 회원가입
  Future<Result<AuthUser>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _repository.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (result.isSuccess && result.dataOrNull != null) {
        // 백엔드 토큰 저장
        await _saveBackendTokenFromUser(result.dataOrNull!);
        return ResultFactory.success(result.dataOrNull!, '会員登録が完了しました');
      } else {
        return ResultFactory.failure('会員登録に失敗しました: ${result.errorOrNull}');
      }
    } catch (error) {
      return ResultFactory.failure('会員登録に失敗しました: ${error.toString()}');
    }
  }

  /// 소셜 로그인
  Future<Result<AuthUser>> signInWithProvider(String provider) async {
    try {
      Result<AuthUser> result;

      switch (provider.toLowerCase()) {
        case 'google':
          result = await _repository.signInWithGoogle();
          break;
        case 'apple':
          result = await _repository.signInWithApple();
          break;
        case 'line':
          result = await _repository.signInWithLine();
          break;
        default:
          return ResultFactory.failure('サポートされていないプロバイダーです');
      }

      if (result.isSuccess && result.dataOrNull != null) {
        // 백엔드 토큰 저장
        await _saveBackendTokenFromUser(result.dataOrNull!);
        return ResultFactory.success(
          result.dataOrNull!,
          '$provider ログインが完了しました',
        );
      } else {
        return ResultFactory.failure(
          '$provider ログインに失敗しました: ${result.errorOrNull}',
        );
      }
    } catch (error) {
      return ResultFactory.failure(
        '$provider ログインに失敗しました: ${error.toString()}',
      );
    }
  }

  /// 로그아웃
  Future<Result<void>> signOut() async {
    try {
      await _repository.signOut();
      await TokenStorageService.clearToken();
      await TokenStorageService.clearRememberMe();
      return ResultFactory.success(null, 'ログアウトが完了しました');
    } catch (error) {
      return ResultFactory.failure('ログアウトに失敗しました: ${error.toString()}');
    }
  }

  /// 현재 인증 상태 확인
  Future<bool> isAuthenticated() async {
    try {
      return await TokenStorageService.isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  /// 현재 사용자 정보 가져오기
  Future<Result<AuthUser?>> getCurrentUser() async {
    try {
      final user = await _repository.getCurrentUser();
      return ResultFactory.success(user, 'ユーザー情報を取得しました');
    } catch (error) {
      return ResultFactory.failure('ユーザー情報の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 비밀번호 재설정 이메일 발송
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
      return ResultFactory.success(null, 'パスワードリセットメールを送信しました');
    } catch (error) {
      return ResultFactory.failure(
        'パスワードリセットメールの送信に失敗しました: ${error.toString()}',
      );
    }
  }

  /// 백엔드에서 받은 토큰을 저장합니다
  Future<void> _saveBackendTokenFromUser(AuthUser user) async {
    final customData = user.customData;
    if (customData != null) {
      // AuthToken 객체 생성
      final token = AuthToken(
        accessToken: customData['accessToken'] as String,
        refreshToken: customData['refreshToken'] as String,
        expiresAt: DateTime.parse(customData['expiresAt'] as String),
      );

      // TokenStorage에 저장
      await TokenStorageService.saveToken(token);
    }
  }

  // 향후 실제 API 연동시 사용할 토큰 저장 메서드
  // Future<void> _saveTokenFromResult(AuthResult result) async {
  //   // 실제 API response에서 토큰 정보 추출하여 저장
  //   final token = AuthToken(
  //     accessToken: result.accessToken,
  //     refreshToken: result.refreshToken,
  //     expiresAt: result.expiresAt,
  //   );
  //   await TokenStorageService.saveToken(token);
  // }
}
