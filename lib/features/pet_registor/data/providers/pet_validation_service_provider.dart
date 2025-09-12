import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/pet_validation_service.dart';
import '../services/pet_validation_service_impl.dart';

/// 펫 검증 서비스 Provider
final petValidationServiceProvider = Provider<PetValidationService>((ref) {
  return PetValidationServiceImpl();
});