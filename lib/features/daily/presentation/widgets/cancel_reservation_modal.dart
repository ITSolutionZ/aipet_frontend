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
    'スケジュール変更',
    '個人的な事情',
    '施設の問題',
    'サービスへの不満',
    'その他',
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
                    '予約キャンセル',
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
              '${widget.facilityName}の予約をキャンセルしますか？',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 취소 사유 선택
            Text(
              'キャンセル理由を選択してください',
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
              '詳細理由（任意）',
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
                hintText: 'キャンセル理由を詳しく入力してください',
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
                    child: const Text('閉じる'),
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
                    child: const Text('予約キャンセル'),
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
      // ✅ Shared SnackBarService 사용
      SnackBarService.showWarning(context, 'キャンセル理由を選択してください');
      return;
    }

    // 실제 예약 취소 로직
    // 1. 로컬 데이터에서 예약 상태를 'cancelled'로 변경
    // 2. 취소 사유와 상세 사유 저장
    // 3. 서버에 취소 요청 전송 (추후 API 연동 시 구현)

    // 성공 메시지 표시
    // ✅ Shared SnackBarService 사용
    SnackBarService.showWarning(
      context,
      '${widget.facilityName}の予約がキャンセルされました',
      duration: const Duration(seconds: 2),
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
