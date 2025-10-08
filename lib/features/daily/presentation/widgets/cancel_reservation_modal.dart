import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CancelReservationModal extends ConsumerStatefulWidget {
  final String reservationId;
  final String facilityName;
  final Function(String reason, String detail)? onCancelConfirmed;

  const CancelReservationModal({
    super.key,
    required this.reservationId,
    required this.facilityName,
    this.onCancelConfirmed,
  });

  @override
  ConsumerState<CancelReservationModal> createState() =>
      _CancelReservationModalState();
}

class _CancelReservationModalState
    extends ConsumerState<CancelReservationModal> {
  final TextEditingController _reasonController = TextEditingController();
  String _selectedReason = '';
  final List<String> _predefinedReasons = [
    '일정 변경',
    '개인 사정',
    '시설 문제',
    '서비스 불만',
    '기타',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                const Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '예약 취소',
                    style: AppFonts.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${widget.facilityName} 예약을 취소하시겠습니까?',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 취소 사유 선택
            Text(
              '취소 사유를 선택해주세요',
              style: AppFonts.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _predefinedReasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedReason = reason;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.pointRed
                          : AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(AppSpacing.lg),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.pointRed
                            : AppColors.toneLightGray,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      reason,
                      style: AppFonts.bodySmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 상세 사유 입력
            Text(
              '상세 사유 (선택)',
              style: AppFonts.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '취소 사유를 자세히 입력해주세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  borderSide: const BorderSide(color: AppColors.pointRed),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.toneLightGray),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedReason.isEmpty ? null : _confirmCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                    ),
                    child: const Text('예약 취소'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel() {
    if (_selectedReason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('취소 사유를 선택해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // TODO: 실제 예약 취소 로직 구현
    // 1. 로컬 데이터에서 예약 상태를 'cancelled'로 변경
    // 2. 취소 사유와 상세 사유 저장
    // 3. 서버에 취소 요청 전송 (추후 구현)

    // 성공 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.facilityName} 예약이 취소되었습니다'),
        backgroundColor: AppColors.pointRed,
        duration: const Duration(seconds: 2),
      ),
    );

    // 모달 닫기
    Navigator.of(context).pop();

    // 콜백 실행 (취소 사유와 상세 사유 전달)
    widget.onCancelConfirmed?.call(
      _selectedReason,
      _reasonController.text.trim(),
    );
  }
}
