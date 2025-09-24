import 'package:aipet_frontend/features/onboarding/domain/services/pet_validation_service.dart';
import 'package:aipet_frontend/shared/services/pet_validation_service_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 펫 검증 서비스 Provider
final petValidationServiceProvider = Provider<PetValidationService>((ref) {
  return PetValidationServiceImpl();
});
