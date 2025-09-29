import 'package:aipet_frontend/features/facility/data/facility_providers.dart';
import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/shared/factories/facility_factory.dart';
import 'package:aipet_frontend/shared/foundation/controllers/base_facility_controller.dart';
import 'package:aipet_frontend/shared/services/facility_error_handler.dart';
import 'package:flutter/material.dart';

/// 시설 상세 화면의 비즈니스 로직을 관리하는 컨트롤러
class FacilityDetailController extends BaseFacilityController {
  FacilityDetailController(super.ref, super.context);

  /// 시설 정보 로드
  Future<Facility?> loadFacilityById(String facilityId) async {
    try {
      final facilityList = ref.read(facilityListNotifierProvider);
      return facilityList.firstWhere(
        (facility) => facility.id == facilityId,
        orElse: () => FacilityFactory.createDefault(facilityId),
      );
    } catch (error) {
      FacilityErrorHandler.handleLoadError(error, context);
      return null;
    }
  }

  /// 연락처 추가 처리
  Future<void> handleAddToContacts(Facility facility) async {
    try {
      final confirmed = await _showAddContactDialog(facility);
      if (confirmed == true) {
        // 실제 구현에서는 연락처 저장 로직 구현
        await _saveToContacts(facility);
        showSuccessMessage('${facility.name}が連絡先に追加されました。');
      }
    } catch (error) {
      if (context.mounted) {
        FacilityErrorHandler.handleContactError(error, context);
      }
    }
  }

  /// 예약 처리
  Future<void> handleBooking(Facility facility) async {
    try {
      // 예약 화면으로 이동 또는 예약 로직 실행
      showSuccessMessage('${facility.name}の予約ページに移動します。');
    } catch (error) {
      FacilityErrorHandler.handleBookingError(error, context);
    }
  }

  /// 즐겨찾기 토글
  Future<void> handleFavoriteToggle(String facilityId) async {
    try {
      final facilityList = ref.read(facilityListNotifierProvider.notifier);
      facilityList.toggleFavorite(facilityId);

      final facility = await loadFacilityById(facilityId);
      if (facility != null) {
        final message = facility.isFavorite
            ? 'お気に入りに追加されました。'
            : 'お気に入りから削除されました。';
        showSuccessMessage(message);
      }
    } catch (error) {
      if (context.mounted) {
        FacilityErrorHandler.handleFavoriteError(error, context);
      }
    }
  }

  /// 전화 걸기
  Future<void> handlePhoneCall(String phoneNumber) async {
    try {
      // 실제 구현에서는 url_launcher를 사용해서 전화 걸기
      showInfoMessage('電話をかける: $phoneNumber');
    } catch (error) {
      FacilityErrorHandler.handleContactError(error, context);
    }
  }

  /// 이메일 보내기
  Future<void> handleSendEmail(String email) async {
    try {
      // 실제 구현에서는 url_launcher를 사용해서 이메일 앱 열기
      showInfoMessage('メールを送信: $email');
    } catch (error) {
      FacilityErrorHandler.handleContactError(error, context);
    }
  }

  /// 지도에서 보기
  Future<void> handleShowOnMap(Facility facility) async {
    try {
      // 실제 구현에서는 지도 앱으로 이동하거나 내장 지도 표시
      showInfoMessage('${facility.name}の位置を地図で確認します。');
    } catch (error) {
      FacilityErrorHandler.handleMapError(error, context);
    }
  }

  /// 연락처 추가 확인 다이얼로그
  Future<bool?> _showAddContactDialog(Facility facility) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('連絡先追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('以下の連絡先を追加しますか？'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('電話: ${facility.phone}'),
                    Text('メール: ${facility.email}'),
                    Text('住所: ${facility.address}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  /// 연락처 저장 (실제 구현 필요)
  Future<void> _saveToContacts(Facility facility) async {
    // 실제 구현에서는 contacts_service 패키지 등을 사용해서 연락처 저장
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // BaseFacilityController에서 상속받은 메시지 메서드들을 사용하므로
  // 중복된 메시지 표시 메서드들을 제거했습니다.
}
