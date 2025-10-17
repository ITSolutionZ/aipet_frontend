import 'package:aipet_frontend/features/allergy/data/services/openai_allergy_analysis_service.dart';
import 'package:aipet_frontend/features/allergy/domain/services/allergy_analysis_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'allergy_service_providers.g.dart';

/// 알레르기 분석 서비스 Provider
@riverpod
AllergyAnalysisService allergyAnalysisService(Ref ref) {
  return OpenAIAllergyAnalysisService();
}
