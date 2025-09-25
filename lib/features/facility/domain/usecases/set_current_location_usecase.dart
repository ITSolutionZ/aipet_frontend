import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';

class SetCurrentLocationUseCase {
  final FacilityRepository repository;

  SetCurrentLocationUseCase(this.repository);

  Future<void> call(double latitude, double longitude, String address) async {
    final result = await repository.setCurrentLocation(
      latitude,
      longitude,
      address,
    );
    if (!result.isSuccess) {
      throw Exception(
        result.errorOrNull?.toString() ?? 'Failed to set current location',
      );
    }
  }
}
