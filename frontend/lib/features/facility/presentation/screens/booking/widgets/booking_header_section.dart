import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';

/// 予約画面のヘッダーセクション
/// 施設名と施設タイプを表示
class BookingHeaderSection extends StatelessWidget {
  final String facilityName;
  final String facilityType;

  const BookingHeaderSection({
    super.key,
    required this.facilityName,
    required this.facilityType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _getFacilityIcon(facilityType),
                  color: AppColors.pointGreen,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facilityName,
                        style: AppFonts.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        facilityType,
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 施設タイプに応じたアイコンを取得
  IconData _getFacilityIcon(String type) {
    switch (type) {
      case '美容室':
      case '미용실':
        return Icons.content_cut;
      case 'カフェ':
      case '카페':
        return Icons.local_cafe;
      case 'ホテル':
      case '호텔':
        return Icons.hotel;
      case '遊び場':
      case '놀이터':
        return Icons.park;
      case '教育センター':
      case '교육센터':
        return Icons.school;
      default:
        return Icons.place;
    }
  }
}
