import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/facility.dart';

class FacilityCard extends StatelessWidget {
  final Facility facility;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const FacilityCard({
    super.key,
    required this.facility,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: _getTypeColor(facility.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(
                _getTypeIcon(facility.type),
                color: _getTypeColor(facility.type),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility.name,
                    style: AppFonts.titleMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    _getTypeName(facility.type),
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onFavoriteToggle,
              icon: Icon(
                Icons.favorite,
                color: facility.isFavorite
                    ? AppColors.pointPink
                    : AppColors.pointGray.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          facility.description,
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.pointDark.withValues(alpha: 0.7),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: AppSpacing.xs),

        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: AppColors.pointGray),
            const SizedBox(width: AppSpacing.xs / 2),
            Expanded(
              child: Text(
                facility.address,
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xs),

        Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: AppSpacing.xs / 2),
            Text(
              facility.rating.toStringAsFixed(1),
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '(${facility.reviewCount}件)',
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            ),
            const Spacer(),
            if (facility.lastVisit != null)
              Row(
                children: [
                  const Icon(
                    Icons.history,
                    size: 14,
                    color: AppColors.pointGray,
                  ),
                  const SizedBox(width: AppSpacing.xs / 2),
                  Text(
                    '最後の訪問',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  IconData _getTypeIcon(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return Icons.medical_services;
      case FacilityType.grooming:
        return Icons.content_cut;
    }
  }

  Color _getTypeColor(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return Colors.red;
      case FacilityType.grooming:
        return Colors.purple;
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
}
