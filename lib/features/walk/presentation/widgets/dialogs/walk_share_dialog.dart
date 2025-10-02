import 'dart:io';

import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 산책 기록 공유 다이얼로그
class WalkShareDialog extends ConsumerWidget {
  final WalkRecordEntity walkRecord;

  const WalkShareDialog({super.key, required this.walkRecord});

  static Future<void> show(BuildContext context, WalkRecordEntity walkRecord) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => WalkShareDialog(walkRecord: walkRecord),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shareText = _generateShareText(walkRecord);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.8,
      minChildSize: 0.4,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.pointGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '散歩記録を共有',
                    style: AppFonts.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.pointDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildShareOption(
                    icon: Icons.copy,
                    title: 'テキストをコピー',
                    subtitle: 'クリップボードにコピー',
                    onTap: () {
                      Navigator.pop(context);
                      _copyToClipboard(context, shareText);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildShareOption(
                    icon: Icons.image,
                    title: 'ファイルとして保存',
                    subtitle: 'テキストファイルで保存',
                    onTap: () {
                      Navigator.pop(context);
                      _saveAsFile(context, walkRecord);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildShareOption(
                    icon: Icons.share,
                    title: 'システム共有',
                    subtitle: '他のアプリで共有',
                    onTap: () {
                      Navigator.pop(context);
                      _systemShare(context, shareText);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 클립보드에 복사
  Future<void> _copyToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('テキストがコピーされました'), backgroundColor: AppColors.pointGreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('コピーに失敗しました: $e'), backgroundColor: AppColors.pointPink),
        );
      }
    }
  }

  /// 파일로 저장
  Future<void> _saveAsFile(BuildContext context, WalkRecordEntity walkRecord) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'walk_record_$timestamp.txt';

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      final walkRecordText = _generateWalkRecordText(walkRecord);
      await file.writeAsString(walkRecordText);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('記録が保存されました: $fileName'),
            backgroundColor: AppColors.pointGreen,
            action: SnackBarAction(
              label: '共有',
              onPressed: () => _systemShare(context, walkRecordText),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e'), backgroundColor: AppColors.pointPink),
        );
      }
    }
  }

  /// 시스템 공유
  Future<void> _systemShare(BuildContext context, String text) async {
    try {
      await Share.share(text, subject: '散歩記録の共有');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('共有が完了しました'), backgroundColor: AppColors.pointGreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('共有に失敗しました: $e'), backgroundColor: AppColors.pointPink),
        );
      }
    }
  }

  /// 공유용 텍스트 생성
  String _generateShareText(WalkRecordEntity walkRecord) {
    final durationHours = walkRecord.duration?.inHours ?? 1;
    final speed = (walkRecord.distance ?? 0) / durationHours;

    return '''🐕 散歩記録 - ${walkRecord.title}

📅 日付: ${walkRecord.startTime.year}/${walkRecord.startTime.month}/${walkRecord.startTime.day}
⏱️ 時間: ${walkRecord.formattedDuration}
📏 距離: ${walkRecord.formattedDistance}
🏃 速度: ${speed.toStringAsFixed(1)} km/h

AI Pet アプリで記録 📱''';
  }

  /// 산책 기록을 텍스트로 생성
  String _generateWalkRecordText(WalkRecordEntity walkRecord) {
    final buffer = StringBuffer();
    buffer.writeln('=== 散歩記録 ===');
    buffer.writeln();
    buffer.writeln('タイトル: ${walkRecord.title}');
    buffer.writeln(
      '日付: ${walkRecord.startTime.year}/${walkRecord.startTime.month}/${walkRecord.startTime.day}',
    );
    buffer.writeln('時間: ${walkRecord.formattedDuration}');
    buffer.writeln('距離: ${walkRecord.formattedDistance}');
    final durationHours = walkRecord.duration?.inHours ?? 1;
    final speed = (walkRecord.distance ?? 0) / durationHours;
    buffer.writeln('速度: ${speed.toStringAsFixed(1)} km/h');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('AI Pet アプリで記録');
    buffer.writeln('記録日時: ${DateTime.now()}');

    return buffer.toString();
  }

  /// 공유 옵션 위젯 생성
  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.pointBlue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
