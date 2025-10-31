import 'dart:convert';
import 'dart:io';

/// 샘플 예약 데이터 생성 스크립트
///
/// 실행 방법:
/// dart scripts/create_sample_reservations.dart
///
/// 이 스크립트는 테스트용 예약 데이터를 생성합니다.
/// 실제 앱에서는 SecureStorage를 사용하지만,
/// 여기서는 데이터 구조를 확인하고 수동으로 입력할 수 있도록 JSON을 출력합니다.

void main() {
  print('📅 샘플 예약 데이터 생성 중...\n');

  final now = DateTime.now();
  final tomorrow = now.add(const Duration(days: 1));
  final nextWeek = now.add(const Duration(days: 7));

  final sampleReservations = [
    {
      'id': '${DateTime.now().millisecondsSinceEpoch}',
      'hospitalId': 'hospital_001',
      'hospitalName': '東京動物病院',
      'petId': 'pet_001', // 실제 펫 ID로 변경 필요
      'petName': 'ポチ',
      'reserverName': '山田太郎',
      'phoneNumber': '090-1234-5678',
      'purpose': '定期健康診断',
      'reservationDate': tomorrow.toIso8601String(),
      'timeSlot': '10:00 - 11:00',
      'symptoms': '特になし',
      'status': 'pending',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    },
    {
      'id': '${DateTime.now().millisecondsSinceEpoch + 1}',
      'hospitalId': 'hospital_002',
      'hospitalName': '渋谷ペットクリニック',
      'petId': 'pet_001', // 실제 펫 ID로 변경 필요
      'petName': 'タマ',
      'reserverName': '佐藤花子',
      'phoneNumber': '090-9876-5432',
      'purpose': 'ワクチン接種',
      'reservationDate': nextWeek.toIso8601String(),
      'timeSlot': '14:00 - 15:00',
      'symptoms': null,
      'status': 'confirmed',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    },
    {
      'id': '${DateTime.now().millisecondsSinceEpoch + 2}',
      'hospitalId': 'hospital_003',
      'hospitalName': '新宿動物医療センター',
      'petId': 'pet_002', // 실제 펫 ID로 변경 필요
      'petName': 'チョコ',
      'reserverName': '鈴木一郎',
      'phoneNumber': '080-1111-2222',
      'purpose': '皮膚科診察',
      'reservationDate': now.add(const Duration(days: 3)).toIso8601String(),
      'timeSlot': '16:00 - 17:00',
      'symptoms': '皮膚に赤みがあります',
      'status': 'pending',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    },
  ];

  final jsonString = const JsonEncoder.withIndent(
    '  ',
  ).convert(sampleReservations);

  print('✅ 생성된 샘플 예약 데이터:\n');
  print(jsonString);
  print('\n');
  print('📝 사용 방법:');
  print('1. 위 JSON을 복사합니다.');
  print('2. Flutter DevTools > Storage Inspector를 엽니다.');
  print('3. SecureStorage에서 "hospital_reservations" 키를 찾습니다.');
  print('4. 위 JSON을 값으로 설정합니다.');
  print('5. 앱을 재시작하면 캘린더에 자동으로 동기화됩니다.');
  print('\n');
  print('⚠️  주의: petId는 실제 등록된 펫의 ID로 변경해야 합니다.');
  print('    펫 ID는 앱의 펫 프로필 화면에서 확인할 수 있습니다.');

  // 파일로도 저장
  final file = File('scripts/sample_reservations.json');
  file.writeAsStringSync(jsonString);
  print('\n✅ JSON 파일로도 저장되었습니다: ${file.path}');
}
