import 'package:flutter/material.dart';

import '../../../../shared/design/design.dart';

/// 산책 핑계 기록 바텀시트
class ExcuseRecordBottomSheet extends StatefulWidget {
  final DateTime date;
  final Function(String excuse)? onSave;

  const ExcuseRecordBottomSheet({super.key, required this.date, this.onSave});

  @override
  State<ExcuseRecordBottomSheet> createState() =>
      _ExcuseRecordBottomSheetState();

  /// 바텀시트 표시 헬퍼 메서드
  static void show(
    BuildContext context, {
    required DateTime date,
    Function(String excuse)? onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExcuseRecordBottomSheet(date: date, onSave: onSave),
    );
  }
}

class _ExcuseRecordBottomSheetState extends State<ExcuseRecordBottomSheet> {
  String? selectedExcuse;

  final List<ExcuseOption> excuseOptions = [
    ExcuseOption(icon: '💊', label: '体調不良', value: 'sick'),
    ExcuseOption(icon: '😴', label: '疲れ', value: 'tired'),
    ExcuseOption(icon: '🥶', label: '寒さ', value: 'cold'),
    ExcuseOption(icon: '☔', label: '雨', value: 'rain'),
    ExcuseOption(icon: '🥵', label: '暑さ', value: 'hot'),
    ExcuseOption(icon: '💼', label: '忙しい', value: 'busy'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: AppColors.pointPink,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 핸들바
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 닫기 버튼
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),

          const SizedBox(height: 20),

          // 제목
          Text(
            '訳あり記録',
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 부제
          Text(
            '散歩に行けなかった理由を教えてください',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),

          const SizedBox(height: 40),

          // 이모지 선택 그리드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.2,
              ),
              itemCount: excuseOptions.length,
              itemBuilder: (context, index) {
                final option = excuseOptions[index];
                final isSelected = selectedExcuse == option.value;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedExcuse = option.value;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(option.icon, style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: 4),
                        Text(
                          option.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? const Color(0xFF5B6EC7)
                                : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Spacer(),

          // 저장 버튼
          if (selectedExcuse != null)
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave?.call(selectedExcuse!);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5B6EC7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '保存',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF5B6EC7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 핑계 옵션 모델
class ExcuseOption {
  final String icon;
  final String label;
  final String value;

  ExcuseOption({required this.icon, required this.label, required this.value});
}
