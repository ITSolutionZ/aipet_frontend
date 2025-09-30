import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

abstract class FacilityRepository {
  Future<Result<List<Facility>>> getNearbyFacilities();
  Future<Result<List<Facility>>> searchFacilities(String query);
  Future<Result<List<Facility>>> getFacilitiesByType(FacilityType type);
  Future<Result<Facility>> getFacilityById(String id);
  Future<Result<List<Facility>>> getFacilitiesInRadius(
    double latitude,
    double longitude,
    double radius,
  );
  Future<Result<void>> setCurrentLocation(double latitude, double longitude, String address);
}
