import 'package:aipet_frontend/features/pet_registor/data/services/pet_validation_service_impl.dart';
import 'package:aipet_frontend/features/pet_registor/domain/services/pet_validation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 펫 검증 서비스 프로바이더
final petValidationServiceProvider = Provider<PetValidationService>((ref) {
  return PetValidationServiceImpl();
});
