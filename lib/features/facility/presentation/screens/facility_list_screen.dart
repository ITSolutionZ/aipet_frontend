import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../data/facility_providers.dart';
import '../../domain/facility.dart';
import '../widgets/facility_card.dart';
import '../widgets/facility_filter_chip.dart';
import '../widgets/facility_search_bar.dart';

class FacilityListScreen extends ConsumerStatefulWidget {
  const FacilityListScreen({super.key});

  @override
  ConsumerState<FacilityListScreen> createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends ConsumerState<FacilityListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final facilityList = ref.read(facilityListNotifierProvider);
    final searchResults = ref.read(searchResultsNotifierProvider.notifier);
    
    searchResults.setSearchResults(facilityList);
  }

  void _onSearchChanged(String query) {
    ref.read(searchQueryNotifierProvider.notifier).setQuery(query);
    
    final facilityList = ref.read(facilityListNotifierProvider.notifier);
    final searchResults = ref.read(searchResultsNotifierProvider.notifier);
    
    final results = facilityList.search(query);
    searchResults.setSearchResults(results);
  }

  void _onFilterChanged(FacilityType? type) {
    ref.read(selectedFacilityTypeNotifierProvider.notifier).setType(type);
    
    final facilityList = ref.read(facilityListNotifierProvider.notifier);
    final searchResults = ref.read(searchResultsNotifierProvider.notifier);
    final query = ref.read(searchQueryNotifierProvider);
    
    List<Facility> results;
    if (type != null) {
      results = facilityList.getByType(type);
      if (query.isNotEmpty) {
        results = results.where((facility) =>
          facility.name.toLowerCase().contains(query.toLowerCase()) ||
          facility.description.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    } else {
      results = facilityList.search(query);
    }
    
    searchResults.setSearchResults(results);
  }

  void _onSortChanged(String sortType) {
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
    }
  }

  void _toggleFavorite(String facilityId) {
    final facilityList = ref.read(facilityListNotifierProvider.notifier);
    facilityList.toggleFavorite(facilityId);
    
    _refreshSearchResults();
  }

  void _refreshSearchResults() {
    final query = ref.read(searchQueryNotifierProvider);
    final selectedType = ref.read(selectedFacilityTypeNotifierProvider);
    
    final facilityList = ref.read(facilityListNotifierProvider.notifier);
    final searchResults = ref.read(searchResultsNotifierProvider.notifier);
    
    List<Facility> results;
    if (selectedType != null) {
      results = facilityList.getByType(selectedType);
      if (query.isNotEmpty) {
        results = results.where((facility) =>
          facility.name.toLowerCase().contains(query.toLowerCase()) ||
          facility.description.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    } else {
      results = facilityList.search(query);
    }
    
    searchResults.setSearchResults(results);
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsNotifierProvider);
    final searchQuery = ref.watch(searchQueryNotifierProvider);
    final selectedType = ref.watch(selectedFacilityTypeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: const Text('近くの施設'),
        backgroundColor: AppColors.pointOffWhite,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _onSortChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'distance', child: Text('距離順')),
              const PopupMenuItem(value: 'rating', child: Text('評価順')),
              const PopupMenuItem(value: 'name', child: Text('名前順')),
            ],
            child: const Icon(Icons.sort),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FacilitySearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSearch: () => _onSearchChanged(_searchController.text),
              onClear: () => _onSearchChanged(''),
              hintText: '施設名で検索...',
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FacilityFilterChip(
                  label: 'すべて',
                  isSelected: selectedType == null,
                  onTap: () => _onFilterChanged(null),
                ),
                const SizedBox(width: 8),
                for (final type in FacilityType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FacilityFilterChip(
                      label: _getTypeLabel(type),
                      isSelected: selectedType == type,
                      onTap: () => _onFilterChanged(type),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Results Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '${searchResults.length}件の施設',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                if (searchQuery.isNotEmpty || selectedType != null)
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                      _onFilterChanged(null);
                    },
                    child: const Text('クリア'),
                  ),
              ],
            ),
          ),

          // Facility List
          Expanded(
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
                          onFavoriteToggle: () => _toggleFavorite(facility.id),
                          onTap: () => _navigateToDetail(facility),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final searchQuery = ref.watch(searchQueryNotifierProvider);
    final selectedType = ref.watch(selectedFacilityTypeNotifierProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty || selectedType != null
                ? '検索条件に合う施設が見つかりません'
                : '施設が見つかりません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '別の条件で検索してみてください',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return '動物病院';
      case FacilityType.grooming:
        return 'トリミング';
    }
  }

  void _navigateToDetail(Facility facility) {
    context.push('${AppRouter.facilityDetailRoute}/${facility.id}');
  }
}
