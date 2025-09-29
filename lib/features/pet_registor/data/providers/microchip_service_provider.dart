import 'package:aipet_frontend/features/pet_registor/data/services/microchip_service_impl.dart';
import 'package:aipet_frontend/features/pet_registor/domain/services/microchip_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 마이크로칩 서비스 프로바이더
final microchipServiceProvider = Provider<MicrochipService>((ref) {
  return MicrochipServiceImpl();
});
