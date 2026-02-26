import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/facility_providers.dart';
import '../../data/services/google_places_service.dart';
import '../../domain/entities/facility_entity.dart';
import 'facility_detail_screen.dart';

/// 주변 펫 시설 검색 화면 (지도 + 리스트 + 루트)
class NearbyFacilitiesScreen extends ConsumerStatefulWidget {
  const NearbyFacilitiesScreen({super.key});

  @override
  ConsumerState<NearbyFacilitiesScreen> createState() =>
      _NearbyFacilitiesScreenState();
}

class _NearbyFacilitiesScreenState
    extends ConsumerState<NearbyFacilitiesScreen> {
  GoogleMapController? _mapController;
  FacilityType? _selectedType;
  Facility? _selectedFacility;
  bool _showList = true;

  // 현재 위치
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;

  // 루트 정보
  RouteInfo? _routeInfo;
  bool _isLoadingRoute = false;
  String _travelMode = 'walking'; // walking, driving

  // 기본 위치 (도쿄)
  static const LatLng _defaultLocation = LatLng(35.6762, 139.6503);

  final List<FacilityType?> _filterTypes = [
    null,
    FacilityType.veterinary,
    FacilityType.petStore,
    FacilityType.grooming,
    FacilityType.cafe,
    FacilityType.petPark,
    FacilityType.hotel,
  ];

  final Map<FacilityType?, String> _filterLabels = {
    null: '全て',
    FacilityType.veterinary: '動物病院',
    FacilityType.petStore: 'ペットショップ',
    FacilityType.grooming: 'トリミング',
    FacilityType.cafe: 'カフェ',
    FacilityType.petPark: 'ドッグラン',
    FacilityType.hotel: 'ホテル',
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = _defaultLocation;
          _isLoadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _currentLocation = _defaultLocation;
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _getRoute(Facility facility) async {
    if (_currentLocation == null) return;

    setState(() {
      _isLoadingRoute = true;
      _routeInfo = null;
    });

    final googlePlacesService = ref.read(googlePlacesServiceProvider);
    final result = await googlePlacesService.getDirections(
      originLat: _currentLocation!.latitude,
      originLng: _currentLocation!.longitude,
      destLat: facility.latitude,
      destLng: facility.longitude,
      mode: _travelMode,
    );

    setState(() {
      _isLoadingRoute = false;
      if (result.isSuccess) {
        _routeInfo = result.dataOrNull;
        // 루트가 표시되면 지도를 루트에 맞게 조정
        _fitMapToRoute(facility);
      }
    });
  }

  void _fitMapToRoute(Facility facility) {
    if (_mapController == null || _currentLocation == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _currentLocation!.latitude < facility.latitude
            ? _currentLocation!.latitude
            : facility.latitude,
        _currentLocation!.longitude < facility.longitude
            ? _currentLocation!.longitude
            : facility.longitude,
      ),
      northeast: LatLng(
        _currentLocation!.latitude > facility.latitude
            ? _currentLocation!.latitude
            : facility.latitude,
        _currentLocation!.longitude > facility.longitude
            ? _currentLocation!.longitude
            : facility.longitude,
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  void _clearRoute() {
    setState(() {
      _routeInfo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final facilitiesAsync = _selectedType == null
        ? ref.watch(nearbyFacilitiesProvider)
        : ref.watch(facilitiesByTypeProvider(_selectedType!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('周辺のペット施設'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showList ? Icons.map : Icons.list),
            onPressed: () {
              setState(() {
                _showList = !_showList;
                if (_showList) {
                  _clearRoute();
                }
              });
            },
            tooltip: _showList ? 'マップ表示' : 'リスト表示',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _clearRoute();
              _getCurrentLocation();
              if (_selectedType == null) {
                ref.invalidate(nearbyFacilitiesProvider);
              } else {
                ref.invalidate(facilitiesByTypeProvider(_selectedType!));
              }
            },
            tooltip: '再検索',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: facilitiesAsync.when(
              data: (result) {
                if (!result.isSuccess) {
                  return _buildErrorState(
                    result.error?.toString() ?? 'エラーが発生しました',
                  );
                }
                var facilities = result.dataOrNull ?? [];

                // 현재 위치가 있으면 거리 추가
                if (_currentLocation != null && facilities.isNotEmpty) {
                  final googlePlacesService = ref.read(googlePlacesServiceProvider);
                  facilities = googlePlacesService.addDistanceToFacilities(
                    facilities: facilities,
                    currentLat: _currentLocation!.latitude,
                    currentLng: _currentLocation!.longitude,
                  );
                }

                if (facilities.isEmpty) {
                  return _buildEmptyState();
                }
                return _showList
                    ? _buildListView(facilities)
                    : _buildMapView(facilities);
              },
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterTypes.map((type) {
            final isSelected = _selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(_filterLabels[type] ?? ''),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type : null;
                    _selectedFacility = null;
                    _clearRoute();
                  });
                },
                selectedColor: AppColors.pointBrown.withValues(alpha: 0.2),
                checkmarkColor: AppColors.pointBrown,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.pointBrown : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMapView(List<Facility> facilities) {
    final markers = facilities.map((facility) {
      final isSelected = _selectedFacility?.id == facility.id;
      return Marker(
        markerId: MarkerId(facility.id),
        position: LatLng(facility.latitude, facility.longitude),
        infoWindow: InfoWindow(
          title: facility.name,
          snippet: facility.distance != null
              ? '${facility.formattedDistance} • ${facility.typeName}'
              : facility.typeName,
          onTap: () => _navigateToDetail(facility),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueGreen : _getMarkerHue(facility.type),
        ),
        onTap: () {
          setState(() {
            _selectedFacility = facility;
            _clearRoute();
          });
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(facility.latitude, facility.longitude),
            ),
          );
        },
      );
    }).toSet();

    // 현재 위치 마커 추가
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: '現在地'),
        ),
      );
    }

    // 루트 폴리라인
    final Set<Polyline> polylines = {};
    if (_routeInfo != null) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _routeInfo!.polylinePoints,
          color: AppColors.pointBrown,
          width: 5,
        ),
      );
    }

    // 지도 중심 계산
    LatLng center = _currentLocation ?? _defaultLocation;
    if (_selectedFacility != null && _routeInfo == null) {
      center = LatLng(_selectedFacility!.latitude, _selectedFacility!.longitude);
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: center,
            zoom: 14,
          ),
          markers: markers,
          polylines: polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onTap: (_) {
            setState(() {
              _selectedFacility = null;
              _clearRoute();
            });
          },
        ),
        // 현재 위치 버튼
        Positioned(
          right: AppSpacing.md,
          top: AppSpacing.md,
          child: FloatingActionButton.small(
            heroTag: 'my_location',
            onPressed: () {
              if (_currentLocation != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(_currentLocation!),
                );
              }
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: AppColors.pointBrown),
          ),
        ),
        // 선택된 시설 카드
        if (_selectedFacility != null)
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.lg,
            child: _buildSelectedFacilityCard(_selectedFacility!),
          ),
        // 루트 로딩 인디케이터
        if (_isLoadingRoute)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: AppSpacing.md),
                        Text('ルートを検索中...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedFacilityCard(Facility facility) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 시설 정보
          InkWell(
            onTap: () => _navigateToDetail(facility),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.md)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: facility.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Icon(
                      facility.icon,
                      color: facility.color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          facility.name,
                          style: AppFonts.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Text(
                              facility.typeName,
                              style: AppFonts.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (facility.distance != null) ...[
                              const Text(' • '),
                              const Icon(
                                Icons.straighten,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                facility.formattedDistance,
                                style: AppFonts.bodySmall.copyWith(
                                  color: AppColors.pointBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber[600]),
                            const SizedBox(width: 2),
                            Text(
                              facility.formattedRating,
                              style: AppFonts.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            // 시설 타입별 뱃지
                            if (facility.badgeText.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: facility.badgeColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      facility.badgeIcon,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      facility.badgeText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(width: 4),
                            // 영업 상태 뱃지
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: facility.openStatusColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                facility.openStatusText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedFacility = null;
                        _clearRoute();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // 루트 정보 (있는 경우)
          if (_routeInfo != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.pointBrown.withValues(alpha: 0.1),
                border: const Border(
                  top: BorderSide(color: AppColors.toneLightGray),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRouteInfoItem(
                    icon: Icons.straighten,
                    label: '距離',
                    value: _routeInfo!.distanceText,
                  ),
                  _buildRouteInfoItem(
                    icon: GooglePlacesService.getModeIcon(_travelMode),
                    label: GooglePlacesService.getModeName(_travelMode),
                    value: _routeInfo!.durationText,
                  ),
                ],
              ),
            ),
          // 루트 액션 버튼
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.toneLightGray),
              ),
            ),
            child: Row(
              children: [
                // 이동 모드 선택
                _buildModeButton(
                  mode: 'walking',
                  icon: Icons.directions_walk,
                  label: '徒歩',
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildModeButton(
                  mode: 'driving',
                  icon: Icons.directions_car,
                  label: '車',
                ),
                const Spacer(),
                // 루트 표시/지우기 버튼
                if (_routeInfo != null)
                  TextButton.icon(
                    onPressed: _clearRoute,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('ルートを消す'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _currentLocation != null
                        ? () => _getRoute(facility)
                        : null,
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('ルートを表示'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBrown,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.pointBrown),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppFonts.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required String mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _travelMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _travelMode = mode;
        });
        // 루트가 이미 표시되어 있으면 새 모드로 다시 검색
        if (_routeInfo != null && _selectedFacility != null) {
          _getRoute(_selectedFacility!);
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointBrown.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(
            color: isSelected ? AppColors.pointBrown : AppColors.toneLightGray,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.pointBrown : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppFonts.bodySmall.copyWith(
                color: isSelected ? AppColors.pointBrown : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<Facility> facilities) {
    return RefreshIndicator(
      onRefresh: () async {
        await _getCurrentLocation();
        if (_selectedType == null) {
          ref.invalidate(nearbyFacilitiesProvider);
        } else {
          ref.invalidate(facilitiesByTypeProvider(_selectedType!));
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: facilities.length,
        itemBuilder: (context, index) {
          final facility = facilities[index];
          return _buildFacilityListItem(facility);
        },
      ),
    );
  }

  Widget _buildFacilityListItem(Facility facility) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(facility),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: facility.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Icon(
                  facility.icon,
                  color: facility.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: AppFonts.titleSmall.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      facility.address,
                      style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[600]),
                        const SizedBox(width: 2),
                        Text(
                          '${facility.formattedRating} (${facility.reviewCount})',
                          style: AppFonts.bodySmall,
                        ),
                        if (facility.distance != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.straighten, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Text(
                            facility.formattedDistance,
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 시설 타입별 뱃지
                  if (facility.badgeText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: facility.badgeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            facility.badgeIcon,
                            size: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            facility.badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  // 영업 상태 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: facility.openStatusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      facility.openStatusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.directions, color: AppColors.pointBrown),
                    onPressed: () {
                      setState(() {
                        _selectedFacility = facility;
                        _showList = false;
                      });
                    },
                    tooltip: 'ルートを表示',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _isLoadingLocation ? '現在地を取得中...' : '周辺の施設を検索中...',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 64,
              color: AppColors.toneLightGray,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '周辺に施設が見つかりません',
              style: AppFonts.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '別のカテゴリを選択するか、\n検索範囲を広げてみてください',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                _getCurrentLocation();
                if (_selectedType == null) {
                  ref.invalidate(nearbyFacilitiesProvider);
                } else {
                  ref.invalidate(facilitiesByTypeProvider(_selectedType!));
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('再検索'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.pointGray,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'エラーが発生しました',
              style: AppFonts.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                _getCurrentLocation();
                if (_selectedType == null) {
                  ref.invalidate(nearbyFacilitiesProvider);
                } else {
                  ref.invalidate(facilitiesByTypeProvider(_selectedType!));
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  double _getMarkerHue(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
      case FacilityType.veterinary:
        return BitmapDescriptor.hueRed;
      case FacilityType.petStore:
      case FacilityType.petShop:
        return BitmapDescriptor.hueOrange;
      case FacilityType.grooming:
        return BitmapDescriptor.hueMagenta;
      case FacilityType.cafe:
        return BitmapDescriptor.hueYellow;
      case FacilityType.petPark:
      case FacilityType.park:
      case FacilityType.dogRun:
        return BitmapDescriptor.hueGreen;
      case FacilityType.hotel:
      case FacilityType.petFriendlyAccommodation:
        return BitmapDescriptor.hueBlue;
      case FacilityType.training:
        return BitmapDescriptor.hueViolet;
      default:
        return BitmapDescriptor.hueAzure;
    }
  }

  void _navigateToDetail(Facility facility) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FacilityDetailScreen(
          facility: {
            'id': facility.id,
            'name': facility.name,
            'type': facility.typeName,
            'address': facility.address,
            'rating': facility.rating,
            'reviewCount': facility.reviewCount,
            'phone': facility.phone ?? facility.phoneNumber,
            'website': facility.website,
            'description': facility.description,
            'latitude': facility.latitude,
            'longitude': facility.longitude,
            'isOpen': facility.isOpen,
            'distance': facility.distance,
          },
        ),
      ),
    );
  }
}
