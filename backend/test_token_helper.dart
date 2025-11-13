// Firebase ID Token을 얻기 위한 테스트 헬퍼
// Flutter 앱의 아무 곳에서나 이 코드를 실행하여 토큰을 얻을 수 있습니다

import 'package:firebase_auth/firebase_auth.dart';

Future<void> printFirebaseToken() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('❌ 로그인되지 않았습니다. 먼저 로그인하세요.');
      return;
    }

    // Firebase ID Token 획득
    final token = await user.getIdToken();

    print('═══════════════════════════════════════════════════════');
    print('✅ Firebase ID Token (Swagger UI에서 사용):');
    print('═══════════════════════════════════════════════════════');
    print(token);
    print('═══════════════════════════════════════════════════════');
    print('📋 이 토큰을 복사하여 Swagger UI의 Authorize 버튼에 붙여넣으세요.');
    print('⏰ 토큰 유효기간: 1시간');

  } catch (e) {
    print('❌ 토큰 획득 실패: $e');
  }
}

// 사용 예시:
// void initState() {
//   super.initState();
//   printFirebaseToken();  // 디버그 콘솔에 토큰 출력
// }
