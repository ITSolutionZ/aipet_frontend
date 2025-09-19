import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../data/auth_providers.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_logo.dart';
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authFormStateNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientBackAppBar(
        title: 'User Profile',
        onBackPressed: () => context.go(AppRouter.loginRoute),
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
                CommonInputField(
                  label: 'メールアドレス ※必須',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  required: true,
                  onChanged: _authController.updateEmail,
                  validator: (value) {
                    // 공통 ValidationService 사용
                    final result = ValidationService.validateEmail(value ?? '');
                    return result.isSuccess ? null : result.message;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // 패스워드 입력 필드
                CommonInputField(
                  label: 'パスワード ※必須',
                  controller: _passwordController,
                  obscureText: !authState.isPasswordVisible,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: authState.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  onSuffixIconTap: _authController.togglePasswordVisibility,
                  required: true,
                  onChanged: (value) {
                    // 패스워드는 AuthFormState에 저장하지 않음 (보안상 이유)
                    // UI에서만 사용하고 검증 후 즉시 메모리에서 제거
                  },
                  validator: (value) {
                    // 공통 ValidationService 사용
                    final result = ValidationService.validatePassword(value ?? '');
                    return result.isSuccess ? null : result.message;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // 패스워드 재입력 필드
                CommonInputField(
                  label: 'パスワード再入力 ※必須',
                  controller: _confirmPasswordController,
                  obscureText: !authState.isConfirmPasswordVisible,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: authState.isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  onSuffixIconTap: _authController.toggleConfirmPasswordVisibility,
                  required: true,
                  onChanged: (value) {
                    // 패스워드는 AuthFormState에 저장하지 않음 (보안상 이유)
                    // UI에서만 사용하고 검증 후 즉시 메모리에서 제거
                  },
                  validator: (value) {
                    // 공통 ValidationService 사용
                    final result = ValidationService.validateConfirmPassword(
                      _passwordController.text,
                      value ?? '',
                    );
                    return result.isSuccess ? null : result.message;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // 사용자명 입력 필드
                CommonInputField(
                  label: 'ユーザ名 ※必須',
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icons.person_outline,
                  required: true,
                  onChanged: _authController.updateUsername,
                  validator: (value) {
                    // 공통 ValidationService 사용
                    final result = ValidationService.validateUsername(value ?? '');
                    return result.isSuccess ? null : result.message;
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // 에러 메시지
                if (authState.error != null)
                  ErrorMessage(message: authState.error!),

                if (authState.error != null)
                  const SizedBox(height: AppSpacing.lg),

                // 회원가입 버튼
                CommonButton(
                  text: 'SIGN UP',
                  isLoading: authState.isLoading,
                  type: ButtonType.primary,
                  size: ButtonSize.large,
                  width: double.infinity,
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
