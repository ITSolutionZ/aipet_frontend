import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 회원가입 UseCase
class SignupUseCase {
  final AuthRepository _repository;

  const SignupUseCase(this._repository);

  /// 이메일/비밀번호로 회원가입
  Future<Result<AuthUser>> call({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    try {
      // 입력 유효성 검사
      final validationResult = _validateSignupInput(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (!validationResult.isSuccess) {
        return ResultFactory.failure(validationResult.errorOrNull ?? '入力が無効です');
      }

      // Repository를 통한 회원가입 실행
      final authResult = await _repository.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (authResult.isSuccess && authResult.dataOrNull != null) {
        // 디스플레이 네임이 제공된 경우 프로필 업데이트
        if (displayName != null && displayName.isNotEmpty) {
          await _repository.updateUserProfile(displayName: displayName);
        }

        // 이메일 인증 메일 발송
        await _repository.sendEmailVerification();

        return ResultFactory.success(
          authResult.dataOrNull!,
          '会員登録が完了しました。確認メールを送信しました。',
        );
      } else {
        return ResultFactory.failure(authResult.errorOrNull ?? '会員登録に失敗しました');
      }
    } catch (error) {
      return ResultFactory.failure('会員登録に失敗しました: ${error.toString()}');
    }
  }

  /// 회원가입 입력 유효성 검사
  Result<void> _validateSignupInput({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    // 필수 입력 검사
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return ResultFactory.failure('全ての項目を入力してください');
    }

    // 이메일 형식 검사
    if (!_isValidEmail(email)) {
      return ResultFactory.failure('有効なメールアドレスを入力してください');
    }

    // 비밀번호 길이 검사
    if (password.length < 8) {
      return ResultFactory.failure('パスワードは8文字以上で入力してください');
    }

    // 비밀번호 복잡성 검사
    if (!_isStrongPassword(password)) {
      return ResultFactory.failure('パスワードは英字、数字、特殊文字を含む必要があります');
    }

    // 비밀번호 확인 검사
    if (password != confirmPassword) {
      return ResultFactory.failure('パスワードが一致しません');
    }

    return ResultFactory.success(null, '入力が有効です');
  }

  /// 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// 강한 비밀번호 검사 (영문, 숫자, 특수문자 포함)
  bool _isStrongPassword(String password) {
    // 최소 8자, 영문 대소문자, 숫자, 특수문자 포함
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
    );
    return password.length >= 8 && regex.hasMatch(password);
  }
}
