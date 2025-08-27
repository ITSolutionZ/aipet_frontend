import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/facility.dart';

class FacilityDetailHeader extends StatelessWidget {
  final Facility facility;

  const FacilityDetailHeader({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 배경 이미지
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(facility.imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.3),
                BlendMode.darken,
              ),
            ),
          ),
        ),

        // 그라데이션 오버레이
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
            ),
          ),
        ),

        // 시설 정보 카드
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 시설 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: AppFonts.fredoka(
                          fontSize: AppFonts.xl,
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        facility.type == FacilityType.grooming
                            ? 'トリミング'
                            : '動物病院',
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.pointGray,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Text(
                            '${facility.rating}',
                            style: AppFonts.bodyMedium.copyWith(
                              color: AppColors.pointDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          // 별점
                          Row(
                            children: List.generate(5, (index) {
                              if (index < facility.rating.floor()) {
                                return const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              } else if (index == facility.rating.floor() &&
                                  facility.rating % 1 > 0) {
                                return const Icon(
                                  Icons.star_half,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              } else {
                                return const Icon(
                                  Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }
                            }),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${facility.reviewCount} レビュー',
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 시설 아이콘
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    facility.type == FacilityType.grooming
                        ? Icons.content_cut
                        : Icons.local_hospital,
                    color: Colors.purple,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
