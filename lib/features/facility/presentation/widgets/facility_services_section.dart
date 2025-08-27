import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/facility.dart';

class FacilityServicesSection extends StatelessWidget {
  final Facility facility;

  const FacilityServicesSection({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    // 더미 서비스 데이터
    final services = [
      {'name': 'カット', 'price': '\$30'},
      {'name': 'バス', 'price': '\$20'},
      {'name': '爪切り', 'price': '\$20'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'サービス',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 서비스 목록
        Column(
          children: services.map((service) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      service['name']!,
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    service['price']!,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
