import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/facility_providers.dart';
import '../../domain/facility.dart';

/// 시설 목록 화면의 비즈니스 로직을 관리하는 컨트롤러
class FacilityListController {
  final WidgetRef ref;
  final BuildContext context;

  FacilityListController(this.ref, this.context);

  /// 초기 데이터 로드
  Future<void> loadInitialData() async {
    try {
      final facilityList = ref.read(facilityListNotifierProvider);
      final searchResults = ref.read(searchResultsNotifierProvider.notifier);

      searchResults.setSearchResults(facilityList);
    } catch (error) {
      _showErrorMessage('시설 데이터를 불러오는데 실패했습니다: $error');
    }
  }

  /// 검색어 변경 처리
  Future<void> handleSearchChanged(String query) async {
    try {
      ref.read(searchQueryNotifierProvider.notifier).setQuery(query);

      final facilityList = ref.read(facilityListNotifierProvider.notifier);
      final searchResults = ref.read(searchResultsNotifierProvider.notifier);

      final results = facilityList.search(query);
      searchResults.setSearchResults(results);
    } catch (error) {
      _showErrorMessage('검색 중 오류가 발생했습니다: $error');
    }
  }

  /// 필터 변경 처리
  Future<void> handleFilterChanged(FacilityType? type) async {
    try {
      ref.read(selectedFacilityTypeNotifierProvider.notifier).setType(type);

      final facilityList = ref.read(facilityListNotifierProvider.notifier);
      final searchResults = ref.read(searchResultsNotifierProvider.notifier);
      final query = ref.read(searchQueryNotifierProvider);

      List<Facility> results;
      if (type != null) {
        results = facilityList.getByType(type);
        if (query.isNotEmpty) {
          results = results
              .where(
                (facility) =>
                    facility.name.toLowerCase().contains(query.toLowerCase()) ||
                    facility.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
        }
      } else {
        results = facilityList.search(query);
      }

      searchResults.setSearchResults(results);
    } catch (error) {
      _showErrorMessage('필터링 중 오류가 발생했습니다: $error');
    }
  }

  /// 정렬 변경 처리
  Future<void> handleSortChanged(String sortType) async {
    try {
      final searchResults = ref.read(searchResultsNotifierProvider.notifier);

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
      final facilityList = ref.read(facilityListNotifierProvider.notifier);
      facilityList.toggleFavorite(facilityId);

      await refreshSearchResults();
      _showSuccessMessage('즐겨찾기가 업데이트되었습니다');
    } catch (error) {
      _showErrorMessage('즐겨찾기 설정 중 오류가 발생했습니다: $error');
    }
  }

  /// 검색 결과 새로고침
  Future<void> refreshSearchResults() async {
    try {
      final query = ref.read(searchQueryNotifierProvider);
      final selectedType = ref.read(selectedFacilityTypeNotifierProvider);

      final facilityList = ref.read(facilityListNotifierProvider.notifier);
      final searchResults = ref.read(searchResultsNotifierProvider.notifier);

      List<Facility> results;
      if (selectedType != null) {
        results = facilityList.getByType(selectedType);
        if (query.isNotEmpty) {
          results = results
              .where(
                (facility) =>
                    facility.name.toLowerCase().contains(query.toLowerCase()) ||
                    facility.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
        }
      } else {
        results = facilityList.search(query);
      }

      searchResults.setSearchResults(results);
    } catch (error) {
      _showErrorMessage('검색 결과 새로고침 중 오류가 발생했습니다: $error');
    }
  }

  /// 모든 필터 초기화
  Future<void> clearAllFilters() async {
    try {
      ref.read(searchQueryNotifierProvider.notifier).setQuery('');
      ref.read(selectedFacilityTypeNotifierProvider.notifier).setType(null);

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
        return '동물병원';
      case FacilityType.grooming:
        return '트리밍';
    }
  }

  /// 검색 상태 확인
  bool get hasActiveFilters {
    final query = ref.read(searchQueryNotifierProvider);
    final selectedType = ref.read(selectedFacilityTypeNotifierProvider);
    return query.isNotEmpty || selectedType != null;
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
