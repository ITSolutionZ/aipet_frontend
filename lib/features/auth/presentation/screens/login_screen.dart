import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../data/auth_providers.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_logo.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(ref);

    // 홈 화면으로 이동하는 콜백 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(navigationCallbackNotifierProvider.notifier)
          .setNavigationCallback(() => context.go(AppRouter.homeRoute));

      // 저장된 로그인 정보 불러오기
      _loadSavedCredentials();
    });
  }

  Future<void> _loadSavedCredentials() async {
    try {
      await _authController.loadSavedCredentials();

      // 저장된 정보가 있으면 텍스트 컨트롤러 업데이트
      final authState = ref.read(authFormStateNotifierProvider);
      if (authState.rememberMe) {
        setState(() {
          _emailController.text = authState.email;
          // 패스워드는 저장하지 않으므로 컨트롤러에 설정하지 않음
        });
      }
    } catch (e) {
      LoggerService.error('로그인 정보 불러오기 실패', error: e);
      // 에러가 발생해도 앱은 정상적으로 작동하도록 함
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 패스워드 재설정 다이얼로그 표시
  void _showPasswordResetDialog(BuildContext context) {
    CommonDialogPatterns.showStandardDialog(
      context: context,
      title: _passwordResetTitle,
      content: const Text(
        _passwordResetMessage,
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(_okButtonText),
        ),
      ],
    );
  }

  // UI 텍스트 상수
  static const String _passwordResetTitle = 'パスワード再設定';
  static const String _passwordResetMessage =
      'パスワード再設定機能は準備中です。\n\nFirebase Auth連携後に実装予定です。';
  static const String _okButtonText = 'OK';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authFormStateNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 로고 섹션
              const Column(
                children: [
                  SizedBox(height: AppSpacing.lg),
                  AuthLogo(),
                  SizedBox(height: AppSpacing.lg),
                  AuthDivider(),
                  SizedBox(height: AppSpacing.lg),
                ],
              ),

              // 입력 섹션
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 이메일 입력 필드
                    CommonInputField(
                      label: 'メールアドレス',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      onChanged: _authController.updateEmail,
                      validator: (value) {
                        // 공통 ValidationService 사용
                        final result = ValidationService.validateEmail(
                          value ?? '',
                        );
                        return result.isSuccess ? null : result.message;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 패스워드 입력 필드
                    CommonInputField(
                      label: 'パスワード',
                      controller: _passwordController,
                      obscureText: !authState.isPasswordVisible,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: authState.isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      onSuffixIconTap: _authController.togglePasswordVisibility,
                      onChanged: (value) {
                        // 패스워드는 AuthFormState에 저장하지 않음 (보안상 이유)
                        // UI에서만 사용하고 검증 후 즉시 메모리에서 제거
                      },
                      validator: (value) {
                        // 공통 ValidationService 사용
                        final result = ValidationService.validatePassword(
                          value ?? '',
                        );
                        return result.isSuccess ? null : result.message;
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Remember Me & 패스워드 재설정
                    Row(
                      children: [
                        Checkbox(
                          value: authState.rememberMe,
                          onChanged: (_) => _authController.toggleRememberMe(),
                          activeColor: AppColors.pointBrown,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        Text(
                          'ログイン情報を記憶',
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.pointGray,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            _showPasswordResetDialog(context);
                          },
                          child: Text(
                            'パスワード再設定',
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointBrown,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.pointBrown,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 로그인 버튼
                    CommonButton(
                      text: 'ログイン',
                      isLoading: authState.isLoading,
                      type: ButtonType.primary,
                      size: ButtonSize.large,
                      width: double.infinity,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: 개발 완료 후 삭제할 임시 로그인 우회 로직
                          // 현재는 아무 입력값이나 넣어도 로그인 성공 처리
                          LoggerService.warning(
                            '임시 로그인 우회 실행',
                            data: {'email': _emailController.text},
                          );

                          // 임시로 성공 처리 후 홈으로 이동
                          _authController.handleTempLoginSuccess();
                          context.go(AppRouter.homeRoute);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 소셜 로그인 섹션
              Column(
                children: [
                  const AuthDivider(text: 'または'),
                  const SizedBox(height: AppSpacing.xl),

                  SocialLoginButton(
                    type: SocialLoginType.email,
                    onPressed: () {
                      // TODO: 개발 완료 후 실제 회원가입 화면으로 이동
                      LoggerService.warning('임시 소셜 로그인 우회: 이메일 회원가입');
                      context.go(AppRouter.signupRoute);
                    },
                    isLoading: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SocialLoginButton(
                    type: SocialLoginType.google,
                    onPressed: () {
                      // TODO: 개발 완료 후 삭제할 임시 로그인 우회
                      LoggerService.warning('임시 소셜 로그인 우회: Google');
                      _authController.handleTempLoginSuccess();
                      context.go(AppRouter.homeRoute);
                    },
                    isLoading: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SocialLoginButton(
                    type: SocialLoginType.apple,
                    onPressed: () {
                      // TODO: 개발 완료 후 삭제할 임시 로그인 우회
                      LoggerService.warning('임시 소셜 로그인 우회: Apple');
                      _authController.handleTempLoginSuccess();
                      context.go(AppRouter.homeRoute);
                    },
                    isLoading: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SocialLoginButton(
                    type: SocialLoginType.line,
                    onPressed: () {
                      // TODO: 개발 완료 후 삭제할 임시 로그인 우회
                      LoggerService.warning('임시 소셜 로그인 우회: LINE');
                      _authController.handleTempLoginSuccess();
                      context.go(AppRouter.homeRoute);
                    },
                    isLoading: false,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
