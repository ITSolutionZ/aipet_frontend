import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/facility/data/facility_providers.dart';
import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/presentation/controllers/facility_list_controller.dart';
import 'package:aipet_frontend/features/facility/presentation/widgets/facility_card.dart';
import 'package:aipet_frontend/features/facility/presentation/widgets/filter_chip.dart';
import 'package:aipet_frontend/features/facility/presentation/widgets/search_bar_widget.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:aipet_frontend/shared/ui/components/states/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FacilityListScreen extends ConsumerStatefulWidget {
  const FacilityListScreen({super.key});

  @override
  ConsumerState<FacilityListScreen> createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends ConsumerState<FacilityListScreen> {
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
      child: SearchBarWidget(
        controller: _searchController,
        onChanged: _controller.handleSearchChanged,
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
    return EmptyState(
      icon: const Icon(Icons.search_off),
      title: _controller.hasActiveFilters
          ? '検索条件に一致する施設がありません'
          : '施設を見つけることができません',
      subtitle: '他の条件で検索してください',
    );
  }

  void _navigateToDetail(Facility facility) {
    context.push('${AppRouter.facilityDetailRoute}/${facility.id}');
  }
}
