import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/pet_profile/data/services/backend_pet_api_service.dart';
import '../../../../features/pet_profile/data/services/local_pet_service.dart';
import '../../../../features/pet_profile/pet_profile.dart';
import '../../../../shared/core/services/backend_token_service.dart';
import '../../../../shared/shared.dart';
import '../../data/data.dart';
import '../../data/services/firebase_token_service.dart';
import '../../domain/domain.dart';



/// 인증 작업 결과 타입 (Result 패턴 사용)
///
/// 인증 관련 작업의 성공/실패 결과를 담는 타입입니다.
typedef AuthControllerResult = Result<String>;

/// 인증 유효성 검사 결과 타입 (Result 패턴 사용)
///
/// 폼 입력 데이터의 유효성 검사 결과를 담는 타입입니다.
typedef AuthValidationResult = Result<void>;

/// 인증 컨트롤러
///
/// 인증 관련 비즈니스 로직을 관리하는 컨트롤러입니다.
/// UseCase 패턴을 사용하여 인증 로직을 처리하고,
/// 폼 상태 관리를 담당합니다.
class AuthController extends Notifier<AuthFormState> {
  /// 로그인 UseCase
  late final LoginUseCase _loginUseCase;

  /// 회원가입 UseCase
  late final SignupUseCase _signupUseCase;

  /// 로그아웃 UseCase
  late final LogoutUseCase _logoutUseCase;

  /// 현재 사용자 정보 조회 UseCase
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  /// 소셜 로그인 UseCase
  late final SocialLoginUseCase _socialLoginUseCase;

  @override
  AuthFormState build() {
    final repository = ref.read(authRepositoryProvider);
    _loginUseCase = LoginUseCase(repository);
    _signupUseCase = SignupUseCase(repository);
    _logoutUseCase = LogoutUseCase(repository);
    _getCurrentUserUseCase = GetCurrentUserUseCase(repository);
    _socialLoginUseCase = SocialLoginUseCase(repository);

    return const AuthFormState();
  }

  AuthFormState get currentState => ref.read(authFormStateNotifierProvider);

  AuthFormState get formData => currentState;

  bool get isFormValid {
    final state = currentState;
    return state.email.isNotEmpty &&
        state.username.isNotEmpty &&
        state.error == null;
  }

  bool get canSubmit => isFormValid && !currentState.isLoading;

  void initializeForm() {
    // 폼 초기화 로직
    ref.read(authFormStateNotifierProvider.notifier).resetState();
  }

  void updateEmail(String email) {
    ref.read(authFormStateNotifierProvider.notifier).updateEmail(email);
  }

  void updateUsername(String username) {
    ref.read(authFormStateNotifierProvider.notifier).updateUsername(username);
  }

  void togglePasswordVisibility() {
    ref.read(authFormStateNotifierProvider.notifier).togglePasswordVisibility();
  }

  void toggleConfirmPasswordVisibility() {
    ref
        .read(authFormStateNotifierProvider.notifier)
        .toggleConfirmPasswordVisibility();
  }

  void toggleRememberMe() {
    ref.read(authFormStateNotifierProvider.notifier).toggleRememberMe();
  }

  /// 실제 로그인 성공 처리
  ///
  /// 인증 성공 시 호출되어 폼 상태를 업데이트합니다.
  /// 로딩 상태를 해제하고 에러를 초기화합니다.
  void handleLoginSuccess() {
    LoggerService.debug('✅ AuthController: 로그인 성공 처리');

    // 폼 상태 업데이트
    ref.read(authFormStateNotifierProvider.notifier).handleLoginSuccess();
  }

  /// 로그인 성공 시 펫 데이터 로드
  ///
  /// [userId] 로그인한 사용자 ID
  /// [return] 로드된 펫 데이터
  Future<List<PetProfileEntity>> loadUserPetsOnLogin(String userId) async {
    try {
      // 🚨 PRINT로 확실하게 출력
      print('');
      print('🚨🚨🚨 ========================================');
      print('🚨 로그인 성공! 토큰 디버그 시작!');
      print('🚨🚨🚨 ========================================');

      LoggerService.debug(
        '🐾 AuthController: 로그인 성공 시 펫 데이터 로드 시작 - 사용자: $userId',
      );

      // 🧪 Firebase 토큰 직접 가져오기
      try {
        print('📞 FirebaseAuth.instance.currentUser 확인 중...');
        final user = FirebaseAuth.instance.currentUser;
        print('👤 현재 유저: ${user?.email ?? "null"}');

        if (user != null) {
          print('🔑 토큰 가져오는 중...');
          final token = await user.getIdToken();
          print('');
          print('🎯🎯🎯 ========== FIREBASE TOKEN ==========');
          print('📧 이메일: ${user.email}');
          print('🆔 UID: ${user.uid}');
          print('📏 토큰 길이: ${token?.length ?? 0} 문자');
          print('');
          print('🔑 전체 토큰:');
          print(token ?? 'null');
          print('');
          print('========================================');
          print('');
        } else {
          print('❌ FirebaseAuth.instance.currentUser가 null입니다!');
        }
      } catch (e) {
        print('❌ 토큰 가져오기 에러: $e');
      }

      print('🚨 토큰 디버그 완료!');
      print('');

      // 펫 프로필 프로바이더를 통해 사용자 펫 데이터 로드
      final petsAsync = ref.read(petProfilesProvider);
      final pets = petsAsync.maybeWhen(
        data: (data) => data,
        orElse: () => <PetProfileEntity>[],
      );

      LoggerService.debug('🐾 로그인 성공 - 펫 ${pets.length}마리 로드됨');

      return pets;
    } catch (error, stackTrace) {
      LoggerService.debug('❌ AuthController: 펫 데이터 로드 실패: $error');
      LoggerService.debug('Stack trace: $stackTrace');
      return [];
    }
  }

