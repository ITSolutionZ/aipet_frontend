import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 Walk Co-Manager Selection State Provider
final walkCoManagerSelectorProvider =
    StateNotifierProvider.family<WalkCoManagerSelectorController, String?, String?>(
      (ref, initialValue) => WalkCoManagerSelectorController(initialValue),
    );

class WalkCoManagerSelectorController extends StateNotifier<String?> {
  WalkCoManagerSelectorController(super.initialValue);

  void selectCoManager(String? managerId) {
    state = managerId;
  }
}

/// 산책 공동 관리자 선택 위젯
class WalkCoManagerSelector extends ConsumerWidget {
  final String? selectedCoManagerId;
  final void Function(String?)? onChanged;

  const WalkCoManagerSelector({super.key, this.selectedCoManagerId, this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(walkCoManagerSelectorProvider(selectedCoManagerId).notifier);
    final selectedId = ref.watch(walkCoManagerSelectorProvider(selectedCoManagerId));

    // TODO: 실제로는 API에서 공동관리자 목록을 가져와야 함
    final coManagers = [
      {'id': 'co1', 'name': '田中さん', 'avatar': '👩'},
      {'id': 'co2', 'name': '佐藤さん', 'avatar': '👨'},
      {'id': 'co3', 'name': '山田さん', 'avatar': '👨‍💼'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '共同管理者（任意）',
          style: AppFonts.point(
            fontSize: AppFonts.lg,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildCoManagerOption(null, '記録者のみ', Icons.person, '自分だけの記録', selectedId, (
                managerId,
              ) {
                controller.selectCoManager(managerId);
                onChanged?.call(managerId);
              }),
              const SizedBox(height: AppSpacing.sm),
              ...coManagers.map(
                (manager) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildCoManagerOption(
                    manager['id'] as String,
                    manager['name'] as String,
                    Icons.people,
                    '${manager['avatar']} 共同管理',
                    selectedId,
                    (managerId) {
                      controller.selectCoManager(managerId);
                      onChanged?.call(managerId);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoManagerOption(
    String? managerId,
    String name,
    IconData icon,
    String description,
    String? selectedCoManagerId,
    Function(String?) onSelect,
  ) {
    final isSelected = selectedCoManagerId == managerId;

    return GestureDetector(
      onTap: () => onSelect(managerId),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pointGreen.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected ? AppColors.pointGreen : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.pointGreen : Colors.grey[200],
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.grey[600]),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.baseSize,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.pointGreen : Colors.grey[800],
                    ),
                  ),
                  Text(
                    description,
                    style: AppFonts.base(fontSize: AppFonts.sm, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.pointGreen, size: 24),
          ],
        ),
      ),
    );
  }
}
