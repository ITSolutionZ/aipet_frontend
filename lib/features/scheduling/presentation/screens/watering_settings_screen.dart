import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 급수 설정 화면
class WateringSettingsScreen extends ConsumerStatefulWidget {
  const WateringSettingsScreen({super.key});

  @override
  ConsumerState<WateringSettingsScreen> createState() =>
      _WateringSettingsScreenState();
}

class _WateringSettingsScreenState
    extends ConsumerState<WateringSettingsScreen> {
  bool _autoWateringEnabled = false;
  bool _notificationsEnabled = true;
  bool _lowWaterAlertEnabled = true;
  double _waterAmount = 200.0;
  int _alertThreshold = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(title: '給水設定'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 자동 급수 설정
              _buildAutoWateringSection(),
              const SizedBox(height: AppSpacing.lg),

              // 급수량 설정
              _buildWaterAmountSection(),
              const SizedBox(height: AppSpacing.lg),

              // 알림 설정
              _buildNotificationSection(),
              const SizedBox(height: AppSpacing.lg),

              // 급수기 설정
              _buildWateringDeviceSection(),
              const SizedBox(height: AppSpacing.lg),

              // 고급 설정
              _buildAdvancedSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// 자동 급수 설정 섹션
  Widget _buildAutoWateringSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '自動給水設定',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              title: const Text('自動給水を有効にする'),
              subtitle: const Text('設定された時間に自動で給水します'),
              value: _autoWateringEnabled,
              onChanged: (value) {
                setState(() {
                  _autoWateringEnabled = value;
                });
              },
              activeColor: AppColors.pointBlue,
            ),
          ],
        ),
      ),
    );
  }

  /// 급수량 설정 섹션
  Widget _buildWaterAmountSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '給水量設定',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '1回の給水量: ${_waterAmount.round()}ml',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
            Slider(
              value: _waterAmount,
              min: 50,
              max: 500,
              divisions: 45,
              activeColor: AppColors.pointBlue,
              onChanged: (value) {
                setState(() {
                  _waterAmount = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 알림 설정 섹션
  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '通知設定',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              title: const Text('給水通知を有効にする'),
              subtitle: const Text('給水時間に通知を受け取ります'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: AppColors.pointBlue,
            ),
            SwitchListTile(
              title: const Text('水量不足アラート'),
              subtitle: const Text('給水器の水が少なくなったら通知します'),
              value: _lowWaterAlertEnabled,
              onChanged: (value) {
                setState(() {
                  _lowWaterAlertEnabled = value;
                });
              },
              activeColor: AppColors.pointBlue,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'アラート閾値: $_alertThreshold%',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
            Slider(
              value: _alertThreshold.toDouble(),
              min: 10,
              max: 90,
              divisions: 8,
              activeColor: AppColors.pointBrown,
              onChanged: (value) {
                setState(() {
                  _alertThreshold = value.round();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 급수기 설정 섹션
  Widget _buildWateringDeviceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '給水器設定',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const ListTile(
              leading: Icon(Icons.water_drop, color: AppColors.pointBlue),
              title: Text('スマート給水器'),
              subtitle: Text('接続済み - バッテリー残量: 85%'),
              trailing: Icon(
                Icons.signal_cellular_4_bar,
                color: AppColors.pointGreen,
              ),
            ),
            const const const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.pointGray),
              title: const Text('給水器を再設定'),
              subtitle: const Text('新しい給水器を接続します'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showDeviceResetDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: AppColors.pointGray),
              title: const Text('給水器情報'),
              subtitle: const Text('デバイスの詳細情報を表示'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showDeviceInfoDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 고급 설정 섹션
  Widget _buildAdvancedSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '高度な設定',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.schedule, color: AppColors.pointGray),
              title: const Text('給水スケジュール管理'),
              subtitle: const Text('詳細な給水スケジュールを設定'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.pushNamed('watering-schedule');
              },
            ),
            const const const Divider(),
            ListTile(
              leading: const Icon(Icons.analytics, color: AppColors.pointGray),
              title: const Text('データエクスポート'),
              subtitle: const Text('給水データをCSVファイルでエクスポート'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showExportDataDialog();
              },
            ),
            const const const Divider(),
            ListTile(
              leading: const Icon(Icons.restore, color: AppColors.pointGray),
              title: const Text('設定をリセット'),
              subtitle: const Text('すべての設定を初期値に戻します'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showResetDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 설정 초기화 다이얼로그
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('設定をリセット'),
          content: const Text('すべての設定を初期値に戻しますか？この操作は取り消せません。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetSettings();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('設定をリセットしました')));
              },
              child: const Text('リセット'),
            ),
          ],
        );
      },
    );
  }

  /// 설정 초기화
  void _resetSettings() {
    setState(() {
      _autoWateringEnabled = false;
      _notificationsEnabled = true;
      _lowWaterAlertEnabled = true;
      _waterAmount = 200.0;
      _alertThreshold = 50;
    });
  }

  /// 급수기 재설정 다이얼로그
  void _showDeviceResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('給水器を再設定'),
          content: const Text('新しい給水器を接続しますか？現在の設定は保持されます。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('給水器の再設定を開始しました'),
                    backgroundColor: AppColors.pointBlue,
                  ),
                );
              },
              child: const Text('再設定'),
            ),
          ],
        );
      },
    );
  }

  /// 급수기 정보 다이얼로그
  void _showDeviceInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('給水器情報'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('デバイス名: スマート給水器'),
              SizedBox(height: 8),
              Text('モデル: SW-2024'),
              SizedBox(height: 8),
              Text('ファームウェア: v1.2.3'),
              SizedBox(height: 8),
              Text('バッテリー残量: 85%'),
              SizedBox(height: 8),
              Text('接続状態: 接続済み'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  /// 데이터 내보내기 다이얼로그
  void _showExportDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('データエクスポート'),
          content: const Text('給水データをCSVファイルとしてエクスポートしますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('データをエクスポートしました'),
                    backgroundColor: AppColors.pointGreen,
                  ),
                );
              },
              child: const Text('エクスポート'),
            ),
          ],
        );
      },
    );
  }
}
