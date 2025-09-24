import 'package:aipet_frontend/features/onboarding/domain/services/microchip_service.dart';
import 'package:aipet_frontend/shared/services/microchip_service_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 마이크로칩 서비스 Provider
final microchipServiceProvider = Provider<MicrochipService>((ref) {
  return MicrochipServiceImpl();
});
