import 'dart:convert';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
// ✅ Removed SharedPreferences

/// 급여 기록 섹션
class FeedingRecordsSection extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const FeedingRecordsSection({super.key, required this.analysisData});

  @override
  Widget build(BuildContext context) {
    final recentRecords =
        analysisData['recentRecords'] as List<Map<String, dynamic>>;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近の食事記録',
                style: AppFonts.fredoka(
                  fontSize: AppFonts.xl,
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => _showAddFeedingDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pointBrown,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '追加',
                        style: AppFonts.fredoka(
                          fontSize: AppFonts.sm,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...recentRecords.map(
            (record) => FeedingRecordItem(
              amount: record['amount'],
              date: record['date'],
              change: record['change'],
            ),
          ),
        ],
      ),
    );
  }

  /// 급여 기록 추가 다이얼로그 표시
  void _showAddFeedingDialog(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '食事記録追加',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 날짜 선택
                  ListTile(
                    title: Text(
                      '날짜',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}',
                      style: AppFonts.bodyMedium,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // 급여량 입력
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '食事量 (g)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // 메모 입력
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: '메모',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                amountController.dispose();
                noteController.dispose();
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.isNotEmpty) {
                  // 로컬 데이터로 저장
                  final cache = CacheService(); await cache.initialize();

                  final feedingRecord = {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'amount': '${amountController.text}g',
                    'date':
                        '${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}',
                    'note': noteController.text,
                    'timestamp': selectedDate.toIso8601String(),
                    'change': '+0g', // 변화량은 별도 계산 로직 필요
                  };

                  final records = await cache.getPersistentCacheList('feeding_records') ?? [];
                  records.add(jsonEncode(feedingRecord));
                  await await cache.setPersistentCacheList('feeding_records', records);

                  SnackBarService.showSuccess(context, '食事記録が追加されました。');
                  amountController.dispose();
                  noteController.dispose();
                  Navigator.of(context).pop();
                } else {
                  SnackBarService.showError(context, '食事量を入力してください。');
                }
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }
}

/// 급여 기록 아이템 위젯
class FeedingRecordItem extends StatelessWidget {
  final String amount;
  final String date;
  final String change;

  const FeedingRecordItem({
    super.key,
    required this.amount,
    required this.date,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change.startsWith('+');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.restaurant,
              color: AppColors.pointBrown,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.pointDark,
                  ),
                ),
                Text(
                  date,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            change,
            style: AppFonts.bodySmall.copyWith(
              color: isPositive ? AppColors.pointGreen : AppColors.pointBrown,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
