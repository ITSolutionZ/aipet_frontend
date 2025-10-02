import 'dart:async';

import 'package:aipet_frontend/features/walk/data/providers/walk_providers.dart';
import 'package:aipet_frontend/features/walk/domain/entities/pet_info.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/walk_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart'
    hide MapWidget, WalkRecordCardWidget;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WalkListScreen extends ConsumerStatefulWidget {
  final bool showBackButton;

  const WalkListScreen({super.key, this.showBackButton = false});

  @override
  ConsumerState<WalkListScreen> createState() => _WalkListScreenState();
}

class _WalkListScreenState extends ConsumerState<WalkListScreen> {
  late final WalkController _controller;
  final PageController _pageController = PageController();
  bool _isPaused = false; // 일시정지 상태
  Timer? _timer; // 타이머
  int _elapsedSeconds = 0; // 경과 시간 (초)
  final List<Map<String, dynamic>> _petActivities = []; // 펫 활동 기록 (똥, 오줌)

  @override
  void initState() {
    super.initState();
    _controller = WalkController(ref);
    _loadInitialData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _controller.loadWalkRecords();

    // Mock 데이터의 첫 번째 펫을 기본으로 설정
    final pets = PetMockData.getMockPets();
    if (pets.isNotEmpty) {
      final firstPet = pets.first;
      _controller.setSelectedPet(WalkPetInfo.fromPetProfile(firstPet));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPets = ref.watch(selectedPetsNotifierProvider);
    final walkRecords = ref.watch(walkRecordsNotifierProvider);
    final currentWalk = ref.watch(currentWalkNotifierProvider);

    // 산책 시작 시 타이머 시작
    if (currentWalk != null && _timer == null) {
      final startTime = currentWalk.startTime;
      _elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
      _startTimer();
    }

    // 산책 종료 시 타이머 정지
    if (currentWalk == null && _timer != null) {
      _stopTimer();
      _elapsedSeconds = 0;
      _isPaused = false;
    }

    // 새로운 전체 화면 오버레이 레이아웃
    return _buildFullScreenOverlayLayout(
      selectedPets,
      walkRecords,
      currentWalk,
    );
  }

  /// 새로운 전체 화면 오버레이 레이아웃
  Widget _buildFullScreenOverlayLayout(
    List<WalkPetInfo> selectedPets,
    List<WalkRecordEntity> walkRecords,
    WalkRecordEntity? currentWalk,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 전체 화면 지도 (상태바와 바텀 네비게이터 제외)
          Positioned.fill(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).padding.bottom,
            child: _buildMapWidget(walkRecords, selectedPets),
          ),

          // 중앙 하단 펫 선택 카드 (산책 중이 아닐 때만 표시)
          if (currentWalk == null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 90,
              left: 0,
              right: 0,
              child: Center(child: _buildPetFloatingButton(selectedPets)),
            ),

          // 상단 우측 버튼들 (세로 배치)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Column(
              children: [
                // 산책 기록 리스트 버튼
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _showWalkRecordsList,
                    icon: const Icon(
                      Icons.list,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 현재 위치로 이동 버튼
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _moveToCurrentLocation,
                    icon: const Icon(
                      Icons.my_location,
                      color: AppColors.pointBrown,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 줌 인 버튼
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _zoomIn,
                    icon: const Icon(
                      Icons.add,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 줌 아웃 버튼
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _zoomOut,
                    icon: const Icon(
                      Icons.remove,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 배변/배뇨 버튼 (우측 상단)
          if (currentWalk != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 160,
              right: 16,
              child: Column(
                children: [
                  _buildActivityButton(
                    iconPath: 'assets/icons/poop.png',
                    onTap: () => _recordPetActivity('poop'),
                  ),
                  const SizedBox(height: 8),
                  _buildActivityButton(
                    iconPath: 'assets/icons/marking.png',
                    onTap: () => _recordPetActivity('pee'),
                  ),
                ],
              ),
            ),

          // 산책 중일 때 정보 표시 (버튼 위)
          if (currentWalk != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 90,
              left: 20,
              right: 20,
              child: _buildWalkInfoCard(currentWalk),
            ),

          // 하단 버튼들
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 20,
            right: 20,
            child: currentWalk == null
                ? Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.pointBrown,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pointBrown.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: _showStartWalkDialog,
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'スタート',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      // 일시정지/재시작 버튼 (산책 중)
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: _isPaused
                                ? AppColors.pointGreen.withValues(alpha: 0.9)
                                : AppColors.pointBlue.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_isPaused
                                            ? AppColors.pointGreen
                                            : AppColors.pointBlue)
                                        .withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextButton.icon(
                            onPressed: _pauseWalk,
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            icon: Icon(
                              _isPaused ? Icons.play_arrow : Icons.pause,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isPaused ? '再開' : '一時停止',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 종료 버튼 (산책 중)
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.pointPink,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.pointPink.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextButton.icon(
                            onPressed: _showEndWalkDialog,
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            icon: const Icon(Icons.stop, color: Colors.white),
                            label: Text(
                              '終了',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      drawer: widget.showBackButton ? null : const AppDrawer(),
    );
  }

  /// 중앙 하단 펫 리스트 위젯
  Widget _buildPetFloatingButton(List<WalkPetInfo> selectedPets) {
    // Mock 펫 데이터 가져오기
    final pets = PetMockData.getMockPets();

    if (pets.isEmpty) {
      // 펫이 없는 경우: + 원형 아이콘만 표시
      return GestureDetector(
        onTap: () {
          // TODO: 펫 추가 화면으로 이동
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ペットを追加してください'),
              backgroundColor: AppColors.pointBrown,
            ),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.pointBrown.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      );
    }

    // 펫 리스트가 있는 경우: 가로 스크롤 펫 카드
    return Center(
      child: SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: pets.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final pet = pets[index];
            final isSelected = selectedPets.any((p) => p.id == pet.id);

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  debugPrint('🐾 펫 탭: ${pet.name} (ID: ${pet.id})');
                  // 펫 선택 토글
                  _controller.togglePet(WalkPetInfo.fromPetProfile(pet));

                  // 선택된 펫 확인
                  final currentSelected = ref.read(
                    selectedPetsNotifierProvider,
                  );
                  debugPrint(
                    '✅ 선택된 펫들: ${currentSelected.map((p) => p.name).join(', ')}',
                  );
                },
                child: Container(
                  width: 75,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.pointPink.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: isSelected
                        ? Border.all(color: AppColors.pointPink, width: 3)
                        : Border.all(color: Colors.grey.shade300, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 펫 아바타
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : AppColors.pointGray.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: pet.imagePath?.isNotEmpty == true
                              ? Image.asset(
                                  pet.imagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.pets,
                                      color: isSelected
                                          ? AppColors.pointPink
                                          : AppColors.pointGray,
                                      size: 22,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.pets,
                                  color: isSelected
                                      ? AppColors.pointPink
                                      : AppColors.pointGray,
                                  size: 22,
                                ),
                        ),
                      ),
                      const SizedBox(height: 3),

                      // 펫 이름
                      Text(
                        pet.name,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // 권장 산책 시간
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 10,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${pet.recommendedWalkTime}分',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showStartWalkDialog() async {
    final selectedPets = ref.read(selectedPetsNotifierProvider);

    if (selectedPets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ペットを選択してください'),
          backgroundColor: AppColors.pointPink,
        ),
      );
      return;
    }

    // 다이얼로그 없이 바로 산책 시작
    final result = await _controller.startNewWalk(
      title: '散歩',
      petId: selectedPets.first.id,
      petName: selectedPets.map((p) => p.name).join('、'),
    );

    if (!result.isSuccess && mounted) {
      // 실패 시에만 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.pointPink,
        ),
      );
    }
  }

  /// 타이머 시작
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  /// 타이머 정지
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// 산책 일시정지/재시작
  void _pauseWalk() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      // 위치 추적 중지
      ref.read(locationTrackingNotifierProvider.notifier).stopTracking();
    } else {
      // 위치 추적 재개
      ref.read(locationTrackingNotifierProvider.notifier).startTracking();
    }
  }

  /// 펫 활동 버튼 (똥/오줌) - 원형 아이콘 버튼
  Widget _buildActivityButton({
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: 28,
            height: 28,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.pets,
                size: 28,
                color: AppColors.pointBrown,
              );
            },
          ),
        ),
      ),
    );
  }

  /// 펫 활동 기록 (똥/오줌)
  Future<void> _recordPetActivity(String activityType) async {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      // 현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final activity = {
        'type': activityType,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };

      setState(() {
        _petActivities.add(activity);
      });

      // 지도에 즉시 마커 표시를 위해 강제 리빌드
      debugPrint(
        '✅ 活動記録追加: ${activityType == 'poop' ? '💩' : '💧'} at (${position.latitude}, ${position.longitude})',
      );

      // 사용자에게 피드백 (간단하게)
      final label = activityType == 'poop' ? '💩' : '💧';
      messenger.showSnackBar(
        SnackBar(
          content: Text(label),
          backgroundColor: AppColors.pointGreen,
          duration: const Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      debugPrint('❌ 活動記録失敗: $e');
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('位置情報を取得できませんでした'),
            backgroundColor: AppColors.pointPink,
          ),
        );
      }
    }
  }

  /// 산책 정보 카드
  Widget _buildWalkInfoCard(WalkRecordEntity currentWalk) {
    final hours = _elapsedSeconds ~/ 3600;
    final seconds = _elapsedSeconds % 60;
    final distance = currentWalk.distance ?? 0.0;

    // 선택된 펫의 추천 시간 가져오기
    final selectedPets = ref.watch(selectedPetsNotifierProvider);
    final pets = PetMockData.getMockPets();
    final selectedPet = selectedPets.isNotEmpty
        ? pets.firstWhere(
            (p) => p.id == selectedPets.first.id,
            orElse: () => pets.first,
          )
        : pets.first;
    final recommendedTime = selectedPet.recommendedWalkTime;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 소요 시간 (h:s 형식)
          _buildInfoItem(
            icon: Icons.timer,
            value: '$hours:${seconds.toString().padLeft(2, '0')}',
          ),

          // 거리
          _buildInfoItem(
            icon: Icons.straighten,
            value: distance < 1
                ? '${(distance * 1000).toStringAsFixed(0)}m'
                : '${distance.toStringAsFixed(2)}km',
          ),

          // 추천 시간
          _buildInfoItem(icon: Icons.flag_outlined, value: '$recommendedTime分'),
        ],
      ),
    );
  }

  /// 정보 아이템 (아이콘 + 값)
  Widget _buildInfoItem({required IconData icon, required String value}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.pointBrown, size: 18),
        const SizedBox(width: 6),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
        ),
      ],
    );
  }

  /// 산책 종료 확인 다이얼로그
  void _showEndWalkDialog() {
    final currentWalk = ref.read(currentWalkNotifierProvider);
    if (currentWalk == null) return;

    // 현재 거리 및 시간 계산
    final currentDistance = currentWalk.distance ?? 0.0;
    final durationInSeconds = _elapsedSeconds;
    final hours = durationInSeconds ~/ 3600;
    final minutes = (durationInSeconds % 3600) ~/ 60;
    final seconds = durationInSeconds % 60;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('散歩を終了'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${currentWalk.petName}との散歩を終了しますか？'),
            const SizedBox(height: 16),
            Text(
              '経過時間: $hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '距離: ${currentDistance < 1 ? '${(currentDistance * 1000).toStringAsFixed(0)}m' : '${currentDistance.toStringAsFixed(2)}km'}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              // context를 미리 저장
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              navigator.pop();

              // 활동 기록을 notes에 JSON 형식으로 저장
              String? notesWithActivities;
              if (_petActivities.isNotEmpty) {
                final activitiesJson = _petActivities.map((a) {
                  return {
                    'type': a['type'],
                    'latitude': a['latitude'],
                    'longitude': a['longitude'],
                    'timestamp': (a['timestamp'] as DateTime).toIso8601String(),
                  };
                }).toList();
                notesWithActivities = 'activities:${activitiesJson.toString()}';
              }

              // 산책 종료 (현재 거리, 시간, 활동 기록 전달)
              final result = await _controller.endCurrentWalk(
                distance: currentDistance,
                notes: notesWithActivities,
              );

              if (!mounted) return;

              // 타이머 정지 및 상태 초기화
              _stopTimer();

              setState(() {
                _petActivities.clear();
                _isPaused = false;
                _elapsedSeconds = 0;
              });

              if (result.isSuccess) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('散歩が終了しました'),
                    backgroundColor: AppColors.pointGreen,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: AppColors.pointPink,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointPink,
              foregroundColor: Colors.white,
            ),
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }

  /// 지도 위젯 빌드
  Widget _buildMapWidget(
    List<WalkRecordEntity> walkRecords,
    List<WalkPetInfo> selectedPets,
  ) {
    return MapWidget(
      key: ValueKey('walk_map_widget_${_petActivities.length}'),
      walkRecords: walkRecords,
      selectedPet: selectedPets.isNotEmpty ? selectedPets.first : null,
      petActivities: _petActivities,
    );
  }

  /// 현재 위치로 지도 이동
  Future<void> _moveToCurrentLocation() async {
    try {
      // 전역 provider에서 지도 컨트롤러 가져오기
      final mapController = ref.read(globalMapControllerProvider);

      if (mapController == null) {
        debugPrint('❌ 지도 컨트롤러가 아직 초기화되지 않았습니다');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('地図が読み込まれていません'),
              backgroundColor: AppColors.pointPink,
            ),
          );
        }
        return;
      }

      // 현재 위치 가져오기
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('位置情報の取得がタイムアウトしました');
            },
          );

      debugPrint('📍 현재 위치: ${position.latitude}, ${position.longitude}');

      // 지도 카메라를 현재 위치로 이동 (줌 레벨을 기본값 16.0으로 재설정)
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0, // 기본 줌 레벨로 되돌림
          ),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('現在地に移動しました'),
            backgroundColor: AppColors.pointGreen,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 현재 위치 이동 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('現在地の取得に失敗しました'),
            backgroundColor: AppColors.pointPink,
          ),
        );
      }
    }
  }

  /// 지도 확대
  Future<void> _zoomIn() async {
    try {
      final mapController = ref.read(globalMapControllerProvider);

      if (mapController == null) {
        debugPrint('❌ 지도 컨트롤러가 아직 초기화되지 않았습니다');
        return;
      }

      await mapController.animateCamera(CameraUpdate.zoomIn());
      debugPrint('🔍 지도 확대');
    } catch (e) {
      debugPrint('❌ 지도 확대 에러: $e');
    }
  }

  /// 지도 축소
  Future<void> _zoomOut() async {
    try {
      final mapController = ref.read(globalMapControllerProvider);

      if (mapController == null) {
        debugPrint('❌ 지도 컨트롤러가 아직 초기화되지 않았습니다');
        return;
      }

      await mapController.animateCamera(CameraUpdate.zoomOut());
      debugPrint('🔍 지도 축소');
    } catch (e) {
      debugPrint('❌ 지도 축소 에러: $e');
    }
  }

  void _showWalkRecordsList() {
    // 산책 기록 달력 페이지로 이동
    context.push('/walk/calendar');
  }
}
