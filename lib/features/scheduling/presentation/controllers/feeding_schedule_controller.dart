import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/scheduling/data/services/feeding_local_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';

class MealStatus {
  final String meal;
  final String time;
  final bool isCompleted;

  const MealStatus({
    required this.meal,
    required this.time,
    required this.isCompleted,
  });
}

class ScheduleItem {
  final String id;
  final String meal;
  final String time;
  final String amount;
  final bool isEnabled;

  const ScheduleItem({
    required this.id,
    required this.meal,
    required this.time,
    required this.amount,
    required this.isEnabled,
  });

  ScheduleItem copyWith({
    String? id,
    String? meal,
    String? time,
    String? amount,
    bool? isEnabled,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      meal: meal ?? this.meal,
      time: time ?? this.time,
      amount: amount ?? this.amount,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class FeedingScheduleController extends BaseController {
  FeedingScheduleController(super.ref);

  /// 펫 정보 로드
  Future<Result<Map<String, dynamic>>> loadPetInfo(String petId) async {
    try {
      final petsInfo = FeedingLocalStorageService.getPetSizeFeedingInfo();
      final pet = petsInfo[petId];
      if (pet != null) {
        return Result.success('ペット情報を取得しました', pet);
      }
      return Result.failure('ペットが見つかりません');
    } catch (error) {
      return Result.failure('ペット情報の取得に失敗しました: $error');
    }
  }

  /// 오늘의 급여 상태 로드
  Future<Result<List<MealStatus>>> loadTodayMealStatus() async {
    try {
      // Mock data for today's meal status
      final now = DateTime.now();

      final mealStatuses = [
        MealStatus(
          meal: '朝',
          time: '08:00',
          isCompleted: now.hour > 8 || (now.hour == 8 && now.minute > 30),
        ),
        MealStatus(
          meal: '昼',
          time: '12:00',
          isCompleted: now.hour > 12 || (now.hour == 12 && now.minute > 30),
        ),
        MealStatus(
          meal: '夜',
          time: '18:00',
          isCompleted: now.hour > 18 || (now.hour == 18 && now.minute > 30),
        ),
      ];

      return Result.success('급여 상태가 로드되었습니다', mealStatuses);
    } catch (error) {
      return Result.failure('급여 상태 로드 실패: $error');
    }
  }

  /// 스케줄 설정 로드
  Future<Result<List<ScheduleItem>>> loadScheduleSettings(String petId) async {
    try {
      // Mock data for schedule settings
      final scheduleItems = [
        const ScheduleItem(
          id: 'morning',
          meal: '朝食',
          time: '08:00',
          amount: '100g',
          isEnabled: true,
        ),
        const ScheduleItem(
          id: 'lunch',
          meal: '昼食',
          time: '12:00',
          amount: '100g',
          isEnabled: true,
        ),
        const ScheduleItem(
          id: 'dinner',
          meal: '夕食',
          time: '18:00',
          amount: '100g',
          isEnabled: true,
        ),
      ];

      return Result.success('스케줄 설정이 로드되었습니다', scheduleItems);
    } catch (error) {
      return Result.failure('스케줄 설정 로드 실패: $error');
    }
  }

  /// 스케줄 항목 업데이트
  Future<Result<ScheduleItem>> updateScheduleItem(ScheduleItem item) async {
    try {
      // Mock update logic - 실제로는 repository를 통해 저장
      await Future.delayed(const Duration(milliseconds: 500));
      return Result.success('스케줄이 업데이트되었습니다', item);
    } catch (error) {
      return Result.failure('스케줄 업데이트 실패: $error');
    }
  }

  /// 급여 기록 추가
  Future<Result<Map<String, dynamic>>> addFeedingRecord({
    required String petId,
    required String meal,
    required String amount,
  }) async {
    try {
      // Mock add feeding record logic
      await Future.delayed(const Duration(milliseconds: 500));

      final record = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'petId': petId,
        'meal': meal,
        'amount': amount,
        'timestamp': DateTime.now(),
      };

      return Result.success('급여 기록이 추가되었습니다', record);
    } catch (error) {
      return Result.failure('급여 기록 추가 실패: $error');
    }
  }

  /// 스케줄 편집을 위한 데이터 준비
  Map<String, dynamic> prepareScheduleEditData(ScheduleItem item) {
    return {
      'id': item.id,
      'meal': item.meal,
      'time': item.time,
      'amount': item.amount,
      'isEnabled': item.isEnabled,
      'hours': _parseHour(item.time),
      'minutes': _parseMinute(item.time),
      'amountValue': _parseAmount(item.amount),
    };
  }

  /// 시간 파싱 헬퍼 메서드
  int _parseHour(String time) {
    final parts = time.split(':');
    return int.tryParse(parts[0]) ?? 8;
  }

  int _parseMinute(String time) {
    final parts = time.split(':');
    return int.tryParse(parts[1]) ?? 0;
  }

  int _parseAmount(String amount) {
    final numStr = amount.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numStr) ?? 100;
  }

  /// 시간 포맷팅
  String formatTime(int hour, int minute) {
    final dateTime = DateTime(2000, 1, 1, hour, minute);
    return DateTimeUtils.formatTime(dateTime);
  }

  /// 급여량 포맷팅
  String formatAmount(int amount) {
    return '${amount}g';
  }

  /// 급여 완료율 계산
  double calculateCompletionRate(List<MealStatus> mealStatuses) {
    if (mealStatuses.isEmpty) return 0.0;
    final completedCount = mealStatuses
        .where((status) => status.isCompleted)
        .length;
    return completedCount / mealStatuses.length;
  }

  /// 다음 급여 시간 계산
  DateTime? getNextMealTime(List<ScheduleItem> scheduleItems) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final item in scheduleItems) {
      if (!item.isEnabled) continue;

      final hour = _parseHour(item.time);
      final minute = _parseMinute(item.time);
      final mealTime = today.add(Duration(hours: hour, minutes: minute));

      if (mealTime.isAfter(now)) {
        return mealTime;
      }
    }

    // 오늘의 모든 급여가 끝났으면 내일 첫 급여 시간 반환
    if (scheduleItems.isNotEmpty) {
      final firstItem = scheduleItems.first;
      if (firstItem.isEnabled) {
        final hour = _parseHour(firstItem.time);
        final minute = _parseMinute(firstItem.time);
        final tomorrow = today.add(const Duration(days: 1));
        return tomorrow.add(Duration(hours: hour, minutes: minute));
      }
    }

    return null;
  }

  /// 급여 알림 메시지 생성
  String generateFeedingNotification(DateTime? nextMealTime) {
    if (nextMealTime == null) {
      return '급여 일정이 없습니다';
    }

    return DateTimeUtils.formatTimeDifference(nextMealTime);
  }
}
