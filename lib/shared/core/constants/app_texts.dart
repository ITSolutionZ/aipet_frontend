/// 앱 전체에서 사용하는 공통 텍스트 상수들 (일본어)
class AppTexts {
  AppTexts._();

  // ========== 공통 버튼 텍스트 ==========

  /// 기본 버튼
  static const String save = '保存';
  static const String cancel = 'キャンセル';
  static const String confirm = '確認';
  static const String delete = '削除';
  static const String edit = '編集';
  static const String add = '追加';
  static const String remove = '削除';
  static const String close = '閉じる';
  static const String back = '戻る';
  static const String next = '次へ';
  static const String previous = '前へ';
  static const String complete = '完了';
  static const String skip = 'スキップ';
  static const String retry = '再試行';
  static const String refresh = '更新';
  static const String search = '検索';
  static const String filter = 'フィルター';
  static const String sort = '並び替え';
  static const String clear = 'クリア';
  static const String reset = 'リセット';
  static const String apply = '適用';
  static const String done = '完了';
  static const String ok = 'OK';
  static const String yes = 'はい';
  static const String no = 'いいえ';

  // ========== 온보딩 관련 텍스트 ==========

  /// 온보딩 버튼
  static const String nextButton = '次へ';
  static const String startButton = '始める';
  static const String skipButton = 'Skip';

  // ========== 스케줄링 관련 텍스트 ==========

  /// 스케줄링 메뉴
  static const String feedingSchedule = '食事スケジュール';
  static const String feedingRecords = '食事記録';
  static const String feedingAnalysis = '食事分析';
  static const String healthManagement = '健康管理';
  static const String training = '学習';
  static const String watering = '給水';

  /// 스케줄링 설명
  static const String feedingScheduleDescription = 'ペットの食事時間と量を管理します';
  static const String feedingRecordsDescription = 'これまでの食事記録を確認できます';
  static const String feedingAnalysisDescription = '食事パターンと健康状態を分析します';
  static const String healthManagementDescription = 'ワクチンと健康診断を管理します';
  static const String trainingDescription = 'トレーニング';
  static const String wateringDescription = '水分補給';

  /// 급여 관련
  static const String morningMeal = '朝食';
  static const String lunchMeal = '昼食';
  static const String dinnerMeal = '夕食';
  static const String addFeedingRecord = '食事記録を追加';
  static const String feedingRecordSaved = '食事記録を保存しました';
  static const String feedingRecordAdded = '食事記録が追加されました';
  static const String feedingRecordUpdated = '食事記録が更新されました';
  static const String feedingRecordDeleted = '食事記録が削除されました';

  /// 알림 관련
  static const String alarmSettings = 'アラーム設定';
  static const String alarmEnabled = 'アラームを有効にしました';
  static const String alarmDisabled = 'アラームを無効にしました';
  static const String scheduleNotification = 'スケジュール通知を受け取りますか？';
  static const String morningMealTime = '朝食の時間です';
  static const String morningMealOverdue = 'ペットの朝食時間が過ぎました';
  static const String healthCheckupTime = '健康診断の時期です';
  static const String healthCheckupOverdue = '前回の健康診断から90日が経過しました';

  // ========== 상태 메시지 ==========

  /// 로딩 상태
  static const String loading = '読み込み中...';
  static const String saving = '保存中...';
  static const String processing = '処理中...';
  static const String uploading = 'アップロード中...';
  static const String downloading = 'ダウンロード中...';
  static const String syncing = '同期中...';
  static const String connecting = '接続中...';

  /// 성공 메시지
  static const String success = '成功しました';
  static const String saved = '保存しました';
  static const String updated = '更新しました';
  static const String deleted = '削除しました';
  static const String added = '追加しました';
  static const String completed = '完了しました';
  static const String uploaded = 'アップロードしました';
  static const String downloaded = 'ダウンロードしました';
  static const String synced = '同期しました';
  static const String connected = '接続しました';

  /// 에러 메시지
  static const String error = 'エラーが発生しました';
  static const String networkError = 'ネットワークエラーが発生しました';
  static const String serverError = 'サーバーエラーが発生しました';
  static const String unknownError = '予期しないエラーが発生しました';
  static const String connectionError = '接続エラーが発生しました';
  static const String timeoutError = 'タイムアウトが発生しました';
  static const String permissionError = '権限がありません';
  static const String validationError = '入力内容に問題があります';
  static const String notFoundError = '見つかりませんでした';
  static const String unauthorizedError = '認証が必要です';
  static const String forbiddenError = 'アクセスが拒否されました';

  // ========== 폼 관련 메시지 ==========

  /// 필수 입력
  static const String required = '必須項目です';
  static const String requiredField = 'この項目は必須です';
  static const String pleaseEnter = '入力してください';
  static const String pleaseSelect = '選択してください';

  /// 유효성 검사
  static const String invalidFormat = '正しい形式で入力してください';
  static const String tooShort = '短すぎます';
  static const String tooLong = '長すぎます';
  static const String invalidEmail = '正しいメールアドレスを入力してください';
  static const String invalidPassword = 'パスワードの形式が正しくありません';
  static const String passwordMismatch = 'パスワードが一致しません';
  static const String invalidNumber = '数値を入力してください';
  static const String invalidDate = '正しい日付を入力してください';
  static const String invalidUrl = '正しいURLを入力してください';

  // ========== 네트워크 관련 메시지 ==========

