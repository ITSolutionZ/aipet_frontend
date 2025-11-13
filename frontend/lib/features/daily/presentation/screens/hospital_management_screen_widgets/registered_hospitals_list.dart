import 'package:aipet_frontend/features/daily/data/providers/hospital_registration_provider.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hospital_state_widgets.dart';

/// 등록된 병원 목록 위젯
class RegisteredHospitalsList extends ConsumerWidget {
  final Function(String action, RegisteredHospital hospital) onHospitalAction;
  final VoidCallback onAddHospital;

  const RegisteredHospitalsList({
    super.key,
    required this.onHospitalAction,
    required this.onAddHospital,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.list_alt,
                    color: AppColors.pointGreen,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '登録済み病院',
                    style: AppFonts.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onAddHospital,
                icon: const Icon(Icons.add_circle, color: AppColors.pointGreen),
                tooltip: '病院追加',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Consumer(
            builder: (context, ref, child) {
              final hospitalsAsync = ref.watch(registeredHospitalsProvider);

              return hospitalsAsync.when(
                data: (hospitals) {
                  if (hospitals.isEmpty) {
                    return const HospitalEmptyState();
                  }
                  return _buildHospitalsList(hospitals);
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) =>
                    HospitalErrorState(error: error.toString()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalsList(List<RegisteredHospital> hospitals) {
    return Column(
      children: hospitals.map((hospital) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.pointGreen.withValues(alpha: 0.1),
              child: const Icon(
                Icons.local_hospital,
                color: AppColors.pointGreen,
                size: 20,
              ),
            ),
            title: Text(
              hospital.name,
              style: AppFonts.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital.address, style: AppFonts.bodySmall),
                Text(
                  hospital.phoneNumber,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointBlue,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 20),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'call',
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 16),
                      SizedBox(width: AppSpacing.xs),
                      Text('電話'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle, size: 16, color: Colors.red),
                      SizedBox(width: AppSpacing.xs),
                      Text('削除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) =>
                  onHospitalAction(value.toString(), hospital),
            ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }
}
