import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/facility_providers.dart';
import '../../domain/facility.dart';

/// 시설 상세 화면의 비즈니스 로직을 관리하는 컨트롤러
class FacilityDetailController {
  final WidgetRef ref;
  final BuildContext context;

  FacilityDetailController(this.ref, this.context);

  /// 시설 정보 로드
  Future<Facility?> loadFacilityById(String facilityId) async {
    try {
      final facilityList = ref.read(facilityListNotifierProvider);
      return facilityList.firstWhere(
        (facility) => facility.id == facilityId,
        orElse: () => _createDefaultFacility(facilityId),
      );
    } catch (error) {
      _showErrorMessage('시설 정보를 불러오는데 실패했습니다: $error');
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
        _showSuccessMessage('${facility.name}이(가) 연락처에 추가되었습니다.');
      }
    } catch (error) {
      _showErrorMessage('연락처 추가 중 오류가 발생했습니다: $error');
    }
  }

  /// 예약 처리
  Future<void> handleBooking(Facility facility) async {
    try {
      // 예약 화면으로 이동 또는 예약 로직 실행
      _showSuccessMessage('${facility.name} 예약 페이지로 이동합니다.');
    } catch (error) {
      _showErrorMessage('예약 처리 중 오류가 발생했습니다: $error');
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
          ? '즐겨찾기에 추가되었습니다.' 
          : '즐겨찾기에서 제거되었습니다.';
        _showSuccessMessage(message);
      }
    } catch (error) {
      _showErrorMessage('즐겨찾기 설정 중 오류가 발생했습니다: $error');
    }
  }

  /// 전화 걸기
  Future<void> handlePhoneCall(String phoneNumber) async {
    try {
      // 실제 구현에서는 url_launcher를 사용해서 전화 걸기
      _showInfoMessage('전화 걸기: $phoneNumber');
    } catch (error) {
      _showErrorMessage('전화 걸기 중 오류가 발생했습니다: $error');
    }
  }

  /// 이메일 보내기
  Future<void> handleSendEmail(String email) async {
    try {
      // 실제 구현에서는 url_launcher를 사용해서 이메일 앱 열기
      _showInfoMessage('이메일 보내기: $email');
    } catch (error) {
      _showErrorMessage('이메일 보내기 중 오류가 발생했습니다: $error');
    }
  }

  /// 지도에서 보기
  Future<void> handleShowOnMap(Facility facility) async {
    try {
      // 실제 구현에서는 지도 앱으로 이동하거나 내장 지도 표시
      _showInfoMessage('${facility.name}의 위치를 지도에서 확인합니다.');
    } catch (error) {
      _showErrorMessage('지도 표시 중 오류가 발생했습니다: $error');
    }
  }

  /// 기본 시설 정보 생성 (더미 데이터)
  Facility _createDefaultFacility(String facilityId) {
    return Facility(
      id: facilityId,
      name: 'Shinny Fur Saloon',
      description: '전문적인 펫 트리밍 서비스',
      address: '70 North Street',
      phone: '079 1234 7777',
      email: 'contactshinnyfur@gmail.com',
      type: FacilityType.grooming,
      rating: 4.6,
      reviewCount: 230,
      imagePath: 'assets/images/placeholder.png',
      isFavorite: false,
      hasHistory: false,
    );
  }

  /// 연락처 추가 확인 다이얼로그
  Future<bool?> _showAddContactDialog(Facility facility) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('연락처 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('다음 연락처를 추가하시겠습니까?'),
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
                    Text('전화: ${facility.phone}'),
                    Text('이메일: ${facility.email}'),
                    Text('주소: ${facility.address}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('추가'),
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

  /// 성공 메시지 표시
  void _showSuccessMessage(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 정보 메시지 표시
  void _showInfoMessage(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 에러 메시지 표시
  void _showErrorMessage(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}