  /// 연결 상태
  static const String noInternetConnection = 'インターネット接続を確認してください';
  static const String connectionLost = '接続が失われました';
  static const String connectionRestored = '接続が復旧しました';
  static const String offlineMode = 'オフラインモード';
  static const String onlineMode = 'オンラインモード';

  /// API 관련
  static const String apiError = 'APIエラーが発生しました';
  static const String apiTimeout = 'APIタイムアウトが発生しました';
  static const String apiRateLimit = 'API呼び出し制限に達しました';
  static const String apiUnauthorized = 'API認証に失敗しました';

  // ========== 파일 관련 메시지 ==========

  /// 파일 업로드
  static const String fileUploadSuccess = 'ファイルがアップロードされました';
  static const String fileUploadFailed = 'ファイルのアップロードに失敗しました';
  static const String fileTooLarge = 'ファイルサイズが大きすぎます';
  static const String invalidFileType = 'サポートされていないファイル形式です';
  static const String fileNotFound = 'ファイルが見つかりません';

  /// 파일 다운로드
  static const String fileDownloadSuccess = 'ファイルがダウンロードされました';
  static const String fileDownloadFailed = 'ファイルのダウンロードに失敗しました';
  static const String fileSizeExceeded = 'ファイルサイズが制限を超えています';

  // ========== 인증 관련 메시지 ==========

  /// 로그인
  static const String loginSuccess = 'ログインしました';
  static const String loginFailed = 'ログインに失敗しました';
  static const String logoutSuccess = 'ログアウトしました';
  static const String sessionExpired = 'セッションが期限切れです';

  /// 회원가입
  static const String signupSuccess = '会員登録が完了しました';
  static const String signupFailed = '会員登録に失敗しました';
  static const String emailAlreadyExists = 'このメールアドレスは既に使用されています';
  static const String usernameAlreadyExists = 'このユーザー名は既に使用されています';

  /// 비밀번호
  static const String passwordChanged = 'パスワードが変更されました';
  static const String passwordResetSent = 'パスワードリセットメールを送信しました';
  static const String passwordResetFailed = 'パスワードリセットに失敗しました';

  // ========== 펫 관련 메시지 ==========

  /// 펫 등록
  static const String petRegistered = 'ペットが登録されました';
  static const String petRegistrationFailed = 'ペットの登録に失敗しました';
  static const String petUpdated = 'ペット情報が更新されました';
  static const String petUpdateFailed = 'ペット情報の更新に失敗しました';
  static const String petDeleted = 'ペットが削除されました';
  static const String petDeleteFailed = 'ペットの削除に失敗しました';
  static const String petNotFound = 'ペットが見つかりません';

  /// 펫 건강
  static const String healthRecordAdded = '健康記録が追加されました';
  static const String healthRecordUpdated = '健康記録が更新されました';
  static const String healthRecordDeleted = '健康記録が削除されました';
  static const String vaccinationReminder = 'ワクチン接種の時期です';
  static const String checkupReminder = '健康診断の時期です';

  // ========== 산책 관련 메시지 ==========

  /// 산책 기록
  static const String walkStarted = '散歩を開始しました';
  static const String walkCompleted = '散歩が完了しました';
  static const String walkPaused = '散歩を一時停止しました';
  static const String walkResumed = '散歩を再開しました';
  static const String walkCancelled = '散歩をキャンセルしました';
  static const String walkSaved = '散歩記録が保存されました';
  static const String walkDeleted = '散歩記録が削除されました';

  // ========== 알림 관련 메시지 ==========

  /// 알림 설정
  static const String notificationEnabled = '通知が有効になりました';
  static const String notificationDisabled = '通知が無効になりました';
  static const String notificationPermissionRequired = '通知の許可が必要です';
  static const String notificationPermissionDenied = '通知の許可が拒否されました';

  /// 알림 내용
  static const String feedingTime = '餌やりの時間です';
  static const String walkTime = '散歩の時間です';
  static const String medicationTime = '薬の時間です';
  static const String appointmentTime = '予約の時間です';

  // ========== 설정 관련 메시지 ==========

  /// 설정 변경
  static const String settingsSaved = '設定が保存されました';
  static const String settingsReset = '設定がリセットされました';
  static const String cacheCleared = 'キャッシュがクリアされました';
  static const String dataExported = 'データがエクスポートされました';
  static const String dataImported = 'データがインポートされました';

  // ========== 공유 관련 메시지 ==========

  /// 펫 공유
  static const String petShared = 'ペットが共有されました';
  static const String shareLinkGenerated = '共有リンクが生成されました';
  static const String shareLinkExpired = '共有リンクの有効期限が切れました';
  static const String sharePermissionGranted = '共有権限が付与されました';
  static const String sharePermissionRevoked = '共有権限が取り消されました';

  // ========== 기타 메시지 ==========

  /// 일반
  static const String noData = 'データがありません';
  static const String noResults = '結果が見つかりません';
  static const String tryAgain = 'もう一度お試しください';
  static const String contactSupport = 'サポートにお問い合わせください';
  static const String comingSoon = '近日公開予定です';
  static const String underMaintenance = 'メンテナンス中です';

  /// 확인 메시지
  static const String confirmDelete = '削除してもよろしいですか？';
  static const String confirmLogout = 'ログアウトしてもよろしいですか？';
  static const String confirmReset = 'リセットしてもよろしいですか？';
  static const String confirmCancel = 'キャンセルしてもよろしいですか？';
  static const String unsavedChanges = '保存されていない変更があります';
}
