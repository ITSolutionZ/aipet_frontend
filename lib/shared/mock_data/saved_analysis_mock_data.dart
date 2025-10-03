import 'package:aipet_frontend/features/allergy/domain/entities/saved_analysis_entity.dart';

/// 저장된 알레르기 분석 Mock 데이터
class SavedAnalysisMockData {
  static final List<SavedAnalysisEntity> mockAnalyses = [
    SavedAnalysisEntity(
      id: 'analysis-001',
      petId: '1',
      petName: 'MAX',
      analysisResult: {
        'allergyProducts': 2,
        'nonAllergyProducts': 1,
        'suspectedIngredients': ['トウモロコシ', '鶏肉ミール', '小麦'],
        'analysis': '''
アレルギー反応があった「ロイヤルカナン ドッグフード 小型犬用」には、一般的に鶏肉、小麦、とうもろこしなどが含まれている可能性があります。一方、「CIAO ちゅ〜る まぐろ味」にはこれらの原料ではなく、主に魚介類が使用されていることが考えられます。これらの成分は犬においてアレルギーを引き起こすことが知られているため、アレルギーの疑いがある原料として特定しました。
''',
        'confidence': 0.85,
        'recommendations': [
          '獣医師に相談し、正確なアレルギーテストを受けることをお勧めします',
          '鶏肉、小麦、とうもろこしを含まないドッグフードを試してみてください',
          'フード切り替えは徐々に行い、反応を観察してください',
        ],
      },
      savedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SavedAnalysisEntity(
      id: 'analysis-002',
      petId: '1',
      petName: 'MAX',
      analysisResult: {
        'allergyProducts': 3,
        'nonAllergyProducts': 2,
        'suspectedIngredients': ['牛肉', '大豆', '乳製品'],
        'analysis': '''
分析の結果、牛肉、大豆、乳製品がアレルギーの疑いがある原料として特定されました。これらは一般的な犬のアレルギー原料として知られています。
''',
        'confidence': 0.75,
        'recommendations': [
          '牛肉、大豆、乳製品を避けたフードを選択してください',
          '代替タンパク源として魚や鹿肉を検討してください',
        ],
      },
      savedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    SavedAnalysisEntity(
      id: 'analysis-003',
      petId: '2',
      petName: 'Luna',
      analysisResult: {
        'allergyProducts': 1,
        'nonAllergyProducts': 3,
        'suspectedIngredients': ['サーモン'],
        'analysis': '''
Lunaのアレルギー分析結果では、サーモンが疑わしい原料として特定されました。魚アレルギーは猫では比較的まれですが、発生する可能性があります。
''',
        'confidence': 0.65,
        'recommendations': [
          'サーモンを含まないキャットフードに変更してみてください',
          '他の魚類でも反応が出るか観察してください',
        ],
      },
      savedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];
}
