import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/app.dart';

/// 앱의 진입점
///
/// Flutter 앱의 시작점으로, 최소한의 초기화만 수행하고
/// 나머지는 AppBootstrap에서 처리합니다.
void main() async {
  // Flutter 위젯 바인딩 초기화 (Sentry 호환)
  SentryWidgetsFlutterBinding.ensureInitialized();

  // 세로 모드만 지원 (가로 모드 비활성화)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 일본어 로케일 데이터 초기화
  await initializeDateFormatting('ja_JP', null);

  // timezone 초기화 (스케줄 알림에 필요)
  tz.initializeTimeZones();

  // .env 파일 로드
  try {
    await dotenv.load(fileName: '.env');
    // debugPrint('✅ Environment variables loaded from .env');
  } catch (e) {
    // .env 파일이 없어도 앱이 계속 실행되도록 함
    // debugPrint('Warning: .env file not found: $e');
  }

  // 앱 부트스트랩 초기화
  await AppBootstrap.initialize();

  // 앱 실행
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://b5916da06a961ec24d87dafbc5c07b2e@o4510047577309184.ingest.us.sentry.io/4510047582683136';
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      options.enableLogs = true;

      // 샘플링 설정 (성능 모니터링) - 프로파일링 충돌 방지를 위해 낮게 설정
      options.tracesSampleRate = 0.1;

      // 프로파일링 완전 비활성화 (크래시 방지)
      options.profilesSampleRate = 0.0;

      // ANR (Application Not Responding) 감지 비활성화
      options.enableAutoNativeBreadcrumbs = false;

      // 네이티브 크래시 모니터링만 활성화
      options.enableAutoSessionTracking = false;

      // Session Replay도 비활성화 (안정성 향상)
      options.replay.sessionSampleRate = 0.0;
      options.replay.onErrorSampleRate = 0.0;
    },
    appRunner: () => runApp(
      SentryWidget(child: ProviderScope(child: AppBootstrap.createApp())),
    ),
  );
}
