import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class MicrochipCard extends StatelessWidget {
  final PetProfileEntity pet;
  final bool isEditMode;
  final TextEditingController? microchipController;

  const MicrochipCard({
    super.key,
    required this.pet,
    this.isEditMode = false,
    this.microchipController,
  });

  @override
  Widget build(BuildContext context) {
    final microchipId = isEditMode
        ? microchipController?.text ?? ''
        : pet.additionalInfo?['microchipId'] ?? '';

    return Container(
      padding: const const const EdgeInsets.all(AppSpacing.md),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pointGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.memory,
              color: AppColors.pointGreen,
              size: 20,
            ),
          ),
          const const const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'マイクロチップ番号',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
                const const const SizedBox(height: AppSpacing.xs),
                if (isEditMode && microchipController != null)
                  TextField(
                    controller: microchipController,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'マイクロチップ番号を入力',
                      isDense: true,
                      contentPadding: const const const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                    ),
                  )
                else
                  Text(
                    microchipId.isEmpty ? '未登録' : microchipId,
                    style: AppFonts.bodyMedium.copyWith(
                      color: microchipId.isEmpty
                          ? AppColors.pointGray
                          : AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
