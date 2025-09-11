import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/microchip_service.dart';
import '../services/microchip_service_impl.dart';

/// 마이크로칩 서비스 Provider
final microchipServiceProvider = Provider<MicrochipService>((ref) {
  return MicrochipServiceImpl();
});