import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';


import '../../../../shared/shared.dart';
import '../../../../app/controllers/base_controller.dart';
import '../../../../../features/scheduling/data/services/feeding_local_storage_service.dart';
import 'helpers/helpers.dart';


class FeedingRecordsController extends BaseController {
  FeedingRecordsController(super.ref);

  /// 급여 기록 데이터 로드
  Future<Result<List<dynamic>>> loadFeedingRecords() async {
    try {
      final records = await FeedingLocalStorageService.getFeedingRecords();
      return Result.success('給餌記録を取得しました', records);
    } catch (error) {
      return Result.failure('給餌記録の取得に失敗しました: $error');
    }
  }

  /// 급여 통계 데이터 로드
  Future<Result<Map<String, dynamic>>> loadFeedingStatistics() async {
    try {
      final records = await FeedingLocalStorageService.getFeedingRecords();
      final statistics = {
        'totalFeedings': records.length,
        'averageAmount': records.isEmpty
            ? 0.0
            : records.fold<double>(
                    0,
                    (sum, r) => sum + (r['amount'] as double),
                  ) /
                  records.length,
        'completionRate': 0.85,
      };
      return Result.success('給餌統計を取得しました', statistics);
    } catch (error) {
      return Result.failure('給餌統計の取得に失敗しました: $error');
    }
  }

  /// 차트 데이터 생성
  Result<Map<String, dynamic>> generateChartData(List<dynamic> feedingRecords) {
    try {
      final data = FeedingChartHelper.generateChartData(feedingRecords);
      return Result.success('차트 데이터가 생성되었습니다', data);
    } catch (error) {
      return Result.failure('차트 데이터 생성 실패: $error');
    }
  }

  /// 차트 위젯 생성
  Widget buildChart(List<FlSpot> chartData, List<FlSpot> targetData) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 50,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.pointGray.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.pointGray.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FeedingChartHelper.buildTitlesData(),
        borderData: FeedingChartHelper.buildBorderData(),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 350,
        lineBarsData: [
          FeedingChartHelper.buildActualDataLine(chartData),
          FeedingChartHelper.buildTargetDataLine(targetData),
        ],
        lineTouchData: FeedingChartHelper.buildTouchData(),
      ),
    );
  }

  /// 시간 포맷팅
  String formatTime(DateTime time) {
    return FeedingStatsHelper.formatTime(time);
  }

  /// 급여 기록 필터링
  List<dynamic> filterRecordsByDate(
    List<dynamic> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    return FeedingFilterHelper.filterRecordsByDate(records, startDate, endDate);
  }

  /// 급여 기록 검색
  List<dynamic> searchRecords(List<dynamic> records, String query) {
    return FeedingFilterHelper.searchRecords(records, query);
  }

  /// 새 급여 기록 추가
  Future<Result<Map<String, dynamic>>> addFeedingRecord({
    required String petName,
    required String foodType,
    required String foodBrand,
    required double amount,
    required DateTime fedTime,
  }) async {
    try {
      // Mock add logic - 실제로는 repository를 통해 저장
      await Future.delayed(const Duration(milliseconds: 500));

      final record = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'petName': petName,
        'foodType': foodType,
        'foodBrand': foodBrand,
        'amount': amount,
        'fedTime': fedTime,
        'status': 'completed',
      };

      return Result.success('급여 기록이 추가되었습니다', record);
    } catch (error) {
      return Result.failure('급여 기록 추가 실패: $error');
    }
  }

  /// 급여 기록 삭제
  Future<Result<void>> deleteFeedingRecord(String recordId) async {
    try {
      // Mock delete logic
      await Future.delayed(const Duration(milliseconds: 300));
      return Result.success('급여 기록이 삭제되었습니다', null);
    } catch (error) {
      return Result.failure('급여 기록 삭제 실패: $error');
    }
  }

  /// 급여 기록 수정
  Future<Result<Map<String, dynamic>>> updateFeedingRecord({
    required String recordId,
    required String petName,
    required String foodType,
    required String foodBrand,
    required double amount,
    required DateTime fedTime,
  }) async {
    try {
      // Mock update logic
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedRecord = {
        'id': recordId,
        'petName': petName,
        'foodType': foodType,
        'foodBrand': foodBrand,
        'amount': amount,
        'fedTime': fedTime,
        'status': 'completed',
      };

      return Result.success('급여 기록이 수정되었습니다', updatedRecord);
    } catch (error) {
      return Result.failure('급여 기록 수정 실패: $error');
    }
  }

  /// 주간 급여 통계 계산
  Map<String, dynamic> calculateWeeklyStatistics(List<dynamic> records) {
    return FeedingStatsHelper.calculateWeeklyStatistics(records);
  }
}
