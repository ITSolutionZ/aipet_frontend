import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:aipet_frontend/shared/ui/components/cards/info_card.dart';
import 'package:flutter/material.dart';

/// 🏢 예약 화면용 시설 정보 카드
///
/// 예약하려는 시설의 기본 정보를 표시하는 전용 위젯
class BookingFacilityCard extends StatelessWidget {
  final String facilityId;
  final String facilityName;
  final String facilityAddress;
  final String facilityPhoneNumber;
  final String? facilityImageUrl;

  const BookingFacilityCard({
    super.key,
    required this.facilityId,
    required this.facilityName,
    required this.facilityAddress,
    required this.facilityPhoneNumber,
    this.facilityImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard.basic(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 시설 이미지
              if (facilityImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  child: Image.network(
                    facilityImageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackgroundGray,
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: const Icon(
                        Icons.business,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundGray,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                ),
              const SizedBox(width: AppSpacing.md),

              // 시설 정보
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facilityName,
                      style: AppFonts.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            facilityAddress,
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          facilityPhoneNumber,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
