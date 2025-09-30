import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:aipet_frontend/shared/ui/components/cards/info_card.dart';
import 'package:flutter/material.dart';

class FacilityCard extends StatelessWidget {
  final Facility facility;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const FacilityCard({super.key, required this.facility, this.onTap, this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: InfoCard.basic(child: _buildContent(context)),
      ),
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
                    style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
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
          facility.description ?? '',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark.withValues(alpha: 0.7)),
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
                  const Icon(Icons.history, size: 14, color: AppColors.pointGray),
                  const SizedBox(width: AppSpacing.xs / 2),
                  Text('最後の訪問', style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray)),
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
      case FacilityType.veterinary:
        return Icons.medical_services;
      case FacilityType.grooming:
        return Icons.content_cut;
      case FacilityType.petShop:
        return Icons.shopping_bag;
      case FacilityType.petStore:
        return Icons.store;
      case FacilityType.dogRun:
        return Icons.directions_run;
      case FacilityType.park:
        return Icons.park;
      case FacilityType.petPark:
        return Icons.pets;
      case FacilityType.cafe:
        return Icons.local_cafe;
      case FacilityType.hotel:
        return Icons.hotel;
      case FacilityType.petFriendlyAccommodation:
        return Icons.home;
      case FacilityType.training:
        return Icons.school;
      case FacilityType.other:
        return Icons.place;
    }
  }

  Color _getTypeColor(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return Colors.red;
      case FacilityType.veterinary:
        return Colors.red;
      case FacilityType.grooming:
        return Colors.purple;
      case FacilityType.petShop:
        return Colors.orange;
      case FacilityType.petStore:
        return Colors.orange;
      case FacilityType.dogRun:
        return Colors.green;
      case FacilityType.park:
        return Colors.lightGreen;
      case FacilityType.petPark:
        return Colors.lightGreen;
      case FacilityType.cafe:
        return Colors.brown;
      case FacilityType.hotel:
        return Colors.blue;
      case FacilityType.petFriendlyAccommodation:
        return Colors.blue;
      case FacilityType.training:
        return Colors.indigo;
      case FacilityType.other:
        return Colors.grey;
    }
  }

  String _getTypeName(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return '動物病院';
      case FacilityType.veterinary:
        return '獣医院';
      case FacilityType.grooming:
        return 'トリミング';
      case FacilityType.petShop:
        return 'ペットショップ';
      case FacilityType.petStore:
        return 'ペット用品店';
      case FacilityType.dogRun:
        return 'ドッグラン';
      case FacilityType.park:
        return '公園';
      case FacilityType.petPark:
        return 'ペット公園';
      case FacilityType.cafe:
        return 'ペットカフェ';
      case FacilityType.hotel:
        return 'ペットホテル';
      case FacilityType.petFriendlyAccommodation:
        return 'ペット可宿泊施設';
      case FacilityType.training:
        return '訓練所';
      case FacilityType.other:
        return 'その他';
    }
  }
}
