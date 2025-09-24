import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/viewmodels/weather_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'meteocons_icon.dart';

/// 🎯 날씨 카드 (리팩토링됨)
///
/// 순수 UI 위젯으로 단순화, 비즈니스 로직은 ViewModel로 분리
class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(weatherViewModelProvider);

    return GestureDetector(
      onTap: viewModel.isLoading
          ? null
          : () {
              debugPrint('👆 Weather Card 탭됨 - 새로고침 시작');
              ref.read(weatherViewModelProvider).refresh();
            },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // 왼쪽: 온도와 위치 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        viewModel.getTemperatureText(),
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.pointBlue,
                        ),
                      ),
                      const MeteoconsIcon(name: 'celsius', size: 36),
                      const const const SizedBox(width: 6),
                      // UV 지수 표시 (아이콘만)
                      MeteoconsIcon(
                        name: viewModel.isLoading
                            ? 'uv-index'
                            : viewModel.getUvIndexIcon(),
                        size: 36,
                      ),
                      const const const SizedBox(width: 6),
                      // 풍속 표시 (Beaufort 스케일 아이콘)
                      MeteoconsIcon(
                        name: viewModel.isLoading
                            ? 'wind-beaufort-0'
                            : viewModel.getWindIcon(),
                        size: 36,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    viewModel.getLocationText(),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    viewModel.getStatusText(),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.pointGray,
                      fontSize: 13,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),

            // 오른쪽: 날씨 아이콘
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.pointOffWhite.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(45),
              ),
              child: Center(
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.pointBlue,
                        ),
                      )
                    : MeteoconsIcon(
                        name: viewModel.iconName ?? 'clear-day',
                        size: 70,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
