import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 급수 기록 화면
class WateringRecordsScreen extends ConsumerStatefulWidget {
  const WateringRecordsScreen({super.key});

  @override
  ConsumerState<WateringRecordsScreen> createState() => _WateringRecordsScreenState();
}

class _WateringRecordsScreenState extends ConsumerState<WateringRecordsScreen> {
  List<Map<String, dynamic>>? _wateringRecords;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    setState(() {
      // 급수 기록 Mock 데이터
      _wateringRecords = [
        {
          'date': '2024-01-15',
          'time': '08:30',
          'amount': '200ml',
          'type': '定期的な給水',
          'notes': 'いつも通り完食',
        },
        {
          'date': '2024-01-15',
          'time': '14:15',
          'amount': '150ml',
          'type': '定期的な給水',
          'notes': '少し残した',
        },
        {'date': '2024-01-15', 'time': '20:00', 'amount': '180ml', 'type': '定期的な給水', 'notes': '完食'},
        {'date': '2024-01-14', 'time': '08:00', 'amount': '200ml', 'type': '定期的な給水', 'notes': '完食'},
        {'date': '2024-01-14', 'time': '14:00', 'amount': '150ml', 'type': '定期的な給水', 'notes': '完食'},
        {'date': '2024-01-14', 'time': '20:30', 'amount': '180ml', 'type': '定期的な給水', 'notes': '完食'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(title: '給水記録'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 통계 카드
            _buildStatsCard(),
            const SizedBox(height: AppSpacing.lg),

            // 기록 목록
            Text(
              '給水履歴',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _wateringRecords != null
                  ? ListView.builder(
                      itemCount: _wateringRecords!.length,
                      itemBuilder: (context, index) {
                        final record = _wateringRecords![index];
                        return _buildRecordItemWidget(record);
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('add-watering-record');
        },
        backgroundColor: AppColors.pointBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 통계 카드
  Widget _buildStatsCard() {
    final todayRecords =
        _wateringRecords?.where((record) => record['date'] == '2024-01-15').toList() ?? [];

    final totalAmount = todayRecords.fold<int>(
      0,
      (sum, record) => sum + int.parse(record['amount'].toString().replaceAll('ml', '')),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                '今日の給水回数',
                '${todayRecords.length}回',
                Icons.water_drop,
                AppColors.pointBlue,
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.pointGray.withValues(alpha: 0.3)),
            Expanded(
              child: _buildStatItem(
                '今日の総摂取量',
                '${totalAmount}ml',
                Icons.analytics,
                AppColors.pointGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 아이템
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        Text(
          label,
          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 기록 아이템 위젯
  Widget _buildRecordItemWidget(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.water_drop, color: AppColors.pointBlue, size: 20),
        ),
        title: Text(
          '${record['date']} ${record['time']}',
          style: AppFonts.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.pointDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${record['amount']} - ${record['type']}',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
            if (record['notes'] != null && record['notes'].isNotEmpty)
              Text(
                record['notes'],
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointGray,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            context.pushNamed('edit-watering-record');
          },
        ),
      ),
    );
  }
}
