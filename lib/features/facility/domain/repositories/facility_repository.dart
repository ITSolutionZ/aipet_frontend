import '../facility.dart';

abstract class FacilityRepository {
  Future<List<Facility>> getNearbyFacilities();
  Future<List<Facility>> searchFacilities(String query);
  Future<List<Facility>> getFacilitiesByType(FacilityType type);
  Future<Facility?> getFacilityById(String id);
  Future<List<Facility>> getFacilitiesInRadius(
    double latitude,
    double longitude,
    double radius,
  );
  Future<void> setCurrentLocation(
    double latitude,
    double longitude,
    String address,
  );
}
