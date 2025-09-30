import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class WalkRecordCardWidget extends StatelessWidget {
  final WalkRecordEntity walkRecord;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const WalkRecordCardWidget({super.key, required this.walkRecord, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GenericInfoCard.withAvatar(
      avatarUrl: walkRecord.ownerAvatar,
      placeholderAsset: 'assets/images/placeholder.png',
      placeholderIcon: Icons.person,
      title: walkRecord.title,
      subtitle: walkRecord.fullDateTimeString,
      badge: walkRecord.formattedDuration,
      badgeColor: AppColors.pointBrown,
      trailing: _buildTrailing(),
      onTap: onTap,
      onLongPress: onLongPress,
      showChevron: onTap != null,
    );
  }

  Widget _buildTrailing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.pointBrown.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: const Icon(Icons.directions_walk, size: 16, color: AppColors.pointBrown),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          walkRecord.formattedDistance,
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
