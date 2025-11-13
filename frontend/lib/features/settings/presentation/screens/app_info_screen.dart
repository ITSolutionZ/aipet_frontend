import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// URL 열기
  Future<void> _openUrl(String urlString) async {
    try {
      final url = Uri.parse(urlString);
      await launchUrl(url);
      LoggerService.debug('URLを開きました: $urlString');
    } catch (e) {
      LoggerService.debug('URL起動エラー: $e');
      if (mounted) {
        SnackBarService.showError(context, 'URLを開けませんでした');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(title: 'アプリ情報'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // 앱 로고 및 이름
          _buildAppLogoSection(),
          const SizedBox(height: AppSpacing.xl),

          // 앱 기본 정보
          _buildAppInfoCard(),
          const SizedBox(height: AppSpacing.lg),

          // 버전 정보
          _buildVersionCard(),
          const SizedBox(height: AppSpacing.lg),

          // 저작권 정보
          _buildCopyrightCard(),
          const SizedBox(height: AppSpacing.lg),

          // 약관 및 정책
          _buildPoliciesCard(),
          const SizedBox(height: AppSpacing.lg),

          // 개발자 정보
          _buildDeveloperCard(),
          const SizedBox(height: AppSpacing.lg),

          // 오픈소스 라이선스
          _buildLicenseCard(),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// 앱 로고 섹션
  Widget _buildAppLogoSection() {
    return Center(
      child: Column(
        children: [
          // 앱 로고
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(AppRadius.large),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.large),
              child: Image.asset(
                'assets/icons/logos/aipet_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // 앱 이름
          Text(
            'AI Pet',
            style: AppFonts.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'AIペット管理アプリ',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
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
          _buildInfoRow('カテゴリ', 'ライフスタイル'),
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

  /// 저작권 정보 카드
  Widget _buildCopyrightCard() {
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
            '著作権情報',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '© 2024 AIPET ITSOLUTIONS\nAll rights reserved.',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'このアプリケーションおよびそのコンテンツは、著作権法により保護されています。無断転載・複製を禁じます。',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 약관 및 정책 카드
  Widget _buildPoliciesCard() {
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
            '利用規約・プライバシー',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPolicyLink(
            '利用規約',
            Icons.description_outlined,
            () => _openUrl(
              'https://www.notion.so/AiPet-299e1bdea1888039a223dcf1779aae13?source=copy_link',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPolicyLink(
            'プライバシーポリシー',
            Icons.privacy_tip_outlined,
            () => _openUrl(
              'https://www.notion.so/AiPet-299e1bdea188806d83ecfcf974fc1e9a?source=copy_link',
            ),
          ),
        ],
      ),
    );
  }

  /// 정책 링크 위젯
  Widget _buildPolicyLink(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.pointBrown),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
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
          _buildInfoRow('会社名', 'アイティーソリューションズ株式会社（ITZ）'),
          _buildClickableInfoRow(
            '連絡先',
            'support@aipet.com',
            () => _openUrl('mailto:support@aipet.com'),
          ),
          _buildClickableInfoRow(
            'ウェブサイト',
            'https://itsol.co.jp',
            () => _openUrl('https://www.itsol.co.jp/'),
          ),
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
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLicenseList(),
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
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
            ),
          ),
        ],
      ),
    );
  }

  /// 클릭 가능한 정보 행 위젯
  Widget _buildClickableInfoRow(
    String label,
    String value,
    VoidCallback onTap,
  ) {
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
            child: InkWell(
              onTap: onTap,
              child: Text(
                value,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointBrown,
                  decoration: TextDecoration.underline,
                ),
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
      children: licenses
          .map(
            (license) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: AppColors.pointBrown,
                      fontSize: AppFonts.bodySmall.fontSize,
                    ),
                  ),
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
            ),
          )
          .toList(),
    );
  }
}
