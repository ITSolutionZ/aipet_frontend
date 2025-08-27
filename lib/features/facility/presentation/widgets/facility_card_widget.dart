import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/facility.dart';

class FacilityCardWidget extends StatelessWidget {
  final Facility facility;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onNavigate;

  const FacilityCardWidget({
    super.key,
    required this.facility,
    required this.onTap,
    required this.onCall,
    required this.onNavigate,
  });

  Color _getTypeColor(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return AppColors.pointBrown;
      case FacilityType.grooming:
        return AppColors.pointBlue;
    }
  }

  IconData _getTypeIcon(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return Icons.local_hospital;
      case FacilityType.grooming:
        return Icons.content_cut;
    }
  }

  String _getTypeName(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return '動物病院';
      case FacilityType.grooming:
        return 'トリミング';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (시설명, 타입, 영업상태)
          _buildHeader(),
          const SizedBox(height: AppSpacing.sm),

          // 주소
          _buildAddress(),
          const SizedBox(height: AppSpacing.sm),

          // 평점과 거리
          _buildRatingAndDistance(),
          const SizedBox(height: AppSpacing.md),

          // 액션 버튼들
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // 시설 아이콘
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTypeColor(facility.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            _getTypeIcon(facility.type),
            color: _getTypeColor(facility.type),
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // 시설 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                facility.name,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Text(
                    _getTypeName(facility.type),
                    style: AppFonts.bodySmall.copyWith(
                      color: _getTypeColor(facility.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pointGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '営業中',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddress() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: AppColors.pointGray, size: 16),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            facility.address,
            style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingAndDistance() {
    return Row(
      children: [
        // 평점
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${facility.rating} (${facility.reviewCount})',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '(${facility.reviewCount})',
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            ),
          ],
        ),
        const Spacer(),
        // 거리
        Row(
          children: [
            const Icon(
              Icons.directions_walk,
              color: AppColors.pointBrown,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '0.5km',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // 전화 버튼
        if (facility.phone.isNotEmpty) ...[
          Expanded(
            child: PointOutlinedButton(
              label: '電話',
              onPressed: onCall,
              leading: const Icon(Icons.phone, size: 16),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],

        // 길찾기 버튼
        Expanded(
          child: PointButton.icon(
            label: '地図',
            onPressed: onNavigate,
            icon: const Icon(Icons.directions, size: 16),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          ),
        ),
      ],
    );
  }
}
