import 'dart:async';

import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/dialogs/app_lock_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 개발용 로그인 화면
///
/// 개발 단계에서 검증을 우회하고 바로 홈 화면으로 이동할 수 있는 간단한 화면입니다.
/// 추후 라우터만 수정하여 실제 로그인 화면으로 전환할 수 있습니다.
class DevLoginScreen extends ConsumerStatefulWidget {
  const DevLoginScreen({super.key});

  @override
  ConsumerState<DevLoginScreen> createState() => _DevLoginScreenState();
}

class _DevLoginScreenState extends ConsumerState<DevLoginScreen> {
  final _emailController = TextEditingController(text: 'dev@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 앱 잠금이 설정되어 있으면 잠금 해제 다이얼로그 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppLock();
    });
  }

  Future<void> _checkAppLock() async {
    final prefs = await SharedPreferences.getInstance();
    final pinEnabled = prefs.getBool('pin_enabled') ?? false;
    final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

    if ((pinEnabled || biometricEnabled) && mounted) {
      unawaited(
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AppLockDialog(
            enablePin: pinEnabled,
            enableBiometric: biometricEnabled,
            onSuccess: () {
              // PIN/생체인증 성공 - 자동 로그인 수행
              _autoLogin();
            },
          ),
        ),
      );
    }
  }

  /// PIN/생체인증 성공 시 자동 로그인
  Future<void> _autoLogin() async {
    // 개발용 딜레이
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('開発モードでログインしました'),
          backgroundColor: AppColors.pointGreen,
        ),
      );

      if (mounted) {
        context.go(AppRouter.homeRoute);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 개발용 로그인 처리
  Future<void> _handleDevLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 개발용 딜레이 (실제 로그인 느낌을 위해)
      await Future.delayed(const Duration(seconds: 1));

      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('開発モードでログインしました'),
            backgroundColor: AppColors.pointGreen,
          ),
        );

        // 홈 화면으로 이동
        if (mounted) {
          context.go(AppRouter.homeRoute);
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ログインエラー: $error'),
            backgroundColor: AppColors.pointBrown,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),

              // 로고 섹션
              _buildLogoSection(),

              const SizedBox(height: AppSpacing.xl),

              // 개발 모드 알림
              _buildDevModeNotice(),

              const SizedBox(height: AppSpacing.xl),

              // 입력 필드
              _buildInputFields(),

              const SizedBox(height: AppSpacing.lg),

              // 로그인 버튼
              _buildLoginButton(),

              const Spacer(),

              // 개발 정보
              _buildDevInfo(),
            ],
          ),
        ),
      ),
    );
  }

  /// 로고 섹션
  Widget _buildLogoSection() {
    return Column(
      children: [
        // 로고 이미지
        Image.asset(
          'assets/icons/logos/aipet_logo.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('로고 로드 실패: $error');
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.pointBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: const Icon(
                Icons.pets,
                size: 60,
                color: AppColors.pointBrown,
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.md),

        // 브랜드명
        Text(
          'AIPET',
          style: AppFonts.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
        ),

        Text(
          'ITSOLUTIONZ',
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.pointBrown.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// 개발 모드 알림
  Widget _buildDevModeNotice() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: AppColors.pointBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.developer_mode,
            color: AppColors.pointBlue,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '開発モード: 任意の入力でログインできます',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 입력 필드
  Widget _buildInputFields() {
    return Column(
      children: [
        // 이메일 필드
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'メールアドレス',
            hintText: '任意のメールアドレスを入力',
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.pointBrown,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              borderSide: const BorderSide(color: AppColors.pointBrown),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              borderSide: const BorderSide(
                color: AppColors.pointBrown,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: AppSpacing.md),

        // 패스워드 필드
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'パスワード',
            hintText: '任意のパスワードを入力',
            prefixIcon: const Icon(
              Icons.lock_outlined,
              color: AppColors.pointBrown,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              borderSide: const BorderSide(color: AppColors.pointBrown),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              borderSide: const BorderSide(
                color: AppColors.pointBrown,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          obscureText: true,
        ),
      ],
    );
  }

  /// 로그인 버튼
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleDevLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointBrown,
          foregroundColor: AppColors.pointOffWhite,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.pointOffWhite,
                  ),
                ),
              )
            : Text(
                '開発ログイン',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// 개발 정보
  Widget _buildDevInfo() {
    return Column(
      children: [
        Divider(color: AppColors.pointBrown.withValues(alpha: 0.2)),

        const SizedBox(height: AppSpacing.md),

        Text(
          '開発モード',
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointBrown.withValues(alpha: 0.6),
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          '本番環境では実際の認証が必要です',
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointBrown.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
