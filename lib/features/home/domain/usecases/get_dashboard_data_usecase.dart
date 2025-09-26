import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:aipet_frontend/shared/core/base_usecase.dart';

/// 📊 대시보드 데이터 조회 UseCase
class GetDashboardDataUseCase extends BaseUseCase<HomeDashboardEntity, GetDashboardDataParams> {
  final HomeRepository _homeRepository;

  GetDashboardDataUseCase(this._homeRepository);

  @override
  Future<Result<HomeDashboardEntity>> execute(GetDashboardDataParams params) async {
    return await _homeRepository.getDashboardData(params.userId);
  }
}

/// 📊 대시보드 데이터 조회 파라미터
class GetDashboardDataParams {
  final String userId;

  const GetDashboardDataParams({
    required this.userId,
  });
}