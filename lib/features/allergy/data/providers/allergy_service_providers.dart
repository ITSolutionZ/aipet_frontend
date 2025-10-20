import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/domain.dart';
import '../services/openai_allergy_analysis_service.dart';

part 'allergy_service_providers.g.dart';

/// 알레르기 분석 서비스 Provider
@riverpod
AllergyAnalysisService allergyAnalysisService(Ref ref) {
  return OpenAIAllergyAnalysisService();
}
