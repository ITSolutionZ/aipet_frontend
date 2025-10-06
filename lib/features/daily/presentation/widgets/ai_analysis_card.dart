import 'package:aipet_frontend/features/daily/domain/entities/health_analysis.dart';
import 'package:aipet_frontend/shared/shared.dart' hide State;
import 'package:flutter/material.dart';

/// 리포트 다운로드 형식
enum ReportFormat { pdf, png, json }

/// AI 분석 카드 위젯
class AIAnalysisCard extends StatefulWidget {
  final HealthAnalysis analysis;
  final Function(ReportFormat format)? onDownloadReport;

  const AIAnalysisCard({
    super.key,
    required this.analysis,
    this.onDownloadReport,
  });

  @override
  State<AIAnalysisCard> createState() => _AIAnalysisCardState();
}

class _AIAnalysisCardState extends State<AIAnalysisCard> {
  ReportFormat _selectedFormat = ReportFormat.pdf;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AIレポート',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildRiskLevelIndicator(),
          const SizedBox(height: AppSpacing.md),
          _buildRecommendationsSection(),
          if (widget.analysis.warnings.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _buildWarningsSection(),
          ],
          // AI 리포트 다운로드 섹션
          if (widget.onDownloadReport != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildDownloadSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildDownloadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'リポート形式',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF667EEA)),
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ReportFormat>(
              value: _selectedFormat,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF667EEA)),
              style: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
              onChanged: (ReportFormat? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFormat = newValue;
                  });
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ReportFormat.pdf,
                  child: Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 20,
                        color: Color(0xFF667EEA),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Flexible(child: Text('PDF')),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ReportFormat.png,
                  child: Row(
                    children: [
                      Icon(Icons.image, size: 20, color: Color(0xFF667EEA)),
                      SizedBox(width: AppSpacing.sm),
                      Flexible(child: Text('PNG画像')),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ReportFormat.json,
                  child: Row(
                    children: [
                      Icon(Icons.code, size: 20, color: Color(0xFF667EEA)),
                      SizedBox(width: AppSpacing.sm),
                      Flexible(child: Text('JSONデータ')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              widget.onDownloadReport?.call(_selectedFormat);
            },
            icon: _getFormatIcon(_selectedFormat),
            label: Text('${_getFormatText(_selectedFormat)}をダウンロード'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getFormatIcon(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return const Icon(Icons.picture_as_pdf, size: 20);
      case ReportFormat.png:
        return const Icon(Icons.image, size: 20);
      case ReportFormat.json:
        return const Icon(Icons.code, size: 20);
    }
  }

  String _getFormatText(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return 'PDF';
      case ReportFormat.png:
        return 'PNG画像';
      case ReportFormat.json:
        return 'JSONデータ';
    }
  }

  Widget _buildRiskLevelIndicator() {
    final riskData = _getRiskLevelData(widget.analysis.riskLevel);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: riskData.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: riskData.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Icon(riskData.icon, color: riskData.color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  riskData.text,
                  style: AppFonts.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: riskData.color,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  riskData.description,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推奨事項',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...widget.analysis.recommendations.map((recommendation) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(
                color: AppColors.pointGreen.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.pointGreen,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    recommendation,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWarningsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '注意事項',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.pointRed,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...widget.analysis.warnings.map((warning) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointRed.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(
                color: AppColors.pointRed.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.pointRed,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    warning,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  _RiskLevelData _getRiskLevelData(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return _RiskLevelData(
          text: '低リスク',
          description: '現在の健康状態は良好です',
          icon: Icons.check_circle,
          color: AppColors.pointGreen,
        );
      case RiskLevel.medium:
        return _RiskLevelData(
          text: '中リスク',
          description: '注意深く観察してください',
          icon: Icons.warning,
          color: AppColors.pointYellow,
        );
      case RiskLevel.high:
        return _RiskLevelData(
          text: '高リスク',
          description: '獣医師への相談を推奨します',
          icon: Icons.dangerous,
          color: AppColors.pointRed,
        );
    }
  }
}

class _RiskLevelData {
  final String text;
  final String description;
  final IconData icon;
  final Color color;

  _RiskLevelData({
    required this.text,
    required this.description,
    required this.icon,
    required this.color,
  });
}
