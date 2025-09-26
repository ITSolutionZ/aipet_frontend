import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/features/home/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:aipet_frontend/features/home/data/repositories/home_repository_impl.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_dashboard_controller.g.dart';

// HomeRepository Provider (임시 - 실제로는 providers 폴더에 있어야 함)
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl();
});

/// 🏠 홈 대시보드 컨트롤러
@riverpod
class HomeDashboardController extends _$HomeDashboardController {
  late final GetDashboardDataUseCase _getDashboardDataUseCase;

  @override
  FutureOr<HomeDashboardEntity> build() async {
    // UseCase 의존성 주입 (실제로는 Provider를 통해 주입되어야 함)
    _getDashboardDataUseCase = GetDashboardDataUseCase(ref.read(homeRepositoryProvider));

    return await _loadDashboardData();
  }

  /// 대시보드 데이터 로드
  Future<HomeDashboardEntity> _loadDashboardData() async {
    try {
      final params = GetDashboardDataParams(userId: 'current_user');
      final result = await _getDashboardDataUseCase.execute(params);

      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      // 에러 시 빈 대시보드 반환
      return HomeDashboardEntity.empty();
    }
  }

  /// 대시보드 새로고침
  Future<void> refresh() async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadDashboardData());
  }
}