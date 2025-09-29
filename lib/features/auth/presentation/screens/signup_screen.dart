import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/auth/presentation/widgets/auth_logo.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 회원가입 화면 폼 상태 관리
final signupFormProvider =
    StateNotifierProvider<SignupFormController, SignupFormState>(
      (ref) => SignupFormController(ref),
    );

class SignupFormController extends StateNotifier<SignupFormState> {
  final Ref ref;

  SignupFormController(this.ref) : super(const SignupFormState());

  void initialize() {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final usernameController = TextEditingController();

    state = state.copyWith(
      formKey: formKey,
      emailController: emailController,
      passwordController: passwordController,
      confirmPasswordController: confirmPasswordController,
      usernameController: usernameController,
    );
  }

  @override
  void dispose() {
    state.emailController?.dispose();
    state.passwordController?.dispose();
    state.confirmPasswordController?.dispose();
    state.usernameController?.dispose();
    super.dispose();
  }
}

class SignupFormState {
  final GlobalKey<FormState>? formKey;
  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPasswordController;
  final TextEditingController? usernameController;

  const SignupFormState({
    this.formKey,
    this.emailController,
    this.passwordController,
    this.confirmPasswordController,
    this.usernameController,
  });

  SignupFormState copyWith({
    GlobalKey<FormState>? formKey,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    TextEditingController? usernameController,
  }) {
    return SignupFormState(
      formKey: formKey ?? this.formKey,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      confirmPasswordController:
          confirmPasswordController ?? this.confirmPasswordController,
      usernameController: usernameController ?? this.usernameController,
    );
  }
}

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(signupFormProvider);

    // Initialize form after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(signupFormProvider.notifier).initialize();
    });

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientBackAppBar(
        title: 'User Profile',
        onBackPressed: () => context.go(AppRouter.loginRoute),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const const const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: formState.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const const const SizedBox(height: AppSpacing.xl),

                // 로고 영역
                const AuthLogo(),

                const const const SizedBox(height: AppSpacing.xl),

                // 구분선
                const Divider(),

                const const const SizedBox(height: AppSpacing.lg),

                // 부제목
                Text(
                  '基本ユーザのプロフィールを登録しましょう',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointBrown,
                  ),
                  textAlign: TextAlign.center,
                ),

                const const const SizedBox(height: AppSpacing.xl),

                // 이메일 입력 필드
                CommonInputField(
                  label: 'メールアドレス ※必須',
                  controller: formState.emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  required: true,
                  onChanged: (value) => {}, // Mock implementation
                  validator: (value) {
                    // 공통 ValidationService 사용
                    final result = ValidationService.validateEmail(value ?? '');
                    return result.isSuccess ? null : result.message;
                  },
                ),

                const const const SizedBox(height: AppSpacing.lg),

                // 패스워드 입력 필드
                CommonInputField(
                  label: 'パスワード ※必須',
                  controller: formState.passwordController,
                  obscureText: true, // Mock implementation
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: Icons.visibility_off,
                  onSuffixIconTap: () => {}, // Mock implementation
                  required: true,
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

                const const const SizedBox(height: AppSpacing.lg),

                // 패스워드 재입력 필드
                CommonInputField(
                  label: 'パスワード再入力 ※必須',
                  controller: formState.confirmPasswordController,
                  obscureText: true, // Mock implementation
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: Icons.visibility_off,
                  onSuffixIconTap: () => {}, // Mock implementation
                  required: true,
                  onChanged: (value) {
                    // 패스워드는 AuthFormState에 저장하지 않음 (보안상 이유)
                    // UI에서만 사용하고 검증 후 즉시 메모리에서 제거
                  },
                  validator: (value) {
                    // 공통 ValidationService 사용
                    final result = ValidationService.validateConfirmPassword(
                      formState.passwordController?.text ?? '',
                      value ?? '',
                    );
                    return result.isSuccess ? null : result.message;
                  },
                ),

                const const const SizedBox(height: AppSpacing.lg),

                // 사용자명 입력 필드
                CommonInputField(
                  label: 'ユーザ名 ※必須',
                  controller: formState.usernameController,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icons.person_outline,
                  required: true,
                  onChanged: (value) => {}, // Mock implementation
                  validator: (value) {
                    // 공통 ValidationService 사용
                    final result = ValidationService.validateUsername(
                      value ?? '',
                    );
                    return result.isSuccess ? null : result.message;
                  },
                ),

                const const const SizedBox(height: AppSpacing.xl),

                // 에러 메시지 (Mock)
                // if (authState.error != null)
                //   ErrorMessage(message: authState.error!),

                // if (authState.error != null)
                const const const SizedBox(height: AppSpacing.lg),

                // 회원가입 버튼
                CommonButton(
                  text: 'SIGN UP',
                  isLoading: false, // Mock implementation
                  type: ButtonType.primary,
                  size: ButtonSize.large,
                  width: double.infinity,
                  onPressed: () {
                    if (formState.formKey?.currentState?.validate() ?? false) {
                      // 데모 앱이므로 바로 홈으로 이동
                      context.go(AppRouter.homeRoute);
                    }
                  },
                ),

                const const const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
