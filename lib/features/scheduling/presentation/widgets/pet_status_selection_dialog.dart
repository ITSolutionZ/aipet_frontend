import 'package:aipet_frontend/shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pet_status_selection_dialog.g.dart';

/// 🎯 Pet Status Selection State
class PetStatusSelectionState {
  final List<String> selectedStatuses;
  final Map<String, String> statusValues;

  const PetStatusSelectionState({
    this.selectedStatuses = const [],
    this.statusValues = const {},
  });

  PetStatusSelectionState copyWith({
    List<String>? selectedStatuses,
    Map<String, String>? statusValues,
  }) {
    return PetStatusSelectionState(
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
      statusValues: statusValues ?? this.statusValues,
    );
  }
}

/// 🎯 Pet Status Selection Provider
@riverpod
class PetStatusSelection extends _$PetStatusSelection {
  @override
  PetStatusSelectionState build(String dialogId) {
    return const PetStatusSelectionState();
  }

  void initialize(List<String> selectedStatuses, Map<String, String> statusValues) {
    state = state.copyWith(
      selectedStatuses: selectedStatuses,
      statusValues: statusValues,
    );
  }

  void toggleStatus(String status) {
    final selectedStatuses = List<String>.from(state.selectedStatuses);
    if (selectedStatuses.contains(status)) {
      selectedStatuses.remove(status);
    } else {
      selectedStatuses.add(status);
    }
    state = state.copyWith(selectedStatuses: selectedStatuses);
  }

  void updateStatusValue(String status, String value) {
    final statusValues = Map<String, String>.from(state.statusValues);
    statusValues[status] = value;
    state = state.copyWith(statusValues: statusValues);
  }
}

/// 펫 상태 선택 다이얼로그
class PetStatusSelectionDialog extends ConsumerWidget {
  final Map<String, dynamic> petInfo;
  final List<String> selectedStatuses;
  final Map<String, String> statusValues;
  final List<Map<String, dynamic>> statusOptions;
  final Function(List<String>, Map<String, String>) onStatusUpdated;

  const PetStatusSelectionDialog({
    super.key,
    required this.petInfo,
    required this.selectedStatuses,
    required this.statusValues,
    required this.statusOptions,
    required this.onStatusUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PetStatusSelectionDialogContent(
      petInfo: petInfo,
      selectedStatuses: selectedStatuses,
      statusValues: statusValues,
      statusOptions: statusOptions,
      onStatusUpdated: onStatusUpdated,
    );
  }
}

class _PetStatusSelectionDialogContent extends ConsumerStatefulWidget {
  final Map<String, dynamic> petInfo;
  final List<String> selectedStatuses;
  final Map<String, String> statusValues;
  final List<Map<String, dynamic>> statusOptions;
  final Function(List<String>, Map<String, String>) onStatusUpdated;

  const _PetStatusSelectionDialogContent({
    required this.petInfo,
    required this.selectedStatuses,
    required this.statusValues,
    required this.statusOptions,
    required this.onStatusUpdated,
  });

  @override
  ConsumerState<_PetStatusSelectionDialogContent> createState() =>
      _PetStatusSelectionDialogContentState();
}

class _PetStatusSelectionDialogContentState
    extends ConsumerState<_PetStatusSelectionDialogContent> {
  final String _dialogId = 'pet_status_selection';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(petStatusSelectionProvider(_dialogId).notifier)
          .initialize(widget.selectedStatuses, widget.statusValues);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(petStatusSelectionProvider(_dialogId));
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                CircleAvatar(radius: 25, backgroundImage: AssetImage(widget.petInfo['imagePath'])),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.petInfo['name']} 状態管理 (最大2つまで選択できます)',
                        style: AppFonts.titleMedium.copyWith(
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // 상태 옵션들
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.statusOptions.map((statusOption) {
                    final isSelected = state.selectedStatuses.contains(statusOption['id']);

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ExpansionTile(
                        leading: Icon(
                          statusOption['icon'],
                          color: isSelected ? AppColors.pointBrown : AppColors.pointGray,
                        ),
                        title: Text(
                          statusOption['title'],
                          style: AppFonts.titleSmall.copyWith(
                            color: isSelected ? AppColors.pointDark : AppColors.pointDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          statusOption['description'],
                          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.pointGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.small),
                                ),
                                child: Text(
                                  '選択済み',
                                  style: AppFonts.bodySmall.copyWith(
                                    color: AppColors.pointGreen,
                                    fontSize: AppFonts.xs,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(width: AppSpacing.xs),
                            InkWell(
                              onTap: () {
                                if (!isSelected && state.selectedStatuses.length >= 2) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('最大2つまで選択できます'),
                                      backgroundColor: AppColors.pointBrown,
                                    ),
                                  );
                                  return;
                                }

                                // 상태 토글 로직은 상위 위젯에서 처리
                                widget.onStatusUpdated(
                                  widget.selectedStatuses,
                                  widget.statusValues,
                                );
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppColors.pointBrown : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? AppColors.pointBrown : AppColors.pointGray,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: state.statusValues[statusOption['id']],
                                    decoration: InputDecoration(
                                      labelText: '状態選択',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppRadius.medium),
                                      ),
                                    ),
                                    items: (statusOption['options'] as List<String>).map((option) {
                                      return DropdownMenuItem<String>(
                                        value: option,
                                        child: Text(option),
                                      );
                                    }).toList(),
                                    onChanged: (String? value) {
                                      if (value != null) {
                                        // 상태 값 업데이트는 상위 위젯에서 처리
                                        widget.onStatusUpdated(
                                          widget.selectedStatuses,
                                          widget.statusValues,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      '戻る',
                      style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onStatusUpdated(state.selectedStatuses, state.statusValues);
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBrown,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      '保存',
                      style: AppFonts.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
