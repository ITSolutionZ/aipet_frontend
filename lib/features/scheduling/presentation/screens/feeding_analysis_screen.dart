import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';

/// 급여 분석 화면
class FeedingAnalysisScreen extends ConsumerStatefulWidget {
  final String petId;

  const FeedingAnalysisScreen({super.key, required this.petId});

  @override
  ConsumerState<FeedingAnalysisScreen> createState() =>
      _FeedingAnalysisScreenState();
}

class _FeedingAnalysisScreenState extends ConsumerState<FeedingAnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    final analysisData = MockDataService.getMockFeedingAnalysisData();

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Text(
          '食事管理',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pointBrown.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 현재 급여량 요약
            Container(
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
                  Text(
                    '現在の食事量',
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.xl,
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCurrentFeedingCard(
                          '${analysisData['currentAmount'].toInt()}g',
                          '現在',
                          AppColors.pointBrown,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildCurrentFeedingCard(
                          '${analysisData['changeAmount'] > 0 ? '+' : ''}${analysisData['changeAmount'].toInt()}g',
                          '変化',
                          AppColors.pointGreen,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildCurrentFeedingCard(
                          '${analysisData['targetAmount'].toInt()}g',
                          '目標',
                          AppColors.pointBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 급여량 추이 차트
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                        '食事量推移',
                        style: AppFonts.fredoka(
                          fontSize: AppFonts.xl,
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          _buildLegendItem('給餌量', AppColors.pointBlue),
                          const SizedBox(width: AppSpacing.md),
                          _buildLegendItem('実際摂取量', Colors.orange),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(height: 200, child: _buildFeedingChart()),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 급여 기록 리스트
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                        '食事記録',
                        style: AppFonts.fredoka(
                          fontSize: AppFonts.xl,
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAddFeedingDialog(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.pointBrown.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFeedingRecord(
                    '${analysisData['currentAmount'].toInt()}g',
                    '2023/09/07',
                    '+0.2kg',
                  ),
                  _buildFeedingRecord(
                    '${(analysisData['currentAmount'] - 15).toInt()}g',
                    '2023/09/06',
                    '-0.1kg',
                  ),
                  _buildFeedingRecord(
                    '${(analysisData['currentAmount'] - 5).toInt()}g',
                    '2023/09/05',
                    '+0.1kg',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentFeedingCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppFonts.fredoka(
              fontSize: AppFonts.xl,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppFonts.bodySmall.copyWith(
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedingChart() {
    final analysisData = MockDataService.getMockFeedingAnalysisData();

    // 오늘부터 1개월까지의 날짜 데이터 생성
    final now = DateTime.now();
    final feedingAmountData = <String, double>{}; // 급여량 (막대그래프)
    final actualAmountData = <String, double>{}; // 실제 식사량 (꺾은선 그래프)

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.month}/${date.day}';

      // 급여량 데이터 (목표량 기준으로 변동)
      feedingAmountData[dateKey] =
          analysisData['targetAmount'] + (i * 0.3 - 4.5);

      // 실제 식사량 데이터 (급여량보다 약간 적게)
      actualAmountData[dateKey] =
          feedingAmountData[dateKey]! * 0.85 + (i * 0.2 - 3.0);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Y축 라벨과 차트 영역
          Expanded(
            child: Row(
              children: [
                // Y축 라벨
                SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '250g',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointGray,
                        ),
                      ),
                      Text(
                        '200g',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointGray,
                        ),
                      ),
                      Text(
                        '150g',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointGray,
                        ),
                      ),
                      Text(
                        '100g',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointGray,
                        ),
                      ),
                      Text(
                        '50g',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // 차트 영역 (가로 스크롤 가능)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: AppColors.pointGray.withValues(alpha: 0.3),
                        ),
                        bottom: BorderSide(
                          color: AppColors.pointGray.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 600, // 30일 * 20px = 600px
                        child: GestureDetector(
                          onTapDown: (details) => _showChartDetail(
                            context,
                            details,
                            feedingAmountData,
                            actualAmountData,
                          ),
                          child: CustomPaint(
                            painter: FeedingChartPainter(
                              feedingAmountData: feedingAmountData,
                              actualAmountData: actualAmountData,
                            ),
                            child: Container(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // X축 라벨 (가로 스크롤 가능)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: feedingAmountData.keys.toList().reversed.map((date) {
                return Container(
                  width: 20,
                  alignment: Alignment.center,
                  child: Text(
                    date,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingRecord(String amount, String date, String change) {
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

  /// 식사 기록 추가 다이얼로그 표시
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
                  // 식사량 입력
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
              onPressed: () {
                if (amountController.text.isNotEmpty) {
                  // 여기에 실제 데이터 저장 로직 추가
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('食事記録が追加されました。'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  amountController.dispose();
                  noteController.dispose();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('食事量を入力してください。'),
                      backgroundColor: Colors.red,
                    ),
                  );
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

/// 차트 상세 정보 표시
void _showChartDetail(
  BuildContext context,
  TapDownDetails details,
  Map<String, double> feedingAmountData,
  Map<String, double> actualAmountData,
) {
  final dates = feedingAmountData.keys.toList();
  if (dates.isEmpty) return;

  // 터치 위치를 기반으로 날짜 인덱스 계산
  const chartWidth = 600.0;
  final touchX = details.localPosition.dx;
  final dateIndex = (touchX / (chartWidth / dates.length)).floor();

  if (dateIndex >= 0 && dateIndex < dates.length) {
    final selectedDate =
        dates[dates.length - 1 - dateIndex]; // 역순으로 표시되므로 인덱스 조정
    final feedingAmount = feedingAmountData[selectedDate] ?? 0.0;
    final actualAmount = actualAmountData[selectedDate] ?? 0.0;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '$selectedDate 상세 정보',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.pointBlue.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '급여량: ${feedingAmount.toStringAsFixed(1)}g',
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '실제 식사량: ${actualAmount.toStringAsFixed(1)}g',
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.pointGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '잔여량: ${(feedingAmount - actualAmount).toStringAsFixed(1)}g',
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

/// 급여량 차트 페인터
class FeedingChartPainter extends CustomPainter {
  final Map<String, double> feedingAmountData; // 급여량 (막대그래프)
  final Map<String, double> actualAmountData; // 실제 식사량 (꺾은선 그래프)

  FeedingChartPainter({
    required this.feedingAmountData,
    required this.actualAmountData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dates = feedingAmountData.keys.toList();
    if (dates.isEmpty) return;

    final barWidth = size.width / dates.length * 0.6; // 막대 너비

    // 급여량 막대그래프 (파란색)
    final barPaint = Paint()
      ..color = AppColors.pointBlue.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dates.length; i++) {
      final date = dates[i];
      final amount = feedingAmountData[date] ?? 200.0;
      final normalizedAmount = ((amount - 150.0) / 100.0).clamp(0.0, 1.0);

      final x = size.width * (i / (dates.length - 1));
      final barHeight = size.height * normalizedAmount;
      final barY = size.height - barHeight;

      // 막대 그리기
      final barRect = Rect.fromLTWH(
        x - barWidth / 2,
        barY,
        barWidth,
        barHeight,
      );
      canvas.drawRect(barRect, barPaint);
    }

    // 실제 식사량 꺾은선 그래프 (주황색)
    final linePaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    final linePoints = dates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final amount = actualAmountData[date] ?? 180.0;
      final normalizedAmount = ((amount - 150.0) / 100.0).clamp(0.0, 1.0);
      return Offset(
        size.width * (index / (dates.length - 1)),
        size.height * (1.0 - normalizedAmount),
      );
    }).toList();

    if (linePoints.isNotEmpty) {
      linePath.moveTo(linePoints.first.dx, linePoints.first.dy);
      for (int i = 1; i < linePoints.length; i++) {
        linePath.lineTo(linePoints[i].dx, linePoints[i].dy);
      }
      canvas.drawPath(linePath, linePaint);

      // 점 그리기
      final dotPaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill;

      for (final point in linePoints) {
        canvas.drawCircle(point, 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
