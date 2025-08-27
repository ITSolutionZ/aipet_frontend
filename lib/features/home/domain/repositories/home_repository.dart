import '../../../pet_registor/domain/entities/pet_profile_entity.dart';
import '../entities/home_dashboard_entity.dart';

abstract class HomeRepository {
  Future<HomeDashboardEntity> getDashboardData();
  Future<WeatherInfo> getCurrentWeather();
  Future<List<AppointmentSummary>> getUpcomingAppointments();
  Future<HealthSummary> getPetHealthSummary();
  Future<WalkSummary> getWalkSummary();
  Future<List<PetProfileEntity>> getPetProfiles();
  Stream<String> getCurrentTimeStream();
}
