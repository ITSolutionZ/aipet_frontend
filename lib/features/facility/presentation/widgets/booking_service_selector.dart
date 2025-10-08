import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:aipet_frontend/shared/ui/components/cards/info_card.dart';
import 'package:flutter/material.dart';

/// 🛠️ 예약 서비스 선택 위젯
///
/// 시설에서 제공하는 서비스들을 선택할 수 있는 위젯
class BookingServiceSelector extends StatelessWidget {
  final List<BookingService> services;
  final List<String> selectedServiceIds;
  final ValueChanged<String> onServiceToggle;
  final bool allowMultipleSelection;

  const BookingServiceSelector({
    super.key,
    required this.services,
    required this.selectedServiceIds,
    required this.onServiceToggle,
    this.allowMultipleSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard.basic(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            Row(
              children: [
                const Icon(
                  Icons.room_service,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'サービスを選択してください',
                  style: AppFonts.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (selectedServiceIds.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Text(
                      '${selectedServiceIds.length}個選択',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 서비스 목록
            ...services.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: BookingServiceCard(
                  service: service,
                  isSelected: selectedServiceIds.contains(service.id),
                  onToggle: () => onServiceToggle(service.id),
                ),
              ),
            ),

            // 총 금액 표시
            if (selectedServiceIds.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _buildTotalPrice(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPrice() {
    final selectedServices = services
        .where((service) => selectedServiceIds.contains(service.id))
        .toList();

    final totalPrice = selectedServices.fold<int>(
      0,
      (sum, service) => sum + service.price,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '合計金額',
            style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '¥${totalPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: AppFonts.headlineSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🃏 서비스 카드
class BookingServiceCard extends StatelessWidget {
  final BookingService service;
  final bool isSelected;
  final VoidCallback onToggle;

  const BookingServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.cardBackgroundGray,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 체크박스
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderGray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),

            // 서비스 정보
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: AppFonts.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (service.description != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      service.description!,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${service.durationMinutes}分',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 가격
            Text(
              '¥${service.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: AppFonts.titleMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📋 예약 서비스 데이터 모델
class BookingService {
  final String id;
  final String name;
  final String? description;
  final int price;
  final int durationMinutes;
  final bool isAvailable;

  const BookingService({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.isAvailable = true,
  });
}
