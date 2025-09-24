import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/entities/home_dashboard_entity.dart';

class GetDashboardDataUseCase {
  final HomeRepository repository;

  GetDashboardDataUseCase(this.repository);

  Future<HomeDashboardEntity> call() async {
    return repository.getDashboardData();
  }
}
