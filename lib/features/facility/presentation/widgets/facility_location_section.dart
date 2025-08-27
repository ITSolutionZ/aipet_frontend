import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/facility.dart';

class FacilityLocationSection extends StatelessWidget {
  final Facility facility;

  const FacilityLocationSection({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '住所',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 주소 정보
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '住所: ${facility.address}',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '市区町村: ${facility.address}',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '国: ${facility.address}',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // 지도 (플레이스홀더)
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Stack(
            children: [
              // 지도 배경
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Center(
                  child: Icon(Icons.map, size: 48, color: Colors.grey[400]),
                ),
              ),

              // 위치 핀
              Positioned(
                top: 50,
                left: 50,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    facility.type == FacilityType.grooming
                        ? Icons.content_cut
                        : Icons.local_hospital,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              // 전체화면 버튼
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.open_in_full,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
