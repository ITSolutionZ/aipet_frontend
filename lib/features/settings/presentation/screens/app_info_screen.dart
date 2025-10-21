import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 앱 정보 화면
class AppInfoScreen extends ConsumerStatefulWidget {
  const AppInfoScreen({super.key});

  @override
  ConsumerState<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends ConsumerState<AppInfoScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // 앱 기본 정보
          _buildAppInfoCard(),
          const SizedBox(height: AppSpacing.lg),

          // 버전 정보
          _buildVersionCard(),
          const SizedBox(height: AppSpacing.lg),

          // 오픈소스 라이선스
          _buildLicenseCard(),
          const SizedBox(height: AppSpacing.lg),

          // 개발자 정보
          _buildDeveloperCard(),
        ],
      ),
    );
  }

  /// 앱 기본 정보 카드
  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'アプリ情報',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('アプリ名', 'AI Pet'),
          _buildInfoRow('説明', 'AIペット管理アプリ'),
          _buildInfoRow('開発者', 'AIPET ITSOLUTIONS'),
        ],
      ),
    );
  }

  /// 버전 정보 카드
  Widget _buildVersionCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'バージョン情報',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_packageInfo != null) ...[
            _buildInfoRow('バージョン', _packageInfo!.version),
            _buildInfoRow('ビルド番号', _packageInfo!.buildNumber),
            _buildInfoRow('パッケージ名', _packageInfo!.packageName),
          ] else
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  /// 오픈소스 라이선스 카드
  Widget _buildLicenseCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'オープンソースライセンス',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'このアプリは以下のオープンソースライブラリを使用しています：',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLicenseList(),
        ],
      ),
    );
  }

  /// 개발자 정보 카드
  Widget _buildDeveloperCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '開発者情報',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('会社名', 'AIPET ITSOLUTIONS'),
          _buildInfoRow('連絡先', 'support@aipet.com'),
          _buildInfoRow('ウェブサイト', 'https://aipet.com'),
        ],
      ),
    );
  }

  /// 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 라이선스 목록
  Widget _buildLicenseList() {
    final licenses = [
      'Flutter SDK - BSD 3-Clause License',
      'Dart SDK - BSD 3-Clause License',
      'Firebase - Apache License 2.0',
      'Google Sign-In - Apache License 2.0',
      'Riverpod - MIT License',
      'GoRouter - BSD 3-Clause License',
      'SharedPreferences - BSD 3-Clause License',
      'WebView Flutter - BSD 3-Clause License',
      'Flutter SVG - MIT License',
      'Lottie - Apache License 2.0',
      'FL Chart - MIT License',
      'HTTP - BSD 3-Clause License',
      'Path Provider - BSD 3-Clause License',
      'Crypto - BSD 3-Clause License',
      'Flutter Local Notifications - BSD 3-Clause License',
      'URL Launcher - BSD 3-Clause License',
      'Share Plus - BSD 3-Clause License',
      'Permission Handler - MIT License',
      'Flutter Secure Storage - BSD 3-Clause License',
      'Dio - MIT License',
      'Package Info Plus - BSD 3-Clause License',
      'Connectivity Plus - BSD 3-Clause License',
      'Flutter Dotenv - MIT License',
      'Geolocator - BSD 3-Clause License',
      'Google Maps Flutter - Apache License 2.0',
      'Location - BSD 3-Clause License',
      'Image Picker - BSD 3-Clause License',
      'Image - MIT License',
      'Logger - MIT License',
      'Sentry Flutter - BSD 3-Clause License',
      'Sqflite - BSD 3-Clause License',
      'Path - BSD 3-Clause License',
      'QR Flutter - MIT License',
      'Table Calendar - MIT License',
      'PDF - BSD 3-Clause License',
      'Printing - BSD 3-Clause License',
      'Intl - BSD 3-Clause License',
      'Google APIs - Apache License 2.0',
      'Google APIs Auth - Apache License 2.0',
      'Extension Google Sign-In - Apache License 2.0',
      'Local Auth - BSD 3-Clause License',
      'Mockito - Apache License 2.0',
      'Freezed - MIT License',
      'JSON Annotation - BSD 3-Clause License',
      'Meta - BSD 3-Clause License',
      'Mobile Scanner - BSD 3-Clause License',
      'UUID - BSD 3-Clause License',
      'Sentry Dart Plugin - BSD 3-Clause License',
      'Flutter Lints - BSD 3-Clause License',
      'Riverpod Generator - MIT License',
      'JSON Serializable - BSD 3-Clause License',
      'Build Runner - BSD 3-Clause License',
      'Test - BSD 3-Clause License',
      'Sqflite Common FFI - BSD 3-Clause License',
      'Flutter Native Splash - BSD 3-Clause License',
      'Flutter Launcher Icons - MIT License',
      'Noto Sans JP - SIL Open Font License 1.1',
      'M PLUS Rounded 1c - SIL Open Font License 1.1',
    ];

    return Column(
      children: licenses.map((license) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(color: AppColors.pointBrown)),
            Expanded(
              child: Text(
                license,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
