/// Pet Basic Info Tab 상수 정의
///
/// 펫 기본 정보 탭에서 사용되는 모든 상수를 중앙 관리
class BasicInfoConstants {
  // Private constructor to prevent instantiation
  BasicInfoConstants._();

  // ============================================================
  // 크기 상수
  // ============================================================

  /// 프로필 이미지 크기
  static const double profileImageSize = 120.0;

  /// 일반 아이콘 크기
  static const double iconSize = 40.0;

  /// 편집 아이콘 크기
  static const double editIconSize = 16.0;

  /// 작은 아이콘 크기
  static const double smallIconSize = 20.0;

  /// 테두리 두께
  static const double borderWidth = 2.0;

  /// 카드 모서리 반경
  static const double cardBorderRadius = 12.0;

  // ============================================================
  // 레이블 텍스트
  // ============================================================

  /// 이름 레이블
  static const String nameLabel = '名前';

  /// 체중 레이블
  static const String weightLabel = '体重';

  /// 성별 레이블
  static const String genderLabel = '性別';

  /// 보호자 레이블
  static const String guardianLabel = '保護者';

  /// 등록 기관 레이블
  static const String institutionLabel = '登録機関';

  /// 입양일 레이블
  static const String adoptionDateLabel = '家に来た日';

  /// 생년월일 레이블
  static const String birthDateLabel = '誕生日';

  /// 나이 레이블
  static const String ageLabel = '歳';

  /// 마이크로칩 레이블
  static const String microchipLabel = 'マイクロチップ';

  /// 건강 상태 레이블
  static const String healthStatusLabel = '健康状態';

  /// 신체 부위 레이블
  static const String bodyPartsLabel = '気になる身体部位';

  /// 외견 레이블
  static const String appearanceLabel = '外見';

  /// 가족 레이블
  static const String familyLabel = '家族';

  /// 등록번호 레이블
  static const String registrationNumberLabel = '登録番号';

  // ============================================================
  // 버튼 텍스트
  // ============================================================

  /// 사진 변경 버튼
  static const String changePhotoButton = '写真を変更';

  /// 편집 버튼
  static const String editButton = '編集';

  /// 저장 버튼
  static const String saveButton = '保存';

  /// 취소 버튼
  static const String cancelButton = 'キャンセル';

  /// 삭제 버튼
  static const String deleteButton = '削除';

  /// 추가 버튼
  static const String addButton = '追加';

  // ============================================================
  // 메시지 텍스트
  // ============================================================

  /// 등록 정보 없음 메시지
  static const String noRegistrationInfo = '登録情報がありません';

  /// 마이크로칩 정보 없음 메시지
  static const String noMicrochipInfo = 'マイクロチップ情報がありません';

  /// 건강 상태 정보 없음 메시지
  static const String noHealthInfo = '健康状態情報がありません';

  /// 신체 부위 정보 없음 메시지
  static const String noBodyPartsInfo = '気になる部位はありません';

  /// 외견 정보 없음 메시지
  static const String noAppearanceInfo = '外見情報がありません';

  /// 보호자 없음 메시지
  static const String noCaretakerMessage = '登録された家族がいません';

  /// 보호자 추가 안내
  static const String addCaretakerHint = '家族を追加してください';

  // ============================================================
  // 다이얼로그 텍스트
  // ============================================================

  /// 건강 상태 선택 타이틀
  static const String selectHealthStatusTitle = '健康状態を選択';

  /// 삭제 확인 타이틀
  static const String deleteConfirmTitle = '削除確認';

  /// 삭제 확인 메시지
  static const String deleteConfirmMessage = 'このペットを削除してもよろしいですか？';

  // ============================================================
  // 건강 상태 옵션
  // ============================================================

  /// 건강 상태 옵션 목록
  static const List<Map<String, String>> healthConditions = [
    {'value': 'arthritis', 'label': '関節炎'},
    {'value': 'heart_disease', 'label': '心臓病'},
    {'value': 'kidney_disease', 'label': '腎臓病'},
    {'value': 'diabetes', 'label': '糖尿病'},
    {'value': 'obesity', 'label': '肥満'},
    {'value': 'allergy', 'label': 'アレルギー'},
    {'value': 'pregnancy', 'label': '妊娠中'},
    {'value': 'recovery', 'label': '回復中'},
  ];

  /// 건강 상태 값으로 레이블 가져오기
  static String getHealthConditionLabel(String value) {
    final condition = healthConditions.firstWhere(
      (item) => item['value'] == value,
      orElse: () => {'label': value},
    );
    return condition['label'] ?? value;
  }

  /// 건강 상태 레이블로 값 가져오기
  static String getHealthConditionValue(String label) {
    final condition = healthConditions.firstWhere(
      (item) => item['label'] == label,
      orElse: () => {'value': label},
    );
    return condition['value'] ?? label;
  }

  // ============================================================
  // 성별 옵션
  // ============================================================

  /// 수컷 값
  static const String maleValue = 'male';

  /// 암컷 값
  static const String femaleValue = 'female';

  /// 수컷 레이블
  static const String maleLabel = 'オス';

  /// 암컷 레이블
  static const String femaleLabel = 'メス';

  /// 성별 옵션 목록
  static const List<Map<String, String>> genderOptions = [
    {'value': maleValue, 'label': maleLabel},
    {'value': femaleValue, 'label': femaleLabel},
  ];

  /// 성별 값으로 레이블 가져오기
  static String getGenderLabel(String? value) {
    if (value == null) return '';
    final gender = genderOptions.firstWhere(
      (item) => item['value'] == value,
      orElse: () => {'label': value},
    );
    return gender['label'] ?? value;
  }

  // ============================================================
  // 날짜 포맷
  // ============================================================

  /// 일본어 날짜 포맷 (YYYY年MM月DD日)
  static String formatDateJa(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 나이 계산 및 포맷팅
  static String formatAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    return '$age$ageLabel';
  }
}
