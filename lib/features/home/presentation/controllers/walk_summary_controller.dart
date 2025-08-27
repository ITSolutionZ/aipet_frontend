import '../../../../app/controllers/base_controller.dart';

class WalkSummaryResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const WalkSummaryResult._(this.isSuccess, this.message, this.data);

  factory WalkSummaryResult.success(String message, [dynamic data]) =>
      WalkSummaryResult._(true, message, data);
  factory WalkSummaryResult.failure(String message) =>
      WalkSummaryResult._(false, message, null);
}

class WalkSummaryController extends BaseController {
  WalkSummaryController(super.ref);

  /// 산책 통계 데이터 로드
  Future<WalkSummaryResult> loadWalkSummary() async {
    try {
      // Mock data - 실제로는 repository에서 데이터 가져옴
      final walkData = {
        'todayDistance': 12.3,
        'todayTime': 30,
        'weeklyDistance': 45.6,
        'weeklyTime': 120,
        'lastWalkTime': DateTime.now().subtract(const Duration(hours: 2)),
      };
      
      return WalkSummaryResult.success('산책 정보가 로드되었습니다', walkData);
    } catch (error) {
      handleError(error);
      return WalkSummaryResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 거리 포맷팅 (km 단위로 변환)
  String formatDistance(double distanceInKm) {
    if (distanceInKm >= 1.0) {
      return distanceInKm.toStringAsFixed(1);
    } else {
      return (distanceInKm * 1000).toInt().toString();
    }
  }

  /// 거리 단위 결정
  String getDistanceUnit(double distanceInKm) {
    return distanceInKm >= 1.0 ? 'km' : 'm';
  }

  /// 시간 포맷팅 (분 단위)
  String formatTime(int timeInMinutes) {
    if (timeInMinutes >= 60) {
      final hours = timeInMinutes ~/ 60;
      final minutes = timeInMinutes % 60;
      return minutes > 0 ? '$hours時間$minutes分' : '$hours時間';
    }
    return timeInMinutes.toString();
  }

  /// 시간 단위 결정
  String getTimeUnit(int timeInMinutes) {
    return timeInMinutes >= 60 ? '' : '分';
  }

  /// 산책 권장 메시지 생성
  String generateWalkRecommendation(double todayDistance, int todayTime) {
    final now = DateTime.now();
    
    if (todayDistance == 0 && now.hour >= 16) {
      return 'まだ散歩していません。お散歩はいかがですか？';
    } else if (todayDistance < 5.0) {
      return 'もう少し歩いてみませんか？';
    } else if (todayDistance >= 10.0) {
      return '今日はよく歩きました！';
    }
    return '良いペースです。続けましょう！';
  }

  /// 주간 목표 달성률 계산
  double calculateWeeklyProgress(double currentDistance, double weeklyGoal) {
    if (weeklyGoal <= 0) return 0.0;
    return (currentDistance / weeklyGoal * 100).clamp(0.0, 100.0);
  }

  /// 산책 기록 탭 핸들러
  Future<WalkSummaryResult> handleWalkTap() async {
    try {
      // 산책 상세 화면으로 이동하는 로직
      return WalkSummaryResult.success('산책 상세 화면으로 이동합니다');
    } catch (error) {
      handleError(error);
      return WalkSummaryResult.failure('산책 정보를 불러올 수 없습니다');
    }
  }
}