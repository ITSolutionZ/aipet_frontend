import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/pet_info.dart';
import 'map/walk_map_camera_controller.dart';
import 'map/walk_map_marker_builder.dart';
import 'map/walk_map_polyline_builder.dart';
import 'utils/custom_marker_builder.dart';

final mapWidgetProvider = StateNotifierProvider.family
    .autoDispose<MapWidgetController, MapWidgetState, MapWidgetParams>((
      ref,
      params,
    ) {
      // keepAlive를 사용하여 dispose 방지
      ref.keepAlive();

      final controller = MapWidgetController(params);
      debugPrint('🗺️ MapWidgetProvider 생성됨 - keepAlive 설정');

      return controller;
    });

/// 전역 지도 컨트롤러 Provider (현재 위치 이동용)
final globalMapControllerProvider = StateProvider<GoogleMapController?>(
  (ref) => null,
);

class MapWidgetParams {
  final List<WalkRecordEntity> walkRecords;
  final WalkPetInfo? selectedPet;
  final List<Map<String, dynamic>> petActivities;
  final Function(int index)? onActivityMarkerTap;

  const MapWidgetParams({
    required this.walkRecords,
    this.selectedPet,
    this.petActivities = const [],
    this.onActivityMarkerTap,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapWidgetParams &&
        other.walkRecords == walkRecords &&
        other.selectedPet == selectedPet &&
        other.petActivities == petActivities &&
        other.onActivityMarkerTap == onActivityMarkerTap;
  }

  @override
  int get hashCode =>
      Object.hash(walkRecords, selectedPet, petActivities, onActivityMarkerTap);
}

class MapWidgetState {
  final GoogleMapController? mapController;
  final Position? currentPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final BitmapDescriptor? poopIcon;
  final BitmapDescriptor? peeIcon;
  final BitmapDescriptor? noEntryIcon;

  const MapWidgetState({
    this.mapController,
    this.currentPosition,
    this.markers = const {},
    this.polylines = const {},
    this.poopIcon,
    this.peeIcon,
    this.noEntryIcon,
  });

  MapWidgetState copyWith({
    GoogleMapController? mapController,
    Position? currentPosition,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    BitmapDescriptor? poopIcon,
    BitmapDescriptor? peeIcon,
    BitmapDescriptor? noEntryIcon,
  }) {
    return MapWidgetState(
      mapController: mapController ?? this.mapController,
      currentPosition: currentPosition ?? this.currentPosition,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      poopIcon: poopIcon ?? this.poopIcon,
      peeIcon: peeIcon ?? this.peeIcon,
      noEntryIcon: noEntryIcon ?? this.noEntryIcon,
    );
  }
}

class MapWidgetController extends StateNotifier<MapWidgetState> {
  final MapWidgetParams params;
  final LocationCacheService _locationCache = LocationCacheService.instance;

  // 전역 캐싱 (한 번만 생성)
  static BitmapDescriptor? _cachedPoopIcon;
  static BitmapDescriptor? _cachedPeeIcon;
  static BitmapDescriptor? _cachedNoEntryIcon;
  static bool _iconsLoading = false;
  static bool _iconsLoaded = false;

  MapWidgetController(this.params) : super(const MapWidgetState()) {
    // 즉시 기본 위치를 설정한 후 실제 위치를 가져오도록 변경
    _setDefaultLocation();
    getCurrentLocation();
    _loadCustomIconsOnce();
    setupMarkersAndPolylines();
  }

