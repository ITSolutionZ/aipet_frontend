/// 🎯 AI キャッシュ戦略
///
/// データ種類ごとに最適なキャッシュタイムアウトを定義します。
class AiCacheStrategy {
  /// 静的データ(カテゴリ、キーワード): 長期キャッシュ
  /// - 変更頻度: 低
  /// - データサイズ: 小
  /// - 推奨タイムアウト: 24時間
  static const categoriesTimeout = Duration(hours: 24);
  static const keywordsTimeout = Duration(hours: 24);
  static const suggestionsTimeout = Duration(hours: 12);

  /// 動的データ(チャット履歴): 短期キャッシュ
  /// - 変更頻度: 高
  /// - データサイズ: 大
  /// - 推奨タイムアウト: 5-10分
  static const chatHistoryTimeout = Duration(minutes: 10);
  static const recentMessagesTimeout = Duration(minutes: 5);

  /// お気に入り: 中期キャッシュ
  /// - 変更頻度: 中
  /// - データサイズ: 中
  /// - 推奨タイムアウト: 1時間
  static const favoritesTimeout = Duration(hours: 1);
  static const favoriteQAsTimeout = Duration(hours: 1);

  /// セッション関連: 短期キャッシュ
  /// - 変更頻度: 高
  /// - データサイズ: 小-中
  /// - 推奨タイムアウト: 15分
  static const chatSessionsTimeout = Duration(minutes: 15);
  static const currentSessionTimeout = Duration(minutes: 30);

  /// APIレスポンス: 超短期キャッシュ
  /// - 変更頻度: 非常に高
  /// - データサイズ: 可変
  /// - 推奨タイムアウト: 2-5分
  static const apiResponseTimeout = Duration(minutes: 2);
  static const tempDataTimeout = Duration(minutes: 5);

  /// キャッシュキーのプレフィックス
  static const String categoriesKey = 'ai_categories';
  static const String keywordsKey = 'ai_keywords';
  static const String suggestionsKey = 'ai_suggestions';
  static const String chatHistoryKey = 'ai_chat_history';
  static const String recentMessagesKey = 'ai_recent_messages';
  static const String favoritesKey = 'ai_favorites';
  static const String favoriteQAsKey = 'ai_favorite_qas';
  static const String chatSessionsKey = 'ai_chat_sessions';
  static const String currentSessionKey = 'ai_current_session';

  /// キャッシュキーごとのタイムアウトを取得
  static Duration getTimeoutForKey(String key) {
    if (key.startsWith(categoriesKey)) return categoriesTimeout;
    if (key.startsWith(keywordsKey)) return keywordsTimeout;
    if (key.startsWith(suggestionsKey)) return suggestionsTimeout;
    if (key.startsWith(chatHistoryKey)) return chatHistoryTimeout;
    if (key.startsWith(recentMessagesKey)) return recentMessagesTimeout;
    if (key.startsWith(favoritesKey)) return favoritesTimeout;
    if (key.startsWith(favoriteQAsKey)) return favoriteQAsTimeout;
    if (key.startsWith(chatSessionsKey)) return chatSessionsTimeout;
    if (key.startsWith(currentSessionKey)) return currentSessionTimeout;

    // デフォルト: 短期キャッシュ
    return apiResponseTimeout;
  }

  /// キャッシュの優先度 (メモリが不足した時の削除順序)
  static int getPriorityForKey(String key) {
    // 優先度: 高い数値 = 重要 (削除されにくい)
    if (key.startsWith(categoriesKey)) return 10; // 静的データは最重要
    if (key.startsWith(keywordsKey)) return 10;
    if (key.startsWith(currentSessionKey)) return 9; // 現在のセッションは重要
    if (key.startsWith(favoritesKey)) return 8; // お気に入りは重要
    if (key.startsWith(favoriteQAsKey)) return 8;
    if (key.startsWith(suggestionsKey)) return 7;
    if (key.startsWith(chatSessionsKey)) return 6;
    if (key.startsWith(recentMessagesKey)) return 5;
    if (key.startsWith(chatHistoryKey)) return 4;

    // デフォルト: 低優先度
    return 1;
  }

  /// キャッシュサイズの推定 (概算)
  static int estimateSizeInBytes(String key, dynamic data) {
    if (data == null) return 0;

    // シンプルな推定: JSON文字列のバイト数
    try {
      final jsonString = data.toString();
      return jsonString.length * 2; // UTF-16エンコーディング想定
    } catch (e) {
      return 1024; // デフォルト: 1KB
    }
  }
}

/// キャッシュエントリーのメタデータ
class CacheMetadata {
  final String key;
  final DateTime timestamp;
  final Duration timeout;
  final int priority;
  final int sizeBytes;

  const CacheMetadata({
    required this.key,
    required this.timestamp,
    required this.timeout,
    required this.priority,
    required this.sizeBytes,
  });

  /// キャッシュが有効期限切れかどうか
  bool get isExpired {
    final now = DateTime.now();
    return now.difference(timestamp) >= timeout;
  }

  /// 残り時間
  Duration get remainingTime {
    final now = DateTime.now();
    final elapsed = now.difference(timestamp);
    final remaining = timeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 有効期限切れまでの割合 (0.0 ~ 1.0)
  double get expirationProgress {
    final now = DateTime.now();
    final elapsed = now.difference(timestamp);
    return (elapsed.inMilliseconds / timeout.inMilliseconds).clamp(0.0, 1.0);
  }
}
