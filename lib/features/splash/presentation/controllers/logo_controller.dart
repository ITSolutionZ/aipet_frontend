import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoController {
  final Ref ref;

  // SharedPreferences 키 상수 (현재는 사용하지 않음 - 항상 두 로고 모두 표시)
  static const String _keyLastLogoShowTime = 'last_logo_show_time';

  LogoController(this.ref);

  /// 로고 시퀀스 시작 시간 저장 (통계 목적)
  Future<void> saveLogoSequenceStartTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _keyLastLogoShowTime,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (error) {
      // 저장 실패는 무시
    }
  }

  /// 순차적 로고 표시 (회사 로고 3초 → 앱 로고 3초) - 항상 둘 다 표시
  Stream<LogoState> startLogoSequence() async* {
    try {
      // 시작 시간 저장 (통계 목적)
      await saveLogoSequenceStartTime();

      // 1단계: 회사 로고 표시 (3초) - 항상 표시
      yield LogoState.companyLogo('assets/icons/itz.png');
      await Future.delayed(const Duration(seconds: 3));

      // 2단계: 앱 로고 표시 (3초) - 항상 표시
      yield LogoState.appLogo('assets/icons/aipet_logo.png');
      await Future.delayed(const Duration(seconds: 3));

      // 완료
      yield LogoState.completed();
    } catch (error) {
      // 에러 발생 시에도 두 로고 모두 표시
      try {
        // 회사 로고
        yield LogoState.companyLogo('assets/icons/itz.png');
        await Future.delayed(const Duration(seconds: 3));

        // 앱 로고
        yield LogoState.appLogo('assets/icons/aipet_logo.png');
        await Future.delayed(const Duration(seconds: 3));

        // 완료
        yield LogoState.completed();
      } catch (criticalError) {
        // 치명적 에러 시에도 완료 신호는 보냄
        yield LogoState.completed();
      }
    }
  }

  /// 로고 이미지 로드 검증
  Future<LogoResult> validateLogoAssets() async {
    try {
      // 회사 로고 에셋 확인
      await rootBundle.load('assets/icons/itz.png');

      // 앱 로고 에셋 확인
      await rootBundle.load('assets/icons/aipet_logo.png');

      return LogoResult.success('로고 에셋이 확인되었습니다');
    } catch (error) {
      return LogoResult.failure('로고 에셋을 로드할 수 없습니다: $error');
    }
  }
}

/// 로고 상태를 나타내는 클래스
class LogoState {
  final LogoType type;
  final String imagePath;
  final int phase;
  final int totalPhases;

  const LogoState._({
    required this.type,
    required this.imagePath,
    required this.phase,
    required this.totalPhases,
  });

  factory LogoState.companyLogo(String imagePath) => LogoState._(
    type: LogoType.company,
    imagePath: imagePath,
    phase: 1,
    totalPhases: 2,
  );

  factory LogoState.appLogo(String imagePath) => LogoState._(
    type: LogoType.app,
    imagePath: imagePath,
    phase: 2,
    totalPhases: 2,
  );

  factory LogoState.completed() => const LogoState._(
    type: LogoType.completed,
    imagePath: '',
    phase: 2,
    totalPhases: 2,
  );

  bool get isCompleted => type == LogoType.completed;
}

/// 로고 타입 열거형
enum LogoType { company, app, completed }

/// 로고 결과 클래스
class LogoResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const LogoResult._(this.isSuccess, this.message, this.data);

  factory LogoResult.success(String message, [dynamic data]) =>
      LogoResult._(true, message, data);
  factory LogoResult.failure(String message) =>
      LogoResult._(false, message, null);
}