  /// 로그인 처리 (UseCase 패턴 사용)
  Future<AuthControllerResult> login({String? password}) async {
    try {
      // 유효성 검사
      final validationResult = validateLoginData();
      if (!validationResult.isSuccess) {
        return Result.failure(validationResult.message);
      }

      // 비밀번호가 제공되지 않은 경우 기본 처리
      if (password == null || password.isEmpty) {
        return Result.failure('パスワードを入力してください');
      }

      // UseCase를 통한 로그인 실행
      final result = await _loginUseCase.call(
        email: currentState.email,
        password: password,
      );

      if (result.isSuccess) {
        // 로그인 성공 시 펫 데이터 로드
        final userId = currentState.email; // 임시로 이메일을 사용자 ID로 사용
        final pets = await loadUserPetsOnLogin(userId);

        LoggerService.debug(
          '✅ AuthController: 로그인 성공 - 펫 ${pets.length}마리 로드됨',
        );

        return Result.success('ログインが完了しました', '');
      } else {
        return Result.failure(result.error?.toString() ?? 'ログインに失敗しました');
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 회원가입 처리 (UseCase 패턴 사용)
  Future<AuthControllerResult> signup({
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // 유효성 검사
      final validationResult = validateSignupData();
      if (!validationResult.isSuccess) {
        return Result.failure(validationResult.message);
      }

      // UseCase를 통한 회원가입 실행
      final result = await _signupUseCase.call(
        email: currentState.email,
        password: password,
        confirmPassword: confirmPassword,
        displayName: currentState.username,
      );

      if (result.isSuccess) {
        return Result.success('회원가입이 완료되었습니다', '');
      } else {
        return Result.failure('회원가입에 실패했습니다');
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// Google 로그인 처리
  Future<AuthControllerResult> loginWithGoogle() async {
    try {
      // 1. Google 로그인 실행
      final result = await _socialLoginUseCase.loginWithGoogle();

      if (result.isSuccess) {
        // 2. 백엔드에 Firebase ID Token 전송
        try {
          final backendAuthSuccess =
              await BackendTokenService.authenticateWithBackend();
          if (backendAuthSuccess) {
            LoggerService.debug('✅ 백엔드 인증 완료');

            // 3. 로컬 펫 데이터를 백엔드로 마이그레이션
            await _migrateLocalPetsToBackend();
          } else {
            LoggerService.debug('⚠️ 백엔드 인증 실패 (앱은 계속 사용 가능)');
          }
        } catch (e) {
          LoggerService.debug('⚠️ 백엔드 인증 중 에러: $e');
          // 백엔드 인증 실패해도 Firebase 로그인은 성공으로 처리
        }

        return Result.success('Googleログインが完了しました', '');
      } else {
        return Result.failure('Googleログインに失敗しました');
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// Apple 로그인 처리
  Future<AuthControllerResult> loginWithApple() async {
    try {
      // 1. Apple 로그인 실행
      final result = await _socialLoginUseCase.loginWithApple();

      if (result.isSuccess) {
        // 2. 백엔드에 Firebase ID Token 전송
        try {
          final backendAuthSuccess =
              await BackendTokenService.authenticateWithBackend();
          if (backendAuthSuccess) {
            LoggerService.debug('✅ 백엔드 인증 완료');
          } else {
            LoggerService.debug('⚠️ 백엔드 인증 실패 (앱은 계속 사용 가능)');
          }
        } catch (e) {
          LoggerService.debug('⚠️ 백엔드 인증 중 에러: $e');
          // 백엔드 인증 실패해도 Firebase 로그인은 성공으로 처리
        }

        return Result.success('Appleログインが完了しました', '');
      } else {
        return Result.failure('Appleログインに失敗しました');
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// LINE 로그인 처리
  Future<AuthControllerResult> loginWithLine() async {
    try {
      // 1. LINE 로그인 실행
      final result = await _socialLoginUseCase.loginWithLine();

      if (result.isSuccess) {
        // 2. 백엔드에 Firebase ID Token 전송
        try {
          final backendAuthSuccess =
              await BackendTokenService.authenticateWithBackend();
          if (backendAuthSuccess) {
            LoggerService.debug('✅ 백엔드 인증 완료');
          } else {
            LoggerService.debug('⚠️ 백엔드 인증 실패 (앱은 계속 사용 가능)');
          }
        } catch (e) {
          LoggerService.debug('⚠️ 백엔드 인증 중 에러: $e');
          // 백엔드 인증 실패해도 Firebase 로그인은 성공으로 처리
        }

        return Result.success('LINEログインが完了しました', '');
      } else {
        return Result.failure('LINEログインに失敗しました');
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 저장된 로그인 정보 불러오기
  Future<void> loadSavedCredentials() async {
    try {
      await ref
          .read(authFormStateNotifierProvider.notifier)
          .loadSavedCredentials();
    } catch (error) {
      handleError(error, StackTrace.current);
    }
  }

  /// 저장된 로그인 정보 삭제
  Future<bool> clearSavedCredentials() async {
    try {
      await ref
          .read(authFormStateNotifierProvider.notifier)
          .clearSavedCredentials();
      return true;
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return false;
    }
  }

  /// 로그아웃 처리 (UseCase 패턴 사용)
  Future<AuthControllerResult> logout() async {
    try {
      // UseCase를 통한 로그아웃 실행
      final result = await _logoutUseCase.call();

      if (result.isSuccess) {
        // 저장된 로그인 정보 삭제
        await clearSavedCredentials();

        // 인증 상태 초기화
        ref.read(authFormStateNotifierProvider.notifier).resetState();

        return Result.success('ログアウトが完了しました', '');
      } else {
        return Result.failure('ログアウトに失敗しました');
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 로그인 데이터 유효성 검사 (UI 로직 분리)
  AuthValidationResult validateLoginData() {
    final state = currentState;

    // 이메일 검증 (공통 ValidationUtils 사용)
    if (!ValidationUtils.isValidEmail(state.email)) {
      return Result.failure('無効なメールアドレスです');
    }

    // 비밀번호 검증은 UI에서 직접 처리 (AuthFormState에는 패스워드 없음)
    // 실제 검증은 TextFormField의 validator에서 수행

    return Result.success('유효성 검사가 완료되었습니다');
  }

  /// 회원가입 데이터 유효성 검사 (UI 로직 분리)
  AuthValidationResult validateSignupData() {
    final state = currentState;

    // 이메일 검증 (공통 ValidationUtils 사용)
    if (!ValidationUtils.isValidEmail(state.email)) {
      return Result.failure('無効なメールアドレスです');
    }

    // 사용자명 검증 (공통 ValidationUtils 사용)
    if (!ValidationUtils.isValidUsername(state.username)) {
      return Result.failure('無効なユーザー名です');
    }

    // 비밀번호 검증은 UI에서 직접 처리 (AuthFormState에는 패스워드 없음)
    // 실제 검증은 TextFormField의 validator에서 수행

    return Result.success('유효성 검사가 완료되었습니다');
  }

  /// 에러 메시지 초기화
  void clearError() {
    ref.read(authFormStateNotifierProvider.notifier).clearError();
  }

  void resetForm() {
    ref.read(authFormStateNotifierProvider.notifier).resetState();
  }

  /// 현재 사용자 정보 가져오기
  Future<Result<AuthUser?>> getCurrentUser() async {
    try {
      final result = await _getCurrentUserUseCase.call();
      if (result.isSuccess) {
        return Result.success('사용자 정보를 가져왔습니다', result.dataOrNull);
      } else {
        return Result.failure(
          result.error?.toString() ?? '사용자 정보를 가져오는데 실패했습니다',
        );
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 로그인 상태 확인
  Future<Result<bool>> isLoggedIn() async {
    try {
      final result = await _getCurrentUserUseCase.isLoggedIn();
      if (result.isSuccess) {
        return Result.success('로그인 상태를 확인했습니다', result.dataOrNull ?? false);
      } else {
        return Result.failure(result.error?.toString() ?? '로그인 상태 확인에 실패했습니다');
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 이메일 인증 상태 확인
  Future<Result<bool>> isEmailVerified() async {
    try {
      final result = await _getCurrentUserUseCase.isEmailVerified();
      if (result.isSuccess) {
        return Result.success('이메일 인증 상태를 확인했습니다', result.dataOrNull ?? false);
      } else {
        return Result.failure(
          result.error?.toString() ?? '이메일 인증 상태 확인에 실패했습니다',
        );
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure(getUserFriendlyErrorMessage(error));
    }
  }

  Future<Result<void>> submitForm() async {
    // 로그인 폼 제출 (기본 동작) - 패스워드는 별도로 제공되어야 함
    return Result.failure('submitFormではなく、login()メソッドを直接使用してください');
  }

  /// 에러 처리 메서드
  void handleError(Object error, StackTrace stackTrace) {
    LoggerService.debug('❌ AuthController Error: $error');
    LoggerService.debug('StackTrace: $stackTrace');
  }

  /// 사용자 친화적 에러 메시지 변환
  String getUserFriendlyErrorMessage(Object error) {
    if (error.toString().contains('network')) {
      return 'ネットワークエラーが発生しました';
    } else if (error.toString().contains('timeout')) {
      return 'タイムアウトが発生しました';
    } else {
      return 'エラーが発生しました';
    }
  }

  /// 로컬 펫 데이터를 백엔드로 마이그레이션
  Future<void> _migrateLocalPetsToBackend() async {
    try {
      LoggerService.debug('🔄 로컬 펫 데이터 마이그레이션 시작');

      // 1. 로컬 스토리지에서 펫 데이터 가져오기
      final localPetService = LocalPetService();
      final localPets = await localPetService.getAllPets();

      if (localPets.isEmpty) {
        LoggerService.debug('📭 마이그레이션할 로컬 펫이 없음');
        return;
      }

      LoggerService.debug('📦 마이그레이션할 펫: ${localPets.length}개');

      // 2. 각 펫을 백엔드로 전송
      int successCount = 0;
      int failCount = 0;

      for (final localPet in localPets) {
        try {
          // PetProfileEntity로 변환
          final petEntity = _convertLocalPetToEntity(localPet);

          // 백엔드로 전송 (static 메서드)
          final result = await BackendPetApiService.createPet(petEntity);

          if (result.isSuccess) {
            successCount++;
            LoggerService.debug('✅ 펫 업로드 성공: ${petEntity.name}');
          } else {
            failCount++;
            LoggerService.debug('❌ 펫 업로드 실패: ${petEntity.name} - ${result.error}');
          }
        } catch (e) {
          failCount++;
          LoggerService.debug('❌ 펫 업로드 실패: ${localPet['name']} - $e');
        }
      }

      LoggerService.debug(
        '🎉 마이그레이션 완료: 성공 $successCount개, 실패 $failCount개',
      );

      // 4. 성공한 경우 알림 (선택사항)
      if (successCount > 0) {
        LoggerService.debug('✅ $successCount匹のペットを同期しました');
      }
    } catch (e) {
      LoggerService.debug('⚠️ 펫 마이그레이션 중 에러: $e');
      // 에러가 나도 로그인은 계속 진행
    }
  }

  /// 로컬 펫 데이터를 PetProfileEntity로 변환
  PetProfileEntity _convertLocalPetToEntity(Map<String, dynamic> localPet) {
    // additionalInfo JSON 파싱
    final additionalInfoStr = localPet['additionalInfo'] as String?;
    Map<String, dynamic> additionalInfo = {};

    if (additionalInfoStr != null && additionalInfoStr.isNotEmpty) {
      try {
        additionalInfo = jsonDecode(additionalInfoStr) as Map<String, dynamic>;
      } catch (e) {
        LoggerService.debug('⚠️ additionalInfo 파싱 실패: $e');
      }
    }

    // Firebase 현재 사용자 UID 가져오기
    final firebaseAuth = FirebaseAuth.instance;
    final ownerId = firebaseAuth.currentUser?.uid ?? '';

    return PetProfileEntity(
      id: '', // 백엔드에서 새로 생성
      name: localPet['name'] as String? ?? '',
      type: localPet['species'] as String? ?? 'dog', // species → type
      breed: localPet['breed'] as String?,
      gender: localPet['gender'] as String? ?? 'male',
      birthDate: DateTime.tryParse(localPet['birthDate'] as String? ?? '') ??
          DateTime.now(),
      weight: (localPet['weight'] as num?)?.toDouble() ?? 0.0,
      imagePath: localPet['imagePath'] as String?,
      microchipNumber: localPet['microchipId'] as String?,
      neutered: additionalInfo['isNeutered'] as bool?,
      arrivalDate:
          DateTime.tryParse(additionalInfo['adoptionDate'] as String? ?? ''),
      ownerId: ownerId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      additionalInfo: additionalInfo,
    );
  }
}

/// AuthController Provider
final authControllerProvider = NotifierProvider<AuthController, AuthFormState>(
  AuthController.new,
);
