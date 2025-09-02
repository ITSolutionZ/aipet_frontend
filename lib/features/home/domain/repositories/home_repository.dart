import '../../../pet_registor/domain/entities/pet_profile_entity.dart';
import '../../data/models/weather_model.dart';
import '../entities/home_dashboard_entity.dart';

abstract class HomeRepository {
  Future<HomeDashboardEntity> getDashboardData();
  Future<WeatherData?> getCurrentWeather();
  Future<List<PetProfileEntity>> getPetProfiles();
  Future<WalkSummary> getWalkSummary();
  Future<HealthSummary> getPetHealthSummary();
  Future<List<AppointmentSummary>> getUpcomingAppointments();
}
