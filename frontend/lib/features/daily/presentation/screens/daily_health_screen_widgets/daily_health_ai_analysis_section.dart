import 'dart:async';

import 'package:aipet_frontend/features/daily/data/providers/health_report_provider.dart';
import 'package:aipet_frontend/features/daily/data/services/health_data_collection_service.dart';
import 'package:aipet_frontend/features/daily/domain/entities/health_analysis.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_screen_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/ai_analysis_card.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

// Daily health specific widgets
import '../../widgets/daily_health_common_widgets.dart' as daily_widgets;

/// Daily Health AI 분석 섹션
class DailyHealthAIAnalysisSection extends ConsumerWidget {
  final HealthAnalysis analysis;

  const DailyHealthAIAnalysisSection({super.key, required this.analysis});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenData = ref.watch(dailyHealthScreenControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const daily_widgets.SectionHeaderWidget(
          title: 'AI健康分析',
          subtitle: '専門的なアドバイス',
        ),
        const SizedBox(height: AppSpacing.md),
        AIAnalysisCard(
          analysis: analysis,
          onDownloadReport: screenData.selectedPetId != null
              ? (format) => _handleDownloadWithFormat(
                  context,
                  ref,
                  screenData.selectedPetId!,
                  format,
                )
              : null,
        ),
      ],
    );
  }

  /// AI 건강 리포트 다운로드 처리
  void _handleDownloadWithFormat(
    BuildContext context,
    WidgetRef ref,
    String petId,
    ReportFormat format,
  ) async {
    bool dialogShown = false;

    try {
      // 로딩 다이얼로그 표시
      if (context.mounted) {
        unawaited(
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => PopScope(
              canPop: false,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _getLoadingMessage(format),
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '30秒ほどお待ちください',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        dialogShown = true;
      }

      // 펫 정보 가져오기
      final petsAsync = await ref.read(petProfilesProvider.future);
      final pet = petsAsync.firstWhere(
        (p) => p.id == petId,
        orElse: () => throw Exception('ペットが見つかりません'),
      );

      // 형식에 따른 파일 생성
      late final String filePath;
      late final String subject;
      late final String mimeType;

      switch (format) {
        case ReportFormat.pdf:
          final pdfFile = await ref
              .read(generateHealthReportPdfProvider(pet).future)
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () {
                  LoggerService.debug('⏰ PDF generation timeout');
                  throw Exception('レポート生成がタイムアウトしました。もう一度お試しください。');
                },
              );
          filePath = pdfFile.path;
          subject = '${pet.name}の健康レポート(PDF)';
          mimeType = 'application/pdf';
          break;

        case ReportFormat.png:
          final pngFile = await ref
              .read(generateHealthReportPngProvider(pet).future)
              .timeout(
                const Duration(seconds: 45),
                onTimeout: () {
                  LoggerService.debug('⏰ PNG generation timeout');
                  throw Exception('PNG生成がタイムアウトしました。もう一度お試しください。');
                },
              );
          filePath = pngFile.path;
          subject = '${pet.name}の健康レポート(PNG)';
          mimeType = 'image/png';
          break;

        case ReportFormat.json:
          final collectionService = HealthDataCollectionService();
          final healthData = await collectionService.collectMonthlyHealthData(
            pet,
          );
          final jsonFile = await collectionService.saveHealthDataAsJson(
            pet,
            healthData,
          );
          filePath = jsonFile.path;
          subject = '${pet.name}の健康データ(JSON)';
          mimeType = 'application/json';
          break;
      }

      // 공유 다이얼로그 표시
      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(filePath, mimeType: mimeType)],
          subject: subject,
          text: _getShareText(format),
        );

        // 성공 메시지
        if (context.mounted) {
          SnackBarService.showSuccess(
            context,
            _getSuccessMessage(format),
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e, stackTrace) {
      LoggerService.debug('❌ PDF generation error: $e');
      LoggerService.debug('Stack trace: $stackTrace');

      // 에러 메시지 표시
      if (context.mounted) {
        SnackBarService.showError(
          context,
          'レポート生成に失敗しました',
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      // 로딩 다이얼로그 무조건 닫기
      if (dialogShown && context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          LoggerService.debug('⚠️ Failed to close dialog: $e');
        }
      }
    }
  }

  /// 로딩 메시지를 형식에 따라 반환
  String _getLoadingMessage(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return 'AI健康レポートを生成中...';
      case ReportFormat.png:
        return 'PNG画像を生成中...';
      case ReportFormat.json:
        return 'JSONデータを生成中...';
    }
  }

  /// 공유 텍스트를 형식에 따라 반환
  String _getShareText(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return '1ヶ月間の健康分析レポートです';
      case ReportFormat.png:
        return '健康レポートの画像です';
      case ReportFormat.json:
        return '健康データのJSONファイルです';
    }
  }

  /// 성공 메시지를 형식에 따라 반환
  String _getSuccessMessage(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return 'PDFレポートを保存しました';
      case ReportFormat.png:
        return 'PNG画像を保存しました';
      case ReportFormat.json:
        return 'JSONデータを保存しました';
    }
  }
}
