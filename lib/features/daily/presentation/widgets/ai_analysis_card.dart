import 'package:aipet_frontend/features/daily/domain/entities/health_analysis.dart';
import 'package:flutter/material.dart';

class AIAnalysisCard extends StatelessWidget {
  final HealthAnalysis analysis;

  const AIAnalysisCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final result = analysis.result;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: Colors.blue[600], size: 24),
              const SizedBox(width: 8),
              Text(
                'AI健康分析',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRiskLevelColor(
                    result.riskLevel,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result.riskLevel.displayName,
                  style: TextStyle(
                    color: _getRiskLevelColor(result.riskLevel),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 분석 결과 요약
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getRiskLevelColor(
                result.riskLevel,
              ).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getRiskLevelColor(
                  result.riskLevel,
                ).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.riskLevel.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getRiskLevelColor(result.riskLevel),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.summary,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          if (analysis.recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '推奨事項',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            ...analysis.recommendations
                .take(3)
                .map(
                  (recommendation) => _buildRecommendationItem(recommendation),
                ),
          ],

          if (analysis.warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '注意事項',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            ...analysis.warnings.map((warning) => _buildWarningItem(warning)),
          ],

          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.verified, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '信頼度: ${(result.confidenceScore * 100).toInt()}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const Spacer(),
              Text(
                '分析日: ${_formatDate(analysis.analysisDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(HealthRecommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            _getRecommendationIcon(recommendation.type),
            size: 16,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                if (recommendation.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    recommendation.description,
                    style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(WarningSign warning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getWarningLevelColor(warning.level).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getWarningLevelColor(warning.level).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            warning.requiresVeterinaryVisit
                ? Icons.local_hospital
                : Icons.warning,
            size: 16,
            color: _getWarningLevelColor(warning.level),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warning.symptom,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getWarningLevelColor(warning.level),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  warning.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: _getWarningLevelColor(warning.level),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskLevelColor(HealthRiskLevel level) {
    switch (level) {
      case HealthRiskLevel.low:
        return Colors.green[600]!;
      case HealthRiskLevel.medium:
        return Colors.orange[600]!;
      case HealthRiskLevel.high:
        return Colors.red[600]!;
      case HealthRiskLevel.critical:
        return Colors.red[800]!;
    }
  }

  Color _getWarningLevelColor(WarningLevel level) {
    switch (level) {
      case WarningLevel.info:
        return Colors.blue[600]!;
      case WarningLevel.warning:
        return Colors.orange[600]!;
      case WarningLevel.urgent:
        return Colors.red[600]!;
    }
  }

  IconData _getRecommendationIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.diet:
        return Icons.restaurant;
      case RecommendationType.exercise:
        return Icons.directions_run;
      case RecommendationType.medication:
        return Icons.medication;
      case RecommendationType.monitoring:
        return Icons.visibility;
      case RecommendationType.veterinary:
        return Icons.local_hospital;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
