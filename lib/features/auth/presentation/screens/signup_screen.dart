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
import '../widgets/error_message.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(ref);

    // Welcome 화면으로 이동하는 콜백 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(navigationCallbackNotifierProvider.notifier)
          .setNavigationCallback(() => context.go(AppRouter.welcomeRoute));
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  /// 이메일 검증
  bool _validateEmail(String email) {
    return ValidationUtils.isValidEmail(email);
  }

  /// 비밀번호 검증
  bool _validatePassword(String password) {
    return ValidationUtils.isValidPassword(password);
  }

  /// 사용자명 검증
  bool _validateUsername(String username) {
    return ValidationUtils.hasMinLength(username, 2) &&
        ValidationUtils.hasMaxLength(username, 20);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointOffWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.pointDark,
            size: 20,
          ),
          onPressed: () => context.go(AppRouter.loginRoute),
        ),
        title: Text(
          'User Profile',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
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

                const SizedBox(height: AppSpacing.lg),

                // 부제목
                Text(
                  '基本ユーザのプロフィールを登録しましょう',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointBrown,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                // 이메일 입력 필드
                AuthInputField(
                  label: 'メールアドレス ※必須',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  labelColor: AppColors.pointBrown,
                  onChanged: _authController.updateEmail,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'メールアドレスを入力してください';
                    }

                    // 개발 중에는 모든 입력을 허용
                    if (!_validateEmail(value)) {
                      return '올바른 이메일 형식을 입력해주세요';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // 패스워드 입력 필드
                AuthPasswordField(
                  label: 'パスワード ※必須',
                  controller: _passwordController,
                  isVisible: authState.isPasswordVisible,
                  labelColor: AppColors.pointBrown,
                  onToggleVisibility: _authController.togglePasswordVisibility,
                  onChanged: _authController.updatePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを入力してください';
                    }

                    // 개발 중에는 모든 입력을 허용
                    if (!_validatePassword(value)) {
                      return '올바른 비밀번호 형식을 입력해주세요';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // 패스워드 재입력 필드
                AuthPasswordField(
                  label: 'パスワード再入力 ※必須',
                  controller: _confirmPasswordController,
                  isVisible: authState.isConfirmPasswordVisible,
                  labelColor: AppColors.pointBrown,
                  onToggleVisibility:
                      _authController.toggleConfirmPasswordVisibility,
                  onChanged: _authController.updateConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを再入力してください';
                    }
                    if (value != _passwordController.text) {
                      return 'パスワードが一致しません';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // 사용자명 입력 필드
                AuthInputField(
                  label: 'ユーザ名 ※必須',
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icons.person_outline,
                  labelColor: AppColors.pointBrown,
                  onChanged: _authController.updateUsername,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ユーザ名を入力してください';
                    }

                    // 개발 중에는 모든 입력을 허용
                    if (!_validateUsername(value)) {
                      return '사용자명은 2-20자 사이여야 합니다';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // 에러 메시지
                if (authState.error != null)
                  ErrorMessage(message: authState.error!),

                if (authState.error != null)
                  const SizedBox(height: AppSpacing.lg),

                // 회원가입 버튼
                AuthButton(
                  text: 'SIGN UP',
                  isLoading: authState.isLoading,
                  backgroundColor: AppColors.pointBrown,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 데모 앱이므로 바로 홈으로 이동
                      context.go(AppRouter.homeRoute);
                    }
                  },
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
