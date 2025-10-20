import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';

/// 위험도 지시기 및 산책 어드바이스
class WeatherRiskIndicator extends StatefulWidget {
  final WeatherEntity weather;

  const WeatherRiskIndicator({super.key, required this.weather});

  @override
  State<WeatherRiskIndicator> createState() => _WeatherRiskIndicatorState();
}

class _WeatherRiskIndicatorState extends State<WeatherRiskIndicator> {
  final WeatherAdviceService _adviceService = WeatherAdviceService();
  String? _dynamicAdvice;
  bool _adviceLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateAdvice();
    });
  }

  /// OpenAI API를 통해 동적 어드바이스 생성
  Future<void> _generateAdvice() async {
    try {
      debugPrint('🤖 Starting weather advice generation...');

      final advice = await _adviceService
          .generateWalkingAdvice(widget.weather)
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              debugPrint('⏰ Weather advice generation timed out (3s)');
              throw Exception('Timeout');
            },
          );

      debugPrint('✅ Weather advice generated: $advice');

      if (mounted) {
        setState(() {
          _dynamicAdvice = advice;
          _adviceLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Weather advice generation failed: $e');

      if (mounted) {
        setState(() {
          _dynamicAdvice = _getDefaultAdvice();
          _adviceLoading = false;
        });
      }
    }
  }

  /// 기본 어드바이스 반환
  String _getDefaultAdvice() {
    switch (widget.weather.dogRiskLevel) {
      case WBGTRiskLevel.safe:
        return '今日は散歩日和です！楽しくお散歩しましょう🐕';
      case WBGTRiskLevel.caution:
        return '暑さに注意して水分補給を忘れずに散歩してください💧';
      case WBGTRiskLevel.alert:
        return '暑いので涼しい時間帯を選んで散歩しましょう🌤️';
      case WBGTRiskLevel.danger:
        return '熱中症の危険があります、短時間の散歩にしてください⚠️';
      case WBGTRiskLevel.extreme:
        return '非常に危険です、今日の散歩は控えましょう🚫';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildRiskBadge(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildCompactWalkingAdvice()),
      ],
    );
  }

  /// 위험도 뱃지
  Widget _buildRiskBadge() {
    final riskLevel = widget.weather.dogRiskLevel;
    String walkIcon;

    switch (riskLevel) {
      case WBGTRiskLevel.safe:
        walkIcon = 'assets/icons/walk_logo/walk_good.png';
        break;
      case WBGTRiskLevel.caution:
        walkIcon = 'assets/icons/walk_logo/walk_warning.png';
        break;
      case WBGTRiskLevel.alert:
        walkIcon = 'assets/icons/walk_logo/walk_warning.png';
        break;
      case WBGTRiskLevel.danger:
        walkIcon = 'assets/icons/walk_logo/walk_dont.png';
        break;
      case WBGTRiskLevel.extreme:
        walkIcon = 'assets/icons/walk_logo/walk_dont.png';
        break;
    }

    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(walkIcon, fit: BoxFit.contain),
    );
  }

  /// 컴팩트한 산책 어드바이스
  Widget _buildCompactWalkingAdvice() {
    final riskLevel = widget.weather.dogRiskLevel;
    Color recommendationColor;

    switch (riskLevel) {
      case WBGTRiskLevel.safe:
        recommendationColor = AppColors.pointGreen;
        break;
      case WBGTRiskLevel.caution:
        recommendationColor = Colors.yellow[700]!;
        break;
      case WBGTRiskLevel.alert:
        recommendationColor = Colors.orange;
        break;
      case WBGTRiskLevel.danger:
      case WBGTRiskLevel.extreme:
        recommendationColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: recommendationColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(
          color: recommendationColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: _adviceLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      recommendationColor,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '生成中...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: recommendationColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Text(
              _dynamicAdvice ?? widget.weather.dogWalkingRecommendation,
              style: AppTextStyles.bodySmall.copyWith(
                color: recommendationColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }
}
