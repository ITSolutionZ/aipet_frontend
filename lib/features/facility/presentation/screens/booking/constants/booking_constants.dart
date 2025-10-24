/// 予約関連の定数定義
class BookingConstants {
  BookingConstants._();

  // ===== 時間スロット =====

  /// 予約可能な開始時刻
  static const int startHour = 9;

  /// 予約可能な終了時刻
  static const int endHour = 17;

  /// 時間スロットの総数
  static const int totalTimeSlots = 9; // 9:00 ~ 17:00

  /// 時間スロット生成
  static List<String> get timeSlots {
    return List.generate(
      totalTimeSlots,
      (index) => '${_formatHour(startHour + index)}:00',
    );
  }

  static String _formatHour(int hour) {
    return hour.toString().padLeft(2, '0');
  }

  // ===== 曜日表示 =====

  /// 日本語曜日リスト
  static const List<String> weekdaysJa = [
    '日',
    '月',
    '火',
    '水',
    '木',
    '金',
    '土',
  ];

  // ===== 施設タイプ別サービス =====

  /// 병원/病院 サービス
  static const List<String> hospitalServices = [
    '一般診療',
    '予防接種',
    '健康診断',
    '内科診療',
    '外科手術',
    '応急処置',
    '歯科診療',
    '眼科診療',
    '皮膚科診療',
    '整形外科診療',
    '産科診療',
    '去勢・避妊手術',
    'ワクチン接種',
    '血液検査',
    'X線撮影',
    '超音波検査',
  ];

  /// 미용실/美容室 サービス
  static const List<String> beautyServices = [
    '基本美容',
    '全身美容',
    '爪のケア',
    '入浴',
    'ドライング',
    '毛のカット',
    'ネイルケア',
    '耳のクリーニング',
    'スタイリング',
    'パーマ',
    'カラーリング',
    '特別スタイル',
    '全体パッケージ',
    '部分美容',
    '涙やけケア',
    '抜け毛ケア',
    '香水処理',
    'スパトリートメント',
  ];

  /// 카페/カフェ サービス
  static const List<String> cafeServices = [
    '基本利用',
    '特別メニュー',
    'イベント参加',
    'ペットフレンドリーカフェ',
    'ペットおやつ',
    'ペットおもちゃ',
    'ペットアクセサリー',
    'ペットフード',
    'ペット栄養剤',
    'ペットシャンプー',
    'ペット寝具',
    'ペット服',
    'ペットリード',
    'ペットバッグ',
    'ペットハウス',
    'ペット遊び場',
    'ペット写真撮影',
    'ペットパーティー',
  ];

  /// 호텔/ホテル サービス
  static const List<String> hotelServices = [
    '1泊',
    '2泊',
    '長期宿泊',
    '特別ケア',
    '1日ペンション',
    '3日ペンション',
    '1週間ペンション',
    '長期ペンション',
    '特別管理',
    '散歩サービス',
    '入浴サービス',
    '給餌サービス',
    '遊びサービス',
    '訓練サービス',
    '健康管理サービス',
    '医療サービス',
    '美容サービス',
    '写真撮影サービス',
  ];

  /// 施設タイプに応じたサービスリスト取得
  static List<String> getServicesForFacilityType(String facilityType) {
    switch (facilityType) {
      case '病院':
      case '병원':
        return hospitalServices;
      case '美容室':
      case '미용실':
        return beautyServices;
      case 'カフェ':
      case '카페':
        return cafeServices;
      case 'ホテル':
      case '호텔':
        return hotelServices;
      default:
        return [];
    }
  }

  // ===== バリデーションメッセージ =====

  static const String errorEmptyName = '予約者名を入力してください';
  static const String errorEmptyPhone = '連絡先を入力してください';
  static const String errorEmptyService = 'サービスを選択してください';
  static const String errorEmptyPet = 'ペットを選択してください';
  static const String errorEmptyDateTime = '予約日時を選択してください';

  // ===== UI テキスト =====

  static const String titleBookerInfo = '予約者情報';
  static const String titlePetInfo = 'ペット情報';
  static const String titleServiceSelect = 'サービス選択';
  static const String titleDateTime = '予約日時';
  static const String titleNotes = '特記事項';

  static const String labelName = '予約者名';
  static const String labelPhone = '連絡先';
  static const String labelNotes = '特記事項';

  static const String hintName = '予約者名を入力してください';
  static const String hintPhone = '010-0000-0000';
  static const String hintNotes = '予約時の参考事項を入力してください（任意）';
  static const String hintSelectService = 'サービスを選択してください';
  static const String hintSelectDateTime = '日時を選択してください';

  static const String buttonBook = '予約する';
  static const String buttonSelectPet = 'ペットを選択';

  // ===== その他 =====

  /// カレンダー表示週数
  static const int calendarWeeks = 2;

  /// デフォルト電話番号
  static const String defaultPhone = '010-0000-0000';
}
