import 'package:flutter/material.dart';

import '../../../../shared/design/design.dart';
import '../../../../shared/testing/mock_data/features/pet_health/pet_health_mock_service.dart';

class WeightRecordsCard extends StatefulWidget {
  const WeightRecordsCard({super.key});

  @override
  State<WeightRecordsCard> createState() => _WeightRecordsCardState();
}

class _WeightRecordsCardState extends State<WeightRecordsCard> {
  final Set<String> _expandedMonths = <String>{};
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final weightRecords = PetHealthMockService.getMockWeightRecords();
    final availableYears = _getAvailableYears(weightRecords);
    final filteredRecords = weightRecords
        .where(
          (record) =>
              (record['recordedDate'] as DateTime).year == _selectedYear,
        )
        .toList();
    final groupedRecords = _groupRecordsByMonth(filteredRecords);

    // 첫 번째(최신) 월을 기본으로 열어놓기
    if (_expandedMonths.isEmpty && groupedRecords.isNotEmpty) {
      _expandedMonths.add(groupedRecords.keys.first);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.pointBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppColors.pointBrown,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '体重記録',
                style: AppFonts.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // 년도 선택 칩
          if (availableYears.length > 1) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: availableYears.map((year) {
                  final isSelected = year == _selectedYear;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text('$year年'),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedYear = year;
                            _expandedMonths.clear(); // 년도 변경시 펼쳐진 월 초기화
                          });
                        }
                      },
                      selectedColor: AppColors.pointBrown.withValues(
                        alpha: 0.2,
                      ),
                      checkmarkColor: AppColors.pointBrown,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.pointBrown
                            : AppColors.pointGray,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          // 월별 아코디언
          Column(
            children: groupedRecords.entries.map((entry) {
              final monthKey = entry.key;
              final monthRecords = entry.value;
              final isExpanded = _expandedMonths.contains(monthKey);

              return _buildMonthAccordion(monthKey, monthRecords, isExpanded);
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<int> _getAvailableYears(List<dynamic> records) {
    final Set<int> years = {};
    for (final record in records) {
      years.add((record['recordedDate'] as DateTime).year);
    }
    final yearsList = years.toList()..sort((a, b) => b.compareTo(a)); // 최신년도부터
    return yearsList;
  }

  Map<String, List<dynamic>> _groupRecordsByMonth(List<dynamic> records) {
    final Map<String, List<dynamic>> grouped = {};

    for (final record in records) {
      final date = record['recordedDate'] as DateTime;
      final monthKey = '${date.year}年 ${date.month}月';

      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(record);
    }

    // 월별로 정렬 (최신 월부터)
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        final aDate = DateTime(
          int.parse(a.key.split('年')[0]),
          int.parse(a.key.split(' ')[1].split('月')[0]),
        );
        final bDate = DateTime(
          int.parse(b.key.split('年')[0]),
          int.parse(b.key.split(' ')[1].split('月')[0]),
        );
        return bDate.compareTo(aDate);
      });

    return Map.fromEntries(sortedEntries);
  }

  Widget _buildMonthAccordion(
    String monthKey,
    List<dynamic> monthRecords,
    bool isExpanded,
  ) {
    final recordCount = monthRecords.length;
    final avgWeight =
        monthRecords.map((r) => r.weight as double).reduce((a, b) => a + b) /
        recordCount;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedMonths.remove(monthKey);
                } else {
                  _expandedMonths.add(monthKey);
                }
              });
            },
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
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
                      Icons.calendar_month,
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
                          monthKey,
                          style: AppFonts.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.pointDark,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '$recordCount件の記録 • 平均 ${avgWeight.toStringAsFixed(1)}kg',
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.pointGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.pointGray,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.pointGray),
            ...monthRecords.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              return _buildWeightRecordItem(record, index, monthRecords);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildWeightRecordItem(
    dynamic record,
    int index,
    List<dynamic> weightRecords,
  ) {
    final isLatest = index == 0;
    final change = index < weightRecords.length - 1
        ? (record['weight'] as double) -
              (weightRecords[index + 1]['weight'] as double)
        : 0.0;
    final changeText = change > 0
        ? '+${change.toStringAsFixed(1)}kg'
        : '${change.toStringAsFixed(1)}kg';
    final changeColor = change > 0
        ? AppColors.pointGreen
        : change < 0
        ? AppColors.pointPink
        : AppColors.pointGray;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.pointGray.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLatest
                  ? AppColors.pointGreen.withValues(alpha: 0.1)
                  : AppColors.pointGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.monitor_weight,
              color: isLatest ? AppColors.pointGreen : AppColors.pointGray,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record['weight']}kg',
                  style: AppFonts.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatDate(record['recordedDate'] as DateTime),
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
                if (record['notes'] != null &&
                    (record['notes'] as String).isNotEmpty)
                  Text(
                    record['notes'] as String,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
              ],
            ),
          ),
          if (index < weightRecords.length - 1)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: changeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                changeText,
                style: AppFonts.bodySmall.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
