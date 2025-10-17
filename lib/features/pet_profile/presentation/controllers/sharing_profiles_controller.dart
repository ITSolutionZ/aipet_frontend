import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sharing_profiles_controller.freezed.dart';
part 'sharing_profiles_controller.g.dart';

/// 프로필 공유 상태 관리
@riverpod
class SharingProfilesController extends _$SharingProfilesController {
  @override
  SharingProfilesState build() {
    return const SharingProfilesState();
  }

  /// QR 코드 생성
  String generateQRCode(PetProfileEntity pet) {
    return 'pet_profile:${pet.id}:${pet.name}';
  }

  /// QR 코드 스캔 처리
  Map<String, dynamic> handleScannedCode(String code) {
    if (code.startsWith('pet_profile:')) {
      return {
        'success': true,
        'message': 'QRコードをスキャンしました: $code',
        'data': code,
      };
    } else {
      return {'success': false, 'error': '無効なQRコードです'};
    }
  }

  /// 프로필 공유 링크 생성
  String generateShareLink(PetProfileEntity pet) {
    // Mock implementation
    return 'https://aipet.app/share/${pet.id}';
  }

  /// 프로필 공유
  Future<void> shareProfile(PetProfileEntity pet) async {
    // final shareLink = generateShareLink(pet);
    // 실제 구현에서는 share_plus 패키지 등을 사용
    // await Share.share(shareLink);
  }
}

/// 프로필 공유 상태
@freezed
class SharingProfilesState with _$SharingProfilesState {
  const factory SharingProfilesState({
    @Default(false) bool isLoading,
    String? error,
  }) = _SharingProfilesState;

  const SharingProfilesState._();
}
