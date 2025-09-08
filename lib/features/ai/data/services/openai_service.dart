import 'package:dio/dio.dart';

import '../../../../app/config/app_config.dart';
import '../../../pet_registor/pet_registor.dart';
import 'pet_content_filter_service.dart';

/// OpenAI API와 통신하는 서비스
class OpenAIService {
  late final Dio _dio;
  final PetContentFilterService _contentFilter = PetContentFilterService();
  
  // API 안정성을 위한 설정
  static const int _maxRetries = 3;
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 60);

  OpenAIService() {
    _dio = Dio();
    _dio.options.baseUrl = 'https://api.openai.com/v1';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = _connectTimeout;
    _dio.options.receiveTimeout = _receiveTimeout;
    
    // 인터셉터 추가로 요청/응답 로깅 및 에러 처리 개선
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // API 키 확인
          if (!options.headers.containsKey('Authorization')) {
            final apiKey = AppConfig.current.openaiApiKey;
            if (apiKey.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $apiKey';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // 상세한 에러 정보 로깅 (프로덕션에서는 실제 로깅 프레임워크 사용)
          // TODO: Replace with proper logging framework in production
          // ignore: avoid_print
          print('OpenAI API Error: ${error.message}');
          if (error.response != null) {
            // ignore: avoid_print
            print('Status: ${error.response?.statusCode}');
            // ignore: avoid_print
            print('Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  /// OpenAI ChatGPT API를 사용하여 메시지에 대한 응답 생성 (재시도 로직 포함)
  Future<String> generateResponse(
    String message, {
    PetProfileEntity? petContext,
  }) async {
    final apiKey = AppConfig.current.openaiApiKey;

    if (apiKey.isEmpty) {
      throw Exception('OpenAI API key is not configured');
    }

    // ペット関連コンテンツ検証 (펫 컨텍스트가 있으면 스킵)
    if (petContext == null) {
      final validationResult = await _contentFilter.validatePetContent(message);
      if (!validationResult.isValid) {
        return '''こんにちは！私はペット専門のAIアシスタントです。🐶🐱

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

    return _executeWithRetry(() async {
      final response = await _dio.post(
        '/chat/completions',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': _buildSystemPrompt(petContext)},
            {'role': 'user', 'content': message},
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
    });
  }

  /// 재시도 로직이 포함된 API 호출 실행
  Future<T> _executeWithRetry<T>(Future<T> Function() apiCall) async {
    int retryCount = 0;
    late Exception lastException;

    while (retryCount < _maxRetries) {
      try {
        return await apiCall();
      } on DioException catch (e) {
        lastException = _handleDioException(e);
        
        // 재시도하지 않을 에러들
        if (e.response?.statusCode == 401 || // Invalid API key
            e.response?.statusCode == 403 || // Forbidden
            e.response?.statusCode == 400) { // Bad request
          throw lastException;
        }
        
        // 429(Rate limit) 또는 5xx 서버 에러의 경우 재시도
        final statusCode = e.response?.statusCode;
        if (statusCode == 429 || (statusCode != null && statusCode >= 500)) {
          retryCount++;
          if (retryCount < _maxRetries) {
            final delay = Duration(seconds: retryCount * 2); // 지수 백오프
            // TODO: Replace with proper logging framework in production
            // ignore: avoid_print
            print('Retrying API call in ${delay.inSeconds} seconds... (attempt $retryCount/$_maxRetries)');
            await Future.delayed(delay);
            continue;
          }
        }
        
        throw lastException;
      } catch (e) {
        lastException = Exception('Unexpected error: $e');
        retryCount++;
        if (retryCount < _maxRetries) {
          final delay = Duration(seconds: retryCount * 2);
          // TODO: Replace with proper logging framework in production
          // ignore: avoid_print
          print('Retrying API call in ${delay.inSeconds} seconds... (attempt $retryCount/$_maxRetries)');
          await Future.delayed(delay);
          continue;
        }
        throw lastException;
      }
    }
    
    throw lastException;
  }

  /// Dio 예외를 사용자 친화적인 메시지로 변환
  Exception _handleDioException(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return Exception('OpenAI API key가 유효하지 않습니다. 설정을 확인해주세요.');
      case 429:
        return Exception('API 요청 한도를 초과했습니다. 잠시 후 다시 시도해주세요.');
      case 500:
      case 502:
      case 503:
      case 504:
        return Exception('OpenAI 서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.');
      case null:
        if (e.type == DioExceptionType.connectionTimeout) {
          return Exception('연결 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          return Exception('응답 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.');
        } else if (e.type == DioExceptionType.connectionError) {
          return Exception('네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인해주세요.');
        }
        return Exception('네트워크 오류가 발생했습니다: ${e.message}');
      default:
        return Exception('OpenAI API 오류 (${e.response?.statusCode}): ${e.message}');
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
      final breedInfo = petContext.breed != null
          ? '（品種：${petContext.breed}）'
          : '';
      final birthYear = petContext.birthDate.year;
      final birthMonth = petContext.birthDate.month;
      final birthDay = petContext.birthDate.day;
      final createdYear = petContext.createdAt.year;
      final createdMonth = petContext.createdAt.month;
      final createdDay = petContext.createdAt.day;

      // 추가 정보가 있는 경우 포함
      String additionalDetails = '';
      if (petContext.additionalInfo != null &&
          petContext.additionalInfo!.isNotEmpty) {
        additionalDetails = '\n・追加情報：';
        petContext.additionalInfo!.forEach((key, value) {
          additionalDetails += '\n  - $key: $value';
        });
      }

      basePrompt +=
          '''

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
