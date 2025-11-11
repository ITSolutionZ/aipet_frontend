import '../../../../shared/shared.dart';

import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';


/// 인증 Repository 구현체
///
/// Clean Architecture 원칙에 따라 데이터소스를 통해 인증 관련 작업을 처리
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;

  const AuthRepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<Result<AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // 1. 원격 데이터소스로 로그인 시도
      final remoteResult = await _remoteDatasource.signInWithEmailAndPassword(
        email,
        password,
      );

      if (remoteResult.isSuccess && remoteResult.dataOrNull != null) {
        final user = remoteResult.dataOrNull!;

        // 2. 로컬에 사용자 정보 캐시
        await _localDatasource.saveUserSession(user);

        return Result.success('ログインが完了しました', user);
      }

      // 3. 원격 실패 시 로컬 캐시 확인 (오프라인 모드)
      final localResult = await _localDatasource.getCachedUser(email);
      if (localResult.isSuccess && localResult.dataOrNull != null) {
        return Result.success('オフラインログインが完了しました', localResult.dataOrNull!);
      }

      return Result.failure(remoteResult.message);
    } catch (error) {
      return Result.failure('ログインに失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<AuthUser>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // 원격 데이터소스로 회원가입
      final result = await _remoteDatasource.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (result.isSuccess && result.dataOrNull != null) {
        final user = result.dataOrNull!;

        // 로컬에 사용자 정보 저장
        await _localDatasource.saveUserSession(user);

        return Result.success('会員登録が完了しました', user);
      }

      return Result.failure(result.message);
    } catch (error) {
      return Result.failure('会員登録に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<AuthUser>> signInWithGoogle() async {
    try {
      final result = await _remoteDatasource.signInWithGoogle();

      if (result.isSuccess && result.dataOrNull != null) {
        final user = result.dataOrNull!;
        await _localDatasource.saveUserSession(user);
        return Result.success('Googleログインが完了しました', user);
      }

      return Result.failure(result.message);
    } catch (error) {
      return Result.failure('Googleログインに失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<AuthUser>> signInWithApple() async {
    try {
      final result = await _remoteDatasource.signInWithApple();

      if (result.isSuccess && result.dataOrNull != null) {
        final user = result.dataOrNull!;
        await _localDatasource.saveUserSession(user);
        return Result.success('Appleログインが完了しました', user);
      }

      return Result.failure(result.message);
    } catch (error) {
      return Result.failure('Appleログインに失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<AuthUser>> signInWithLine() async {
    try {
      final result = await _remoteDatasource.signInWithLine();

      if (result.isSuccess && result.dataOrNull != null) {
        final user = result.dataOrNull!;
        await _localDatasource.saveUserSession(user);
        return Result.success('LINEログインが完了しました', user);
      }

      return Result.failure(result.message);
    } catch (error) {
      return Result.failure('LINEログインに失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // 1. 원격 로그아웃
      await _remoteDatasource.signOut();
    } catch (error) {
      // 원격 로그아웃 실패는 무시 (오프라인일 수 있음)
    }

    // 2. 로컬 세션 삭제 (항상 실행)
    await _localDatasource.clearUserSession();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      // 1. 원격에서 최신 사용자 정보 조회
      final remoteResult = await _remoteDatasource.getCurrentUser();
      if (remoteResult.isSuccess && remoteResult.dataOrNull != null) {
        final user = remoteResult.dataOrNull!;

        // 로컬 캐시 업데이트
        await _localDatasource.saveUserSession(user);

        return user;
      }
    } catch (error) {
      // 원격 조회 실패 시 로컬 캐시 사용
    }

    // 2. 로컬 캐시에서 사용자 정보 조회
    try {
      final localResult = await _localDatasource.getCurrentUser();
      return localResult.dataOrNull;
    } catch (error) {
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _remoteDatasource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> sendEmailVerification() async {
    await _remoteDatasource.sendEmailVerification();
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      // 1. 원격 업데이트
      await _remoteDatasource.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // 2. 로컬 캐시 업데이트
      await _localDatasource.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
    } catch (error) {
      throw Exception('プロフィール更新に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      // 1. 원격에서 계정 삭제
      await _remoteDatasource.deleteAccount();
    } catch (error) {
      // 원격 삭제 실패는 무시하고 로컬은 항상 삭제
    }

    // 2. 로컬 데이터 삭제
    await _localDatasource.clearUserSession();
  }

  @override
  Future<String> exchangeServerToken(String idToken) async {
    return _remoteDatasource.exchangeServerToken(idToken);
  }

  @override
  Future<String?> getCurrentUserIdToken({bool forceRefresh = false}) async {
    return _remoteDatasource.getCurrentUserIdToken();
  }

  @override
  Future<String?> getStoredServerToken() async {
    // 로컬에서 저장된 토큰 조회
    return _localDatasource.getStoredToken();
  }

  @override
  Future<void> saveServerToken(String token) async {
    await _localDatasource.saveToken(token);
  }

  @override
  Future<void> clearServerToken() async {
    await _localDatasource.clearToken();
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      // 1. 현재 사용자 존재 여부 확인
      final user = await getCurrentUser();
      if (user == null) return false;

      // 2. 토큰 유효성 확인
      final token = await getStoredServerToken();
      if (token == null) return false;

      // 3. 원격에서 토큰 유효성 검증 (선택적)
      try {
        final isValid = await _remoteDatasource.validateToken(token);
        return isValid;
      } catch (error) {
        // 네트워크 오류 시 로컬 검증만 사용
        return true;
      }
    } catch (error) {
      return false;
    }
  }
}
