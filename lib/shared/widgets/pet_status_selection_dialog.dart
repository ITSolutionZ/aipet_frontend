import 'package:flutter/material.dart';

import '../design/color.dart';
import '../design/font.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../mock_data/mock_data_service.dart';

/// 펫 상태 선택 다이얼로그
class PetStatusSelectionDialog extends StatefulWidget {
  final Map<String, dynamic> petInfo;
  final List<String> selectedStatuses;
  final Map<String, String> statusValues;
  final Function(List<String>, Map<String, String>) onStatusUpdated;

  const PetStatusSelectionDialog({
    super.key,
    required this.petInfo,
    required this.selectedStatuses,
    required this.statusValues,
    required this.onStatusUpdated,
  });

  @override
  State<PetStatusSelectionDialog> createState() =>
      _PetStatusSelectionDialogState();
}

class _PetStatusSelectionDialogState extends State<PetStatusSelectionDialog> {
  late List<String> _selectedStatuses;
  late Map<String, String> _statusValues;

  @override
  void initState() {
    super.initState();
    _selectedStatuses = List<String>.from(widget.selectedStatuses);
    _statusValues = Map<String, String>.from(widget.statusValues);
  }

  @override
  Widget build(BuildContext context) {
    final statusOptions = MockDataService.getPetStatusOptions();

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
                CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(widget.petInfo['imagePath']),
                ),
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
                  children: statusOptions.map((statusOption) {
                    final isSelected = _selectedStatuses.contains(
                      statusOption['id'],
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ExpansionTile(
                        leading: Icon(
                          statusOption['icon'],
                          color: isSelected
                              ? AppColors.pointBrown
                              : AppColors.pointGray,
                        ),
                        title: Text(
                          statusOption['title'],
                          style: AppFonts.titleSmall.copyWith(
                            color: isSelected
                                ? AppColors.pointDark
                                : AppColors.pointDark,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          statusOption['description'],
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.pointGray,
                          ),
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
                                  color: AppColors.pointGreen.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.small,
                                  ),
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
                                if (!isSelected &&
                                    _selectedStatuses.length >= 2) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('最大2つまで選択できます'),
                                      backgroundColor: AppColors.pointBrown,
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  if (isSelected) {
                                    _selectedStatuses.remove(
                                      statusOption['id'],
                                    );
                                    _statusValues.remove(statusOption['id']);
                                  } else {
                                    _selectedStatuses.add(statusOption['id']);
                                  }
                                });
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.pointBrown
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.pointBrown
                                        : AppColors.pointGray,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
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
                                    value: _statusValues[statusOption['id']],
                                    decoration: InputDecoration(
                                      labelText: '状態選択',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.medium,
                                        ),
                                      ),
                                    ),
                                    items:
                                        (statusOption['options']
                                                as List<String>)
                                            .map((option) {
                                              return DropdownMenuItem<String>(
                                                value: option,
                                                child: Text(option),
                                              );
                                            })
                                            .toList(),
                                    onChanged: (String? value) {
                                      if (value != null) {
                                        setState(() {
                                          _statusValues[statusOption['id']] =
                                              value;
                                        });
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '戻る',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onStatusUpdated(_selectedStatuses, _statusValues);
                      Navigator.of(context).pop();
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