  /// 커스텀 아이콘 로드 (전역 싱글톤, 한 번만)
  Future<void> _loadCustomIconsOnce() async {
    // 이미 로드되었으면 상태만 업데이트
    if (_iconsLoaded && _cachedPoopIcon != null) {
      state = state.copyWith(
        poopIcon: _cachedPoopIcon,
        peeIcon: _cachedPeeIcon,
        noEntryIcon: _cachedNoEntryIcon,
      );
      return;
    }

    // 로딩 중이면 대기
    if (_iconsLoading) {
      while (_iconsLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      state = state.copyWith(
        poopIcon: _cachedPoopIcon,
        peeIcon: _cachedPeeIcon,
        noEntryIcon: _cachedNoEntryIcon,
      );
      return;
    }

    _iconsLoading = true;

    try {
      // 작은 사이즈로 원형 마커 생성 (메모리 효율적)
      final poopIcon = await CustomMarkerBuilder.createCircleMarker(
        iconPath: 'assets/icons/poop.png',
        backgroundColor: const Color(0xFFFF9800),
        size: 40,
      );
      final peeIcon = await CustomMarkerBuilder.createCircleMarker(
        iconPath: 'assets/icons/marking.png',
        backgroundColor: const Color(0xFF2196F3),
        size: 40,
      );
      final noEntryIcon = await CustomMarkerBuilder.createCircleMarker(
        iconPath: 'assets/icons/no-entry.png',
        backgroundColor: const Color(0xFFF44336),
        size: 40,
      );

      _cachedPoopIcon = poopIcon;
      _cachedPeeIcon = peeIcon;
      _cachedNoEntryIcon = noEntryIcon;
      _iconsLoaded = true;

      state = state.copyWith(
        poopIcon: poopIcon,
        peeIcon: peeIcon,
        noEntryIcon: noEntryIcon,
      );

      setupMarkersAndPolylines();
      debugPrint('✅ MapWidget: 원형 마커 로드 완료 (40px)');
    } catch (e) {
      debugPrint('⚠️ MapWidget: 마커 로드 실패 - $e');
    } finally {
      _iconsLoading = false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      // 1. 먼저 캐시된 위치 확인
      final cachedPosition = _locationCache.getCachedPosition();
      if (cachedPosition != null) {
        state = state.copyWith(currentPosition: cachedPosition);
        if (state.mapController != null) {
          await WalkMapCameraController.moveToCurrentLocation(
            state.mapController!,
            cachedPosition,
          );
        }
        return;
      }

      debugPrint('🗺️ MapWidget: 현재 위치 가져오기 시작 (캐시 없음)');
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('🗺️ MapWidget: 위치 권한 상태 - $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('🗺️ MapWidget: 위치 권한 요청 중...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ MapWidget: 위치 권한 거부됨 - 기본 위치 사용');
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ MapWidget: 위치 권한 영구 거부됨 - 기본 위치 사용');
        _setDefaultLocation();
        return;
      }

      debugPrint('🗺️ MapWidget: GPS 위치 가져오는 중...');
      final Position position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('⚠️ MapWidget: GPS 위치 취득 타임아웃 - 기본 위치 사용');
              throw Exception('GPS 위치 취득 タイムアウト');
            },
          );

      debugPrint(
        '✅ MapWidget: 현재 위치 가져오기 성공 - lat: ${position.latitude}, lng: ${position.longitude}',
      );

      // 위치 정보 캐싱
      _locationCache.cachePosition(position);
      state = state.copyWith(currentPosition: position);

      if (state.mapController != null) {
        await WalkMapCameraController.moveToCurrentLocation(
          state.mapController!,
          position,
        );
      }
    } catch (e) {
      debugPrint('❌ MapWidget: 위치 가져오기 실패 - $e');
      _setDefaultLocation();
    }
  }

  /// 강제로 새로운 위치 가져오기 (캐시 무시)
  Future<void> forceRefreshLocation() async {
    _locationCache.invalidateCache();
    await getCurrentLocation();
  }

