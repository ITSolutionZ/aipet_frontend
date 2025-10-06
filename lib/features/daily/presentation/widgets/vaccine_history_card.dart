import 'package:aipet_frontend/shared/shared.dart' hide State;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 백신 내역 카드 위젯 (아코디언 형태)
class VaccineHistoryCard extends StatefulWidget {
  final String petName;
  final List<Map<String, dynamic>> scheduledVaccines;
  final List<Map<String, dynamic>> completedVaccines;
  final VoidCallback? onRegister;

  const VaccineHistoryCard({
    super.key,
    required this.petName,
    this.scheduledVaccines = const [],
    this.completedVaccines = const [],
    this.onRegister,
  });

  @override
  State<VaccineHistoryCard> createState() => _VaccineHistoryCardState();
}

class _VaccineHistoryCardState extends State<VaccineHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasAnyVaccines =
        widget.scheduledVaccines.isNotEmpty ||
        widget.completedVaccines.isNotEmpty;
    final totalCount =
        widget.scheduledVaccines.length + widget.completedVaccines.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (클릭 가능)
          InkWell(
            onTap: hasAnyVaccines
                ? () => setState(() => _isExpanded = !_isExpanded)
                : null,
            borderRadius: BorderRadius.circular(AppSpacing.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.vaccines,
                          size: 20,
                          color: hasAnyVaccines
                              ? AppColors.pointBlue
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${widget.petName}のワクチン接種',
                            style: AppFonts.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (hasAnyVaccines) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.pointGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.xs),
                          ),
                          child: Text(
                            '$totalCount件',
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 내용 (접기/펼치기)
          if (_isExpanded && hasAnyVaccines)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.md),

                  // 접종 예정
                  if (widget.scheduledVaccines.isNotEmpty) ...[
                    _buildSectionHeader('接種予定', AppColors.pointOrange),
                    const SizedBox(height: AppSpacing.sm),
                    ...widget.scheduledVaccines.map(
                      (vaccine) =>
                          _buildVaccineItem(vaccine, isScheduled: true),
                    ),
                    if (widget.completedVaccines.isNotEmpty)
                      const SizedBox(height: AppSpacing.md),
                  ],

                  // 접종 완료
                  if (widget.completedVaccines.isNotEmpty) ...[
                    _buildSectionHeader('接種完了', AppColors.pointGreen),
                    const SizedBox(height: AppSpacing.sm),
                    ...widget.completedVaccines.map(
                      (vaccine) =>
                          _buildVaccineItem(vaccine, isScheduled: false),
                    ),
                  ],
                ],
              ),
            ),

          // 백신 기록이 없는 경우
          if (!hasAnyVaccines)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '登録されたワクチン履歴がありません',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (widget.onRegister != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pointBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                        ),
                        child: const Text('登録する'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildVaccineItem(
    Map<String, dynamic> vaccine, {
    required bool isScheduled,
  }) {
    final vaccineName = vaccine['vaccineName'] as String? ?? '不明';
    final nextDueDate = vaccine['nextDueDate'] as DateTime?;
    final vaccinatedDate = vaccine['vaccinatedDate'] as DateTime?;
    final clinic = vaccine['clinic'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isScheduled
            ? AppColors.pointOrange.withOpacity(0.05)
            : AppColors.pointGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(
          color: isScheduled
              ? AppColors.pointOrange.withOpacity(0.2)
              : AppColors.pointGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isScheduled ? Icons.schedule : Icons.check_circle,
                size: 16,
                color: isScheduled
                    ? AppColors.pointOrange
                    : AppColors.pointGreen,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  vaccineName,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (isScheduled && nextDueDate != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '予定日: ${DateFormat('yyyy年MM月dd日').format(nextDueDate)}',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (!isScheduled && vaccinatedDate != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '接種日: ${DateFormat('yyyy年MM月dd日').format(vaccinatedDate)}',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (clinic.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              clinic,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
