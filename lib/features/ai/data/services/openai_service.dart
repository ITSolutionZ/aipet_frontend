import 'package:dio/dio.dart';
import '../../../../app/config/app_config.dart';
import '../../../pet_registor/domain/entities/pet_profile_entity.dart';
import 'pet_content_filter_service.dart';

/// OpenAI API와 통신하는 서비스
class OpenAIService {
  late final Dio _dio;
  final PetContentFilterService _contentFilter = PetContentFilterService();
  
  OpenAIService() {
    _dio = Dio();
    _dio.options.baseUrl = 'https://api.openai.com/v1';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  /// OpenAI ChatGPT API를 사용하여 메시지에 대한 응답 생성
  Future<String> generateResponse(String message, {PetProfileEntity? petContext}) async {
    final apiKey = AppConfig.current.openaiApiKey;
    
    if (apiKey.isEmpty) {
      throw Exception('OpenAI API key is not configured');
    }

    // ペット関連コンテンツ検証 (펫 컨텍스트가 있으면 스킵)
    if (petContext == null) {
      final validationResult = await _contentFilter.validatePetContent(message);
      if (!validationResult.isValid) {
      return '''申し訳ございません。私はペット専門のAIアシスタントです。🐶🐱

${_translateReasonToJapanese(validationResult.reason)}

以下のような内容についてご質問ください：
• ペットの健康と病気について
• フードと栄養管理
• 行動矯正とトレーニング
• グルーミングとケア
• ペット用品と環境
• 保護と譲渡相談

具体的な状況を教えていただければ、より正確なサポートを提供できます！😊''';
      }
    }

    try {
      final response = await _dio.post(
        '/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': _buildSystemPrompt(petContext)
            },
            {
              'role': 'user',
              'content': message,
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        },
      );

      final data = response.data;
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        throw Exception('No response from OpenAI API');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid OpenAI API key');
      } else if (e.response?.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to get response from OpenAI: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  /// 検証理由を日本語に翻訳 (필터 서비스와 동일한 메시지)
  String _translateReasonToJapanese(String reason) {
    switch (reason) {
      case 'ペットと関連していない話題です':
        return 'ペットと関連していない話題です';
      case 'ペットに関連する内容を含めてご質問ください':
        return 'ペットに関連する内容を含めてご질問ください';
      case 'ペットに関連していないご質問です':
        return 'ペットに関連していないご質問です';
      case 'ペットに関連する内容をより具体的にご質問ください':
        return 'ペットに関連する内容をより具体的にご質問ください';
      case 'ペット関連のご質問です':
        return 'ペット関連のご質問です';
      case '内容が短すぎます。ペット関連の具体的な質問を入力してください':
        return '内容が短すぎます。ペット関連の具体的な質問を入力してください';
      default:
        return 'ペットに関連する内容を含めてご質問ください';
    }
  }
  
  /// システムプロンプトを構築
  String _buildSystemPrompt(PetProfileEntity? petContext) {
    String basePrompt = '''あなたはペット専門のAIアシスタントです。
ペットの健康、行動、トレーニング、栄養、一般的なケアに関する質問にのみお答えください。
回答は親しみやすく、わかりやすく書いてください。
深刻な健康問題が疑われる場合は、必ず獣医師への相談をお勧めしてください。

重要：ペットに関係のない質問（政治、経済、エンターテイメント、ゲーム、料理など）には答えず、
"ペットに関する質問のみお答えできます"と回答してください。''';
    
    if (petContext != null) {
      final age = petContext.age;
      final breedInfo = petContext.breed != null ? '（品種：${petContext.breed}）' : '';
      final birthYear = petContext.birthDate.year;
      final birthMonth = petContext.birthDate.month;
      final birthDay = petContext.birthDate.day;
      final createdYear = petContext.createdAt.year;
      final createdMonth = petContext.createdAt.month;
      final createdDay = petContext.createdAt.day;
      
      // 추가 정보가 있는 경우 포함
      String additionalDetails = '';
      if (petContext.additionalInfo != null && petContext.additionalInfo!.isNotEmpty) {
        additionalDetails = '\n・追加情報：';
        petContext.additionalInfo!.forEach((key, value) {
          additionalDetails += '\n  - $key: $value';
        });
      }
      
      basePrompt += '''

【相談対象のペット情報】
・名前：${petContext.name}
・種類：${petContext.typeName}$breedInfo
・年齢：$age歳（生年月日：$birthYear年$birthMonth月$birthDay日）
・登録日：$createdYear年$createdMonth月$createdDay日$additionalDetails

初回の挨拶では、${petContext.name}の名前を呼んでペット専門アシスタントとして親しみやすく挨拶してください。
このペットの詳細情報を考慮して、より具体的で個別化されたアドバイスを提供してください。
${petContext.name}の年齢（$age歳）、種類（${petContext.typeName}）に応じた特性を踏まえた専門的な回答をお願いします。

例：
- 年齢に応じた健康管理やケア方法
- 種類別の行動特性や注意点
- 個体の特徴を考慮したアドバイス''';
    } else {
      basePrompt += '''

初回の挨拶では、ペット専門アシスタントとして親しみやすく挨拶してください。
ペット全般に関する基本的なアドバイスを提供し、より具体的な相談のためにペット情報の登録をお勧めしてください。''';
    }
    
    return basePrompt;
  }
}