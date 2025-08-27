import '../../../../app/controllers/base_controller.dart';

class AppointmentResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const AppointmentResult._(this.isSuccess, this.message, this.data);

  factory AppointmentResult.success(String message, [dynamic data]) =>
      AppointmentResult._(true, message, data);
  factory AppointmentResult.failure(String message) =>
      AppointmentResult._(false, message, null);
}

class AppointmentData {
  final String petName;
  final String petImagePath;
  final String appointmentTitle;
  final String appointmentInfo;
  final DateTime scheduledTime;
  final String type;
  final String location;

  const AppointmentData({
    required this.petName,
    required this.petImagePath,
    required this.appointmentTitle,
    required this.appointmentInfo,
    required this.scheduledTime,
    required this.type,
    required this.location,
  });
}

class AppointmentController extends BaseController {
  AppointmentController(super.ref);

  /// 다음 예약 정보 로드
  Future<AppointmentResult> loadNextAppointment() async {
    try {
      final nextAppointment = await _getNextAppointment();
      return AppointmentResult.success('예약 정보가 로드되었습니다', nextAppointment);
    } catch (error) {
      handleError(error);
      return AppointmentResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 다음 예약 데이터 가져오기
  Future<AppointmentData?> _getNextAppointment() async {
    // Mock data - 실제로는 repository에서 데이터 가져옴
    final now = DateTime.now();
    final nextAppointment = now.add(const Duration(days: 1));

    return AppointmentData(
      petName: 'ペコ',
      petImagePath: 'assets/images/dogs/poodle.jpg',
      appointmentTitle: '次の予約',
      appointmentInfo: '近く獣医・${nextAppointment.month}月${nextAppointment.day}日',
      scheduledTime: nextAppointment,
      type: '健康診断',
      location: '近く獣医',
    );
  }

  /// 예약 정보 포맷팅
  String formatAppointmentInfo(DateTime scheduledTime, String location) {
    final month = scheduledTime.month;
    final day = scheduledTime.day;
    final hour = scheduledTime.hour;
    final minute = scheduledTime.minute.toString().padLeft(2, '0');

    return '$location・$month月$day日 $hour:$minute';
  }

  /// 예약까지 남은 시간 계산
  String getTimeUntilAppointment(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}日後';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間後';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分後';
    } else {
      return '間もなく';
    }
  }

  /// 예약 상태 확인
  String getAppointmentStatus(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (difference.inHours <= 1 && difference.inMinutes > 0) {
      return '間もなく';
    } else if (difference.inHours <= 24) {
      return '明日';
    } else if (difference.inDays <= 7) {
      return '今週';
    } else {
      return '予定';
    }
  }

  /// 예약 탭 핸들러
  Future<AppointmentResult> handleAppointmentTap() async {
    try {
      // 예약 상세 화면으로 이동하는 로직
      return AppointmentResult.success('예약 상세 화면으로 이동합니다');
    } catch (error) {
      handleError(error);
      return AppointmentResult.failure('예약 정보를 불러올 수 없습니다');
    }
  }

  /// 예약 알림 설정
  Future<AppointmentResult> setAppointmentReminder(
    DateTime scheduledTime,
  ) async {
    try {
      // 알림 설정 로직
      return AppointmentResult.success('예약 알림이 설정되었습니다');
    } catch (error) {
      handleError(error);
      return AppointmentResult.failure('알림 설정에 실패했습니다');
    }
  }

  /// 예약 취소
  Future<AppointmentResult> cancelAppointment(String appointmentId) async {
    try {
      // 예약 취소 로직
      return AppointmentResult.success('예약이 취소되었습니다');
    } catch (error) {
      handleError(error);
      return AppointmentResult.failure('예약 취소에 실패했습니다');
    }
  }

  /// 새 예약 생성
  Future<AppointmentResult> createNewAppointment({
    required String petId,
    required DateTime scheduledTime,
    required String type,
    required String location,
  }) async {
    try {
      // 새 예약 생성 로직
      return AppointmentResult.success('새 예약이 생성되었습니다');
    } catch (error) {
      handleError(error);
      return AppointmentResult.failure('예약 생성에 실패했습니다');
    }
  }
}
