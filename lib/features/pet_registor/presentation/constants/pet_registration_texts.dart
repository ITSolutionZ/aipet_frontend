/// 펫 등록 관련 UI 텍스트 상수
///
/// 일본어 UI 텍스트를 중앙 관리하여 일관성과 유지보수성을 향상시킵니다.
class PetRegistrationTexts {
  // 화면 제목
  static const String petTypeSelection = 'ペットの種類を選択';
  static const String whoDoYouLiveWith = '今、誰と暮らしていますか?';
  static const String whatKindOfPet = 'どんな子ですか？';
  static const String enterName = '名前を教えてください';
  static const String petAnniversary = 'ペットとの記念日は？';
  static const String petAnniversarySummary = 'ペットの記念日は？';
  static const String petSizeWeight = 'ペットのサイズと体重は？';
  static const String registrationComplete = '登録完了';

  // 버튼 텍스트
  static const String next = '次へ';
  static const String back = '戻る';
  static const String complete = '完了';
  static const String cancel = 'キャンセル';
  static const String save = '保存';
  static const String noTypeAvailable = '種類がない';
  static const String customPetTypeComingSoon = 'カスタムペットタイプの機能は準備中です';

  // 입력 필드 관련
  static const String nameHint = 'ペットの名前を入力してください';
  static const String nameRequired = '名前を入力してください';
  static const String nameMinLength = '名前は2文字以上で入力してください';
  static const String nameMaxLength = '名前は20文字以内で入力してください';

  // 펫 타입
  static const String dog = '犬';
  static const String cat = '猫';
  static const String bird = '鳥';
  static const String hamster = 'ハムスター';
  static const String rabbit = 'うさぎ';
  static const String turtle = '亀';

  // 에러 메시지
  static const String networkError = 'ネットワークエラーが発生しました';
  static const String unknownError = '予期しないエラーが発生しました';
  static const String petNotFound = 'ペットが見つかりません';
  static const String registrationFailed = '登録に失敗しました';

  // 성공 메시지
  static const String registrationSuccess = 'ペットの登録が完了しました';
  static const String updateSuccess = 'ペット情報が更新されました';
  static const String deleteSuccess = 'ペットが削除されました';

  // 진행 상태
  static const String loading = '読み込み中...';
  static const String saving = '保存中...';
  static const String processing = '処理中...';

  // Private constructor to prevent instantiation
  PetRegistrationTexts._();
}
