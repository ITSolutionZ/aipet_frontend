import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hospital_registration_provider.g.dart';

/// 등록된 동물병원 여부 확인 프로바이더
///
/// TODO: 유저 프로필 구현 후 유저의 등록된 병원 정보를 확인하도록 변경 예정
/// 현재는 유저 프로필이 미구현 상태이므로 항상 false 반환 (배너 항상 표시)
@riverpod
bool hasRegisteredHospital(HasRegisteredHospitalRef ref) {
  // 유저 프로필 미구현으로 인해 현재는 항상 false 반환
  // 추후 유저 프로필에서 등록된 병원 정보를 가져와서 확인
  return false;

  // TODO: 유저 프로필 구현 후 아래 로직으로 변경
  // final userProfile = ref.watch(userProfileProvider);
  // return userProfile.registeredHospital != null;
}