  /// 기본 위치 설정 (도쿄)
  void _setDefaultLocation() {
    final defaultPosition = Position(
      latitude: 35.6762,
      longitude: 139.6503,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    debugPrint('🗺️ MapWidget: 기본 위치 설정 (도쿄) - lat: 35.6762, lng: 139.6503');
    state = state.copyWith(currentPosition: defaultPosition);
  }

  void setupMarkersAndPolylines() {
    final markers = <Marker>{};
    markers.addAll(
      WalkMapMarkerBuilder.buildAllMarkers(
        walkRecords: params.walkRecords,
        currentPosition: state.currentPosition,
        selectedPet: params.selectedPet,
      ),
    );

    // 펫 활동 마커 추가 (똥/오줌)
    markers.addAll(_buildPetActivityMarkers());

    final polylines = <Polyline>{};
    polylines.addAll(
      WalkMapPolylineBuilder.buildAllPolylines(
        params.walkRecords,
        defaultColor: AppColors.pointBrown,
      ),
    );

    state = state.copyWith(markers: markers, polylines: polylines);
  }

  /// 펫 활동 마커 생성 (똥/오줌) - 각각 개별 표시
  Set<Marker> _buildPetActivityMarkers() {
    final markers = <Marker>{};

    for (int i = 0; i < params.petActivities.length; i++) {
      final activity = params.petActivities[i];
      final type = activity['type'] as String;
      final lat = activity['latitude'] as double;
      final lng = activity['longitude'] as double;

      // 같은 위치에 여러 마커가 있을 경우 약간 오프셋 적용
      final offset = _calculateOffset(i, params.petActivities, lat, lng);

      // 커스텀 아이콘이 로드되었으면 사용, 아니면 기본 마커
      BitmapDescriptor markerIcon;
      if (type == 'poop' && state.poopIcon != null) {
        markerIcon = state.poopIcon!;
      } else if (type == 'pee' && state.peeIcon != null) {
        markerIcon = state.peeIcon!;
      } else if (type == 'no-entry' && state.noEntryIcon != null) {
        markerIcon = state.noEntryIcon!;
      } else {
        // 기본 마커
        double hue;
        if (type == 'poop') {
          hue = BitmapDescriptor.hueOrange;
        } else if (type == 'pee') {
          hue = BitmapDescriptor.hueAzure;
        } else {
          hue = BitmapDescriptor.hueRed;
        }
        markerIcon = BitmapDescriptor.defaultMarkerWithHue(hue);
      }

      String title;
      switch (type) {
        case 'poop':
          title = '💩 排便';
          break;
        case 'pee':
          title = '💧 排尿';
          break;
        case 'no-entry':
          title = '🚫 立入禁止';
          break;
        default:
          title = '記録';
      }

      markers.add(
        Marker(
          markerId: MarkerId('activity_$i'),
          position: LatLng(
            lat + offset['latOffset']!,
            lng + offset['lngOffset']!,
          ),
          icon: markerIcon,
          infoWindow: InfoWindow(title: title, snippet: 'タップして削除'),
          onTap: () {
            // 마커 탭 시 콜백 호출
            params.onActivityMarkerTap?.call(i);
          },
        ),
      );
    }

    return markers;
  }

  /// 같은 위치의 마커를 위한 오프셋 계산
  Map<String, double> _calculateOffset(
    int currentIndex,
    List<Map<String, dynamic>> activities,
    double lat,
    double lng,
  ) {
    // 같은 위치에 있는 이전 마커 수 계산
    int sameLocationCount = 0;
    for (int i = 0; i < currentIndex; i++) {
      final prevLat = activities[i]['latitude'] as double;
      final prevLng = activities[i]['longitude'] as double;

      // 소수점 4자리까지 같으면 같은 위치로 간주
      if ((lat - prevLat).abs() < 0.0001 && (lng - prevLng).abs() < 0.0001) {
        sameLocationCount++;
      }
    }

    // 오프셋 적용 (약 5-10m 정도)
    if (sameLocationCount > 0) {
      return {
        'latOffset': 0.0001 * sameLocationCount,
        'lngOffset': 0.0001 * sameLocationCount,
      };
    }

    return {'latOffset': 0.0, 'lngOffset': 0.0};
  }

  void setMapController(GoogleMapController controller, WidgetRef ref) {
    state = state.copyWith(mapController: controller);
    // 전역 provider에도 저장
    ref.read(globalMapControllerProvider.notifier).state = controller;
  }
}

class MapWidget extends ConsumerWidget {
  final List<WalkRecordEntity> walkRecords;
  final WalkPetInfo? selectedPet;
  final List<Map<String, dynamic>> petActivities;
  final Function(int index)? onActivityMarkerTap;

  const MapWidget({
    super.key,
    required this.walkRecords,
    this.selectedPet,
    this.petActivities = const [],
    this.onActivityMarkerTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = MapWidgetParams(
      walkRecords: walkRecords,
      selectedPet: selectedPet,
      petActivities: petActivities,
      onActivityMarkerTap: onActivityMarkerTap,
    );
    final controller = ref.read(mapWidgetProvider(params).notifier);
    final state = ref.watch(mapWidgetProvider(params));

    debugPrint(
      '🗺️ MapWidget: build() - currentPosition: ${state.currentPosition != null ? '있음' : 'null'}',
    );

    if (state.currentPosition == null) {
      debugPrint('🗺️ MapWidget: 로딩 화면 표시');
      return _buildLoadingState();
    }

    debugPrint('🗺️ MapWidget: GoogleMap 렌더링 시작');
    return GoogleMap(
      key: const ValueKey('google_map_view'),
      onMapCreated: (GoogleMapController mapController) {
        debugPrint('🗺️ MapWidget: GoogleMap 생성 완료');
        controller.setMapController(mapController, ref);
        controller.setupMarkersAndPolylines();

        WalkMapCameraController.moveToCurrentLocation(
          mapController,
          state.currentPosition!,
        );
      },
      initialCameraPosition:
          WalkMapCameraController.createDefaultCameraPosition(
            latitude: state.currentPosition!.latitude,
            longitude: state.currentPosition!.longitude,
            zoom: 15.0,
          ),
      markers: state.markers,
      polylines: state.polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      onCameraMove: (CameraPosition position) {
        // 카메라 이동 시 추가 로직 (필요시)
      },
    );
  }

  Widget _buildLoadingState() {
    debugPrint('🗺️ MapWidget: _buildLoadingState() 호출됨 - 위치 정보가 없어서 로딩 화면 표시');

    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 지도 아이콘 표시
            Icon(Icons.map, size: 60, color: AppColors.pointGray),
            SizedBox(height: AppSpacing.md),
            CircularProgressIndicator(color: AppColors.pointBrown),
            SizedBox(height: AppSpacing.md),
            Text(
              '地図を読み込み中...',
              style: TextStyle(
                color: AppColors.pointGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'GPS位置を確認中です',
              style: TextStyle(color: AppColors.pointGray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
