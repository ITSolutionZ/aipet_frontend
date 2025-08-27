import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../data/facility_providers.dart';
import '../../domain/facility.dart';
import '../controllers/facility_list_controller.dart';
import '../widgets/facility_card.dart';
import '../widgets/facility_filter_chip.dart';
import '../widgets/facility_search_bar.dart';

class FacilityListScreenRefactored extends ConsumerStatefulWidget {
  const FacilityListScreenRefactored({super.key});

  @override
  ConsumerState<FacilityListScreenRefactored> createState() =>
      _FacilityListScreenRefactoredState();
}

class _FacilityListScreenRefactoredState
    extends ConsumerState<FacilityListScreenRefactored> {
  final TextEditingController _searchController = TextEditingController();
  late FacilityListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FacilityListController(ref, context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsNotifierProvider);
    final searchQuery = ref.watch(searchQueryNotifierProvider);
    final selectedType = ref.watch(selectedFacilityTypeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchSection(),
          _buildFilterSection(),
          _buildResultsInfo(searchResults, searchQuery, selectedType),
          _buildFacilityList(searchResults),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('근처 시설'),
      backgroundColor: AppColors.pointOffWhite,
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          onSelected: _controller.handleSortChanged,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'distance', child: Text('距離順')),
            const PopupMenuItem(value: 'rating', child: Text('評価順')),
            const PopupMenuItem(value: 'name', child: Text('名前順')),
          ],
          child: const Icon(Icons.sort),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FacilitySearchBar(
        controller: _searchController,
        onChanged: _controller.handleSearchChanged,
        onSearch: () => _controller.handleSearchChanged(_searchController.text),
        onClear: () {
          _searchController.clear();
          _controller.handleSearchChanged('');
        },
        hintText: '施設名で検索...',
      ),
    );
  }

  Widget _buildFilterSection() {
    final selectedType = ref.watch(selectedFacilityTypeNotifierProvider);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FacilityFilterChip(
            label: '全て',
            isSelected: selectedType == null,
            onTap: () => _controller.handleFilterChanged(null),
          ),
          const SizedBox(width: 8),
          for (final type in FacilityType.values)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FacilityFilterChip(
                label: _controller.getFacilityTypeLabel(type),
                isSelected: selectedType == type,
                onTap: () => _controller.handleFilterChanged(type),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsInfo(
    List<Facility> searchResults,
    String searchQuery,
    FacilityType? selectedType,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            '${searchResults.length}件の施設',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          if (_controller.hasActiveFilters)
            TextButton(
              onPressed: () {
                _searchController.clear();
                _controller.clearAllFilters();
              },
              child: Text(
                'リセット',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFacilityList(List<Facility> searchResults) {
    return Expanded(
      child: searchResults.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final facility = searchResults[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: FacilityCard(
                    facility: facility,
                    onFavoriteToggle: () =>
                        _controller.handleFavoriteToggle(facility.id),
                    onTap: () => _navigateToDetail(facility),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.pointDark.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _controller.hasActiveFilters
                ? '検索条件に一致する施設がありません'
                : '施設を見つけることができません',
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '他の条件で検索してください',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Facility facility) {
    context.push('${AppRouter.facilityDetailRoute}/${facility.id}');
  }
}
