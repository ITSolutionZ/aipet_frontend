import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 시설 전체화면 지도 화면
class FacilityFullscreenMapScreen extends ConsumerStatefulWidget {
  final Facility facility;
  final List<Facility>? nearbyFacilities;

  const FacilityFullscreenMapScreen({
    super.key,
    required this.facility,
    this.nearbyFacilities,
  });

  @override
  ConsumerState<FacilityFullscreenMapScreen> createState() =>
      _FacilityFullscreenMapScreenState();
}

class _FacilityFullscreenMapScreenState
    extends ConsumerState<FacilityFullscreenMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  Facility? _selectedFacility;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _selectedFacility = widget.facility;
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _currentPosition = position;
      });
      _setupMarkers();
    } catch (e) {
      // 위치 권한이 없거나 오류 발생 시 기본 위치 사용
      setState(() {
        _currentPosition = Position(
          latitude: 35.6762, // 도쿄 기본 위치
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
      });
      _setupMarkers();
    }
  }

  void _setupMarkers() {
    _markers.clear();

    // 메인 시설 마커
    _markers.add(
      Marker(
        markerId: MarkerId(widget.facility.id),
        position: LatLng(
          _getFacilityLatitude(widget.facility),
          _getFacilityLongitude(widget.facility),
        ),
        infoWindow: InfoWindow(
          title: widget.facility.name,
          snippet: widget.facility.type == FacilityType.grooming
              ? 'トリミング'
              : '動物病院',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          widget.facility.type == FacilityType.grooming
              ? BitmapDescriptor.hueViolet
              : BitmapDescriptor.hueRed,
        ),
        onTap: () => _selectFacility(widget.facility),
      ),
    );

    // 주변 시설 마커들
    if (widget.nearbyFacilities != null) {
      for (final facility in widget.nearbyFacilities!) {
        if (facility.id != widget.facility.id) {
          _markers.add(
            Marker(
              markerId: MarkerId(facility.id),
              position: LatLng(
                _getFacilityLatitude(facility),
                _getFacilityLongitude(facility),
              ),
              infoWindow: InfoWindow(
                title: facility.name,
                snippet: facility.type == FacilityType.grooming
                    ? 'トリミング'
                    : '動物病院',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                facility.type == FacilityType.grooming
                    ? BitmapDescriptor.hueViolet
                    : BitmapDescriptor.hueRed,
              ),
              onTap: () => _selectFacility(facility),
            ),
          );
        }
      }
    }

    // 현재 위치 마커
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: '現在地', snippet: 'あなたの現在位置'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
  }

  double _getFacilityLatitude(Facility facility) {
    // Mock 데이터에서 좌표 추출 (실제로는 facility.latitude 사용)
    return 35.6762 + (facility.id.hashCode % 100) * 0.001;
  }

  double _getFacilityLongitude(Facility facility) {
    // Mock 데이터에서 좌표 추출 (실제로는 facility.longitude 사용)
    return 139.6503 + (facility.id.hashCode % 100) * 0.001;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _setupMarkers();

    // 메인 시설로 카메라 이동
    _moveToFacility(widget.facility);
  }

  void _moveToFacility(Facility facility) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _getFacilityLatitude(facility),
              _getFacilityLongitude(facility),
            ),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  void _selectFacility(Facility facility) {
    setState(() {
      _selectedFacility = facility;
    });
    _moveToFacility(facility);
  }

  void _goToCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Text(
          '地図',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pointOffWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.pointDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.pointBlue),
            onPressed: _goToCurrentLocation,
            tooltip: '現在地に移動',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Maps
          _currentPosition == null
              ? _buildLoadingState()
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _getFacilityLatitude(widget.facility),
                      _getFacilityLongitude(widget.facility),
                    ),
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                ),

          // 선택된 시설 정보 카드
          if (_selectedFacility != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildSelectedFacilityCard(),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('地図を読み込み中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFacilityCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedFacility!.type == FacilityType.grooming
                        ? Colors.purple.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _selectedFacility!.type == FacilityType.grooming
                        ? Icons.content_cut
                        : Icons.local_hospital,
                    color: _selectedFacility!.type == FacilityType.grooming
                        ? Colors.purple
                        : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFacility!.name,
                        style: AppFonts.bodyLarge.copyWith(
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedFacility!.type == FacilityType.grooming
                            ? 'トリミング'
                            : '動物病院',
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.pointGray,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.pointGray),
                  onPressed: () {
                    setState(() {
                      _selectedFacility = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.pointGray,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _selectedFacility!.address,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_selectedFacility!.rating} (${_selectedFacility!.reviewCount})',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // 시설 상세 화면으로 이동
                    Navigator.of(context).pop();
                    context.pushNamed(
                      'facility-detail',
                      queryParameters: {'facilityId': _selectedFacility!.id},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  ),
                  child: const Text('詳細を見る'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
