import 'local_database_service.dart';

/// AI 채팅 로컬 스토리지 서비스
class LocalAiService {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  /// AI 채팅 메시지 저장
  Future<String> saveChatMessage({
    required String conversationId,
    required String message,
    required bool isUser,
    Map<String, dynamic>? metadata,
  }) async {
    final db = await _dbService.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert(
      'ai_chats',
      {
        'id': id,
        'conversation_id': conversationId,
        'message': message,
        'is_user': isUser ? 1 : 0,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': metadata?.toString(),
      },
    );
    return id;
  }

  /// 대화 내역 조회
  Future<List<Map<String, dynamic>>> getChatHistory(String conversationId, {int limit = 100}) async {
    final db = await _dbService.database;
    return await db.query(
      'ai_chats',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  /// 모든 대화 목록 조회
  Future<List<Map<String, dynamic>>> getAllConversations() async {
    final db = await _dbService.database;
    final results = await db.rawQuery('''
      SELECT conversation_id, MAX(timestamp) as last_message_time, COUNT(*) as message_count
      FROM ai_chats
      GROUP BY conversation_id
      ORDER BY last_message_time DESC
    ''');
    return results;
  }

  /// 대화 삭제
  Future<bool> deleteConversation(String conversationId) async {
    final db = await _dbService.database;
    final count = await db.delete(
      'ai_chats',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
    return count > 0;
  }

  /// AI 설정 저장 (SharedPreferences 사용)
  Future<bool> saveAiSettings(Map<String, dynamic> settings) async {
    return await _dbService.saveJsonToPrefs('ai_settings', settings);
  }

  /// AI 설정 로드
  Future<Map<String, dynamic>?> loadAiSettings() async {
    return await _dbService.loadJsonFromPrefs('ai_settings');
  }

  /// AI 추천 카테고리 저장
  Future<bool> saveAiCategories(List<Map<String, dynamic>> categories) async {
    return await _dbService.saveListToPrefs('ai_categories', categories);
  }

  /// AI 추천 카테고리 로드
  Future<List<Map<String, dynamic>>?> loadAiCategories() async {
    return await _dbService.loadListFromPrefs('ai_categories');
  }

  /// AI 키워드 저장
  Future<bool> saveAiKeywords(List<String> keywords) async {
    final data = keywords.map((k) => {'keyword': k}).toList();
    return await _dbService.saveListToPrefs('ai_keywords', data);
  }

  /// AI 키워드 로드
  Future<List<String>> loadAiKeywords() async {
    final data = await _dbService.loadListFromPrefs('ai_keywords');
    if (data != null) {
      return data.map((item) => item['keyword'] as String).toList();
    }
    return [];
  }

  /// 최근 검색어 저장
  Future<bool> saveRecentSearches(List<String> searches) async {
    final data = searches.map((s) => {'search': s, 'timestamp': DateTime.now().toIso8601String()}).toList();
    return await _dbService.saveListToPrefs('ai_recent_searches', data);
  }

  /// 최근 검색어 로드
  Future<List<String>> loadRecentSearches() async {
    final data = await _dbService.loadListFromPrefs('ai_recent_searches');
    if (data != null) {
      // 타임스탬프 기준으로 정렬
      data.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      return data.map((item) => item['search'] as String).take(10).toList();
    }
    return [];
  }
}