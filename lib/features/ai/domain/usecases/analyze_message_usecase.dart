import 'package:aipet_frontend/features/ai/domain/entities/ai_analysis_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/shared/core/domain/base_usecase_enhanced.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 🔍 메시지 분석 UseCase
class AnalyzeMessageUseCase
    extends BaseUseCase<AiAnalysisEntity, AnalyzeMessageParams> {
  final AiRepository _repository;

  AnalyzeMessageUseCase(this._repository);

  @override
  Future<Result<AiAnalysisEntity>> call(AnalyzeMessageParams params) async {
    return _repository.analyzeMessage(
      message: params.message,
      petId: params.petId,
      context: params.context,
    );
  }
}

/// 🔍 메시지 분석 파라미터
class AnalyzeMessageParams {
  final String message;
  final String? petId;
  final Map<String, dynamic>? context;

  const AnalyzeMessageParams({required this.message, this.petId, this.context});
}
