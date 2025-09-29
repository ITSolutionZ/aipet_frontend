import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';

import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'facility_google_map_widget.dart';

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

        // Google Maps 지도
        FacilityGoogleMapWidget(
          facility: facility,
          onMapTap: () {
            // 전체화면 지도로 이동
            context.pushNamed(
              'facility-fullscreen-map',
              queryParameters: {'facilityId': facility.id},
            );
          },
          onFacilityTap: (selectedFacility) {
            // 선택된 시설 상세 화면으로 이동
            context.pushNamed(
              'facility-detail',
              queryParameters: {'facilityId': selectedFacility.id},
            );
          },
        ),
      ],
    );
  }
}
