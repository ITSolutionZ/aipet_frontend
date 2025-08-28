import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../data/auth_providers.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_password_field.dart';
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
      final authState = ref.read(authStateNotifierProvider);
      if (authState.rememberMe) {
        setState(() {
          _emailController.text = authState.email;
          _passwordController.text = authState.password;
        });
      }
    } catch (e) {
      debugPrint('로그인 정보 불러오기 중 에러 발생: $e');
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'パスワード再設定',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'パスワード再設定機能は準備中です。\n\nFirebase Auth連携後に実装予定です。',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xl),

                // 로고 영역
                const AuthLogo(),

                const SizedBox(height: AppSpacing.xl),

                // 구분선
                const AuthDivider(),

                const SizedBox(height: AppSpacing.xl),

                // 이메일 입력 필드
                AuthInputField(
                  label: 'メールアドレス',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  onChanged: _authController.updateEmail,
                  validator: (value) {
                    // 개발 모드에서는 유효성 검사 생략 (빈 값만 체크)
                    if (value == null || value.isEmpty) {
                      return 'メールアドレスを入力してください';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // 패스워드 입력 필드
                AuthPasswordField(
                  label: 'パスワード',
                  controller: _passwordController,
                  isVisible: authState.isPasswordVisible,
                  onToggleVisibility: _authController.togglePasswordVisibility,
                  onChanged: _authController.updatePassword,
                  validator: (value) {
                    // 개발 모드에서는 유효성 검사 생략 (빈 값만 체크)
                    if (value == null || value.isEmpty) {
                      return 'パスワードを入力してください';
                    }
                    return null;
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
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                AuthButton(
                  text: 'ログイン',
                  isLoading: authState.isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 데모 앱이므로 바로 홈으로 이동
                      context.go(AppRouter.homeRoute);
                    }
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // 또는 구분선
                const AuthDivider(text: 'または'),

                const SizedBox(height: AppSpacing.xl),

                // 소셜 로그인 버튼들
                Column(
                  children: [
                    SocialLoginButton(
                      type: SocialLoginType.email,
                      onPressed: () => context.go(AppRouter.signupRoute),
                      isLoading: false,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SocialLoginButton(
                      type: SocialLoginType.google,
                      onPressed: () =>
                          context.go(AppRouter.homeRoute), // 데모 앱이므로 바로 홈으로 이동
                      isLoading: false,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SocialLoginButton(
                      type: SocialLoginType.apple,
                      onPressed: () =>
                          context.go(AppRouter.homeRoute), // 데모 앱이므로 바로 홈으로 이동
                      isLoading: false,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SocialLoginButton(
                      type: SocialLoginType.line,
                      onPressed: () =>
                          context.go(AppRouter.homeRoute), // 데모 앱이므로 바로 홈으로 이동
                      isLoading: false,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
