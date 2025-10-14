import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 병원 관리 화면 액션 버튼들
class HospitalActionButtons extends StatelessWidget {
  final VoidCallback onEmergencyContacts;

  const HospitalActionButtons({super.key, required this.onEmergencyContacts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 동물병원 찾기 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/home/hospital-list');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
            icon: const Icon(Icons.search),
            label: Text(
              '動物病院 を探す',
              style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // 긴급 연락처 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onEmergencyContacts,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.pointRed,
              side: const BorderSide(color: AppColors.pointRed),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
            icon: const Icon(Icons.emergency),
            label: Text(
              '緊急連絡先',
              style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
