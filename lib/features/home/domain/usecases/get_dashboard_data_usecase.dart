import '../entities/home_dashboard_entity.dart';
import '../repositories/home_repository.dart';

class GetDashboardDataUseCase {
  final HomeRepository repository;

  GetDashboardDataUseCase(this.repository);

  Future<HomeDashboardEntity> call() async {
    return repository.getDashboardData();
  }
}
