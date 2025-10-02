import 'package:aipet_frontend/features/ai/domain/entities/ai_analysis_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 🔍 메시지 분석 UseCase
class AnalyzeMessageUseCase {
  final AiRepository _repository;

  const AnalyzeMessageUseCase(this._repository);

  /// 메시지 분석 실행
  Future<Result<List<AiAnalysisEntity>>> call(AnalyzeMessageParams params) async {
    try {
      final result = await _repository.analyzeMessage(
        message: params.message,
        petId: params.petId,
        context: params.context,
      );

      if (result.isSuccess) {
        return Result.success('メッセージを分析しました', [result.dataOrNull!]);
      } else {
        return Result.failure('メッセージの分析に失敗しました');
      }
    } catch (error) {
      return Result.failure('メッセージの分析に失敗しました: ${error.toString()}');
    }
  }
}

/// 🔍 메시지 분석 파라미터
class AnalyzeMessageParams {
  final String message;
  final String? petId;
  final Map<String, dynamic>? context;

  const AnalyzeMessageParams({required this.message, this.petId, this.context});
}
