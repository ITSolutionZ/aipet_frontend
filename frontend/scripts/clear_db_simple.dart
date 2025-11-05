/// 간단한 데이터베이스 삭제 가이드
///
/// 데이터베이스의 모든 펫과 유저 데이터를 삭제하려면:
///
/// 1. 앱을 실행하세요
/// 2. 설정 화면에서 숨겨진 경로로 이동하세요: /settings/database-dashboard
/// 3. 우측 상단 점3개 메뉴 클릭
/// 4. "全データ削除" (전체 데이터 삭제) 선택
/// 5. 확인 버튼 클릭
///
/// 또는 아래 코드를 test 파일로 실행하세요:
library;

import 'package:flutter/rendering.dart';

void main() {
  debugPrint('Database Dashboard로 이동하여 "全データ削除" 버튼을 사용하세요');
  debugPrint('경로: /settings/database-dashboard');
}
