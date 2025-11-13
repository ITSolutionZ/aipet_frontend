import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';

/// 시설 목록 화면의 비즈니스 로직을 관리하는 컨트롤러
class FacilityListController {
  final WidgetRef ref;
  final BuildContext context;

  FacilityListController(this.ref, this.context);

  /// 초기 데이터 로드
  Future<void> loadInitialData() async {
    try {
      final facilityList = await ref.read(facilityListProvider.future);
      final searchResults = ref.read(searchResultsProvider.notifier);

      searchResults.setSearchResults(facilityList);
    } catch (error) {
      _showErrorMessage('시설 데이터를 불러오는데 실패했습니다: $error');
    }
  }

  /// 검색어 변경 처리
  Future<void> handleSearchChanged(String query) async {
    try {
      ref.read(searchQueryProvider.notifier).setQuery(query);

      final facilityListNotifier = ref.read(facilityListProvider.notifier);
      final searchResults = ref.read(searchResultsProvider.notifier);

      final results = facilityListNotifier.search(query);
      searchResults.setSearchResults(results);
    } catch (error) {
      _showErrorMessage('검색 중 오류가 발생했습니다: $error');
    }
  }

  /// 필터 변경 처리
  Future<void> handleFilterChanged(FacilityType? type) async {
    try {
      ref.read(selectedFacilityTypeProvider.notifier).setType(type);

      final facilityListNotifier = ref.read(facilityListProvider.notifier);
      final searchResults = ref.read(searchResultsProvider.notifier);
      final query = ref.read(searchQueryProvider);

      List<Facility> results;
      if (type != null) {
        results = facilityListNotifier.getByType(type);
        if (query.isNotEmpty) {
          results = results
              .where(
                (facility) =>
                    facility.name.toLowerCase().contains(query.toLowerCase()) ||
                    (facility.description?.toLowerCase() ?? '').contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
        }
      } else {
        results = facilityListNotifier.search(query);
      }

      searchResults.setSearchResults(results);
    } catch (error) {
      _showErrorMessage('필터링 중 오류가 발생했습니다: $error');
    }
  }

  /// 정렬 변경 처리
  Future<void> handleSortChanged(String sortType) async {
    try {
      final searchResults = ref.read(searchResultsProvider.notifier);

      switch (sortType) {
        case 'distance':
          searchResults.sortByDistance();
          break;
        case 'rating':
          searchResults.sortByRating();
          break;
        case 'name':
          searchResults.sortByName();
          break;
        default:
          _showErrorMessage('알 수 없는 정렬 기준입니다');
          return;
      }

      _showSuccessMessage('정렬이 적용되었습니다');
    } catch (error) {
      _showErrorMessage('정렬 중 오류가 발생했습니다: $error');
    }
  }

  /// 즐겨찾기 토글 처리
  Future<void> handleFavoriteToggle(String facilityId) async {
    try {
      final facilityList = ref.read(facilityListProvider.notifier);
      await facilityList.toggleFavorite(facilityId);

      await refreshSearchResults();
      _showSuccessMessage('즐겨찾기가 업데이트되었습니다');
    } catch (error) {
      _showErrorMessage('즐겨찾기 설정 중 오류가 발생했습니다: $error');
    }
  }

  /// 검색 결과 새로고침
  Future<void> refreshSearchResults() async {
    try {
      final query = ref.read(searchQueryProvider);
      final selectedType = ref.read(selectedFacilityTypeProvider);

      final facilityListNotifier = ref.read(facilityListProvider.notifier);
      final searchResults = ref.read(searchResultsProvider.notifier);

      List<Facility> results;
      if (selectedType != null) {
        results = facilityListNotifier.getByType(selectedType);
        if (query.isNotEmpty) {
          results = results
              .where(
                (facility) =>
                    facility.name.toLowerCase().contains(query.toLowerCase()) ||
                    (facility.description?.toLowerCase() ?? '').contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
        }
      } else {
        results = facilityListNotifier.search(query);
      }

      searchResults.setSearchResults(results);
    } catch (error) {
      _showErrorMessage('검색 결과 새로고침 중 오류가 발생했습니다: $error');
    }
  }

  /// 모든 필터 초기화
  Future<void> clearAllFilters() async {
    try {
      ref.read(searchQueryProvider.notifier).setQuery('');
      ref.read(selectedFacilityTypeProvider.notifier).setType(null);

      await loadInitialData();
      _showSuccessMessage('모든 필터가 초기화되었습니다');
    } catch (error) {
      _showErrorMessage('필터 초기화 중 오류가 발생했습니다: $error');
    }
  }

  /// 시설 타입별 라벨 반환
  String getFacilityTypeLabel(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return '動物病院';
      case FacilityType.veterinary:
        return '獣医院';
      case FacilityType.grooming:
        return 'トリミング';
      case FacilityType.petShop:
        return 'ペットショップ';
      case FacilityType.petStore:
        return 'ペット用品店';
      case FacilityType.dogRun:
        return 'ドッグラン';
      case FacilityType.park:
        return '公園';
      case FacilityType.petPark:
        return 'ペット公園';
      case FacilityType.cafe:
        return 'ペットカフェ';
      case FacilityType.hotel:
        return 'ペットホテル';
      case FacilityType.petFriendlyAccommodation:
        return 'ペット可宿泊施設';
      case FacilityType.training:
        return '訓練所';
      case FacilityType.other:
        return 'その他';
    }
  }

  /// 검색 상태 확인
  bool get hasActiveFilters {
    final query = ref.read(searchQueryProvider);
    final selectedType = ref.read(selectedFacilityTypeProvider);
    return query.isNotEmpty || selectedType != null;
  }

  /// 성공 메시지 표시
  /// ✅ Shared SnackBarService 사용
  void _showSuccessMessage(String message) {
    if (context.mounted) {
      SnackBarService.showSuccess(context, message);
    }
  }

  /// 에러 메시지 표시
  /// ✅ Shared SnackBarService 사용
  void _showErrorMessage(String message) {
    if (context.mounted) {
      SnackBarService.showError(context, message);
    }
  }
}
