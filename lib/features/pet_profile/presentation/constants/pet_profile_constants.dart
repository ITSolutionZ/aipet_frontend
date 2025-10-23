/// Pet Profile 관련 상수 정의
///
/// 하드코딩된 텍스트와 설정값들을 중앙 집중식으로 관리합니다.
class PetProfileConstants {
  // Private constructor to prevent instantiation
  PetProfileConstants._();

  /// 탭 관련 상수
  static const int tabCount = 5;
  static const int basicInfoTabIndex = 0;
  static const int healthTabIndex = 1;
  static const int nutritionTabIndex = 2;
  static const int activityTabIndex = 3;
  static const int adoptionTabIndex = 4;

  /// 탭 제목 (일본어)
  static const List<String> tabTitles = ['基本情報', '健康', '栄養', '活動', '家族探し'];

  /// 성별 옵션 (일본어)
  static const List<String> genderOptions = ['オス', 'メス'];

  /// 성별 옵션 (영어 - 백엔드 호환용)
  static const List<String> genderOptionsEn = ['Male', 'Female'];

  /// 펫 타입 아이콘 매핑
  static const Map<String, String> petTypeIcons = {
    'dog': '🐕',
    'cat': '🐱',
    'bird': '🐦',
    'hamster': '🐹',
    'rabbit': '🐰',
    'turtle': '🐢',
    'default': '🐾',
  };

  /// 펫 타입 이름 매핑 (일본어)
  static const Map<String, String> petTypeNames = {
    'dog': '犬',
    'cat': '猫',
    'bird': '鳥',
    'hamster': 'ハムスター',
    'rabbit': 'うさぎ',
    'turtle': '亀',
    'default': 'ペット',
  };

  /// 성별 표시명 매핑 (일본어)
  static const Map<String, String> genderDisplayNames = {
    'male': 'オス',
    'female': 'メス',
    'オス': 'オス',
    'メス': 'メス',
    'default': '不明',
  };

  // ✅ 공통 메시지는 AppTexts 사용
  // loadingMessage → AppTexts.loading
  // successMessage → AppTexts.success
  // saveSuccessMessage → AppTexts.saved
  // deleteSuccessMessage → AppTexts.deleted
  // nameRequiredMessage, weightInvalidMessage 등 → AppTexts 참조
  
  /// Feature-specific 메시지만 유지
  static const String petNotFoundMessage = 'ペットが見つかりません';
  static const String noPermissionMessage = '権限がありません';
  static const String editModeEntered = '編集モードに入りました';
  static const String editModeExited = '編集モードを終了しました';
  static const String cancelEditMessage = '編集をキャンセルしました';
  static const String imageChangeSuccess = '画像を変更しました';
  static const String imageChangeError = '画像の変更に失敗しました';
  static const String weightPositiveMessage = '体重は0より大きい値を入力してください';

  // 공통 메시지 대체 가이드:
  // - loadingMessage -> AppTexts.loading
  // - errorMessage -> AppTexts.error  
  // - successMessage -> AppTexts.success
  // - saveSuccessMessage -> AppTexts.saved
  // - saveErrorMessage -> AppTexts.saveError
  // - deleteSuccessMessage -> AppTexts.deleted
  // - deleteErrorMessage -> AppTexts.deleteError
  // - deleteConfirmMessage -> AppTexts.deleteConfirm
  // - imageUploadSuccess -> AppTexts.uploaded
  // - imageUploadError -> AppTexts.uploadError
  // - nameRequiredMessage -> AppTexts.nameHint
  // - weightInvalidMessage -> AppTexts.weightHint

  /// UI 레이블
  static const String editLabel = '編集';
  static const String saveLabel = '保存';
  static const String cancelLabel = 'キャンセル';
  static const String deleteLabel = '削除';
  static const String shareLabel = '共有';
  static const String backLabel = '戻る';
  static const String homeLabel = 'ホーム';

  /// 필드 레이블
  static const String nameLabel = '名前';
  static const String typeLabel = '種類';
  static const String breedLabel = '品種';
  static const String genderLabel = '性別';
  static const String weightLabel = '体重';
  static const String birthDateLabel = '誕生日';
  static const String ageLabel = '年齢';
  static const String appearanceLabel = '外見';
  static const String microchipLabel = 'マイクロチップ';
  static const String caretakerLabel = '家族';

  /// 힌트 텍스트
  static const String nameHint = '名前を入力してください';
  static const String weightHint = '体重を入力してください';
  static const String appearanceHint = 'ペットの外見について説明してください';
  static const String microchipHint = 'マイクロチップIDを入力してください';

  /// 버튼 텍스트
  static const String changeImageButton = '写真を変更';
  static const String takePhotoButton = 'カメラで撮影';
  static const String selectFromGalleryButton = 'ギャラリーから選択';
  static const String goHomeButton = 'ホームに戻る';

  /// 다이얼로그 제목
  static const String editNameDialogTitle = '名前編集';
  static const String editGenderDialogTitle = '性別編集';
  static const String editWeightDialogTitle = '体重編集';
  static const String editAppearanceDialogTitle = '外見編集';
  static const String editMicrochipDialogTitle = 'マイクロチップ編集';
  static const String deleteConfirmDialogTitle = '削除確認';

  /// 상태 표시
  static const String registeredStatus = '登録済み';
  static const String unregisteredStatus = '未登録';
  static const String managerStatus = '管理者';

  /// 기본값
  static const String defaultPetName = 'ペット';
  static const String defaultBreed = '不明';
  static const String defaultAppearance = '未設定';
  static const double defaultWeight = 0.0;
  static const bool defaultNeutered = false;

  /// 이미지 관련 설정
  static const double profileImageSize = 120.0;
  static const double profileImageBorderWidth = 2.0;
  static const int maxAppearanceLength = 200;
  static const int maxNameLength = 20;

  /// 애니메이션 설정
  static const Duration tabAnimationDuration = Duration(milliseconds: 300);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 200);

  /// 권장 산책 시간 (분 단위)
  static const int smallDogWalkTime = 30;
  static const int mediumDogWalkTime = 45;
  static const int largeDogWalkTime = 60;
  static const int catWalkTime = 20;
  static const int otherAnimalWalkTime = 15;

  /// 몸무게 기준 (kg)
  static const double smallDogWeightLimit = 10.0;
  static const double mediumDogWeightLimit = 25.0;

  /// 색상 관련 상수
  static const double iconBackgroundOpacity = 0.1;
  static const double borderOpacity = 0.3;

  /// 폼 검증 관련
  static const int minNameLength = 1;
  static const int maxNameLengthValidation = 20;
  static const double minWeight = 0.1;
  static const double maxWeight = 100.0;
}
