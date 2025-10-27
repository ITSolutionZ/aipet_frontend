import 'dart:async';

import 'package:aipet_frontend/app/widgets/widgets.dart';
import 'package:aipet_frontend/features/walk/data/providers/walk_providers.dart';
import 'package:aipet_frontend/features/walk/domain/entities/pet_info.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/walk_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart' hide MapWidget;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/pet_profile/data/providers/pet_profile_providers.dart';
import 'helpers/helpers.dart';

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
  final ValueNotifier<int> _elapsedSecondsNotifier = ValueNotifier<int>(0); // ✅ ValueNotifier로 변경
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
    _elapsedSecondsNotifier.dispose(); // ✅ ValueNotifier dispose
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _controller.loadWalkRecords();

    // 백그라운드에서 진행 중인 산책 확인
    await WalkListBackgroundHelper.checkBackgroundWalk(
      context: context,
      ref: ref,
      controller: _controller,
    );

    // SQLite에서 펫 불러와서 첫 번째 펫을 기본으로 설정 (펫이 있을 경우에만)
    try {
      final petsAsync = await ref.read(petProfilesProvider.future);
      LoggerService.debug('🐕 SQLite에서 로드된 펫 개수: ${petsAsync.length}');

      if (petsAsync.isNotEmpty) {
        final firstPet = petsAsync.first;
        LoggerService.debug('🐕 첫 번째 펫: ${firstPet.name} (ID: ${firstPet.id})');
        _controller.setSelectedPet(WalkPetInfo.fromPetProfile(firstPet));
      } else {
        LoggerService.debug('🐕 SQLite에 저장된 펫이 없습니다');
      }
      // 펫이 없어도 산책 화면에는 접근 가능하도록 함
    } catch (e) {
      // 펫 데이터 로드 실패해도 산책 화면은 표시
      LoggerService.debug('🐕 SQLite 펫 데이터 로드 실패, 하지만 산책 화면은 표시: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPets = ref.watch(selectedPetsProvider);
    final walkRecords = ref.watch(walkRecordsProvider);
    final currentWalk = ref.watch(currentWalkProvider);

    // 산책 시작 시 타이머 시작
    if (currentWalk != null && _timer == null) {
      _elapsedSecondsNotifier.value = WalkListTimerHelper.calculateElapsedSeconds(
        currentWalk.startTime,
      );
      _startTimer();
    }

    // 산책 종료 시 타이머 정지
    if (currentWalk == null && _timer != null) {
      WalkListTimerHelper.stopTimer(_timer);
      _timer = null;
      _elapsedSecondsNotifier.value = 0;
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
            child: WalkListUiHelper.buildTopButtons(
              onListTap: _showWalkRecordsList,
              onLocationTap: _moveToCurrentLocation,
            ),
          ),

          // 배변/배뇨/금지구역 버튼 (우측 상단)
          if (currentWalk != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 160,
              right: 16,
              child: Column(
                children: [
                  WalkListUiHelper.buildActivityButton(
                    iconPath: 'assets/icons/no-entry.png',
                    onTap: () => _recordPetActivity('no-entry'),
                  ),
                  const SizedBox(height: 8),
                  WalkListUiHelper.buildActivityButton(
                    iconPath: 'assets/icons/poop.png',
                    onTap: () => _recordPetActivity('poop'),
                  ),
                  const SizedBox(height: 8),
                  WalkListUiHelper.buildActivityButton(
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
                ? WalkListUiHelper.buildStartButton(
                    onPressed: _showStartWalkDialog,
                  )
                : WalkListUiHelper.buildWalkingButtons(
                    isPaused: _isPaused,
                    onPause: _pauseWalk,
                    onEnd: _showEndWalkDialog,
                  ),
          ),
        ],
      ),
      drawer: widget.showBackButton ? null : const AppDrawer(),
    );
  }

  /// 중앙 하단 펫 리스트 위젯
  Widget _buildPetFloatingButton(List<WalkPetInfo> selectedPets) {
    // 로컬 저장소에서 펫 데이터 가져오기
    final petsAsync = ref.watch(petProfilesProvider);

    return petsAsync.when(
      data: (pets) => _buildPetSelectionList(pets, selectedPets),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => const Icon(Icons.error),
    );
  }

  Widget _buildPetSelectionList(
    List<PetProfileEntity> pets,
    List<WalkPetInfo> selectedPets,
  ) {
    if (pets.isEmpty) {
      // 펫이 없는 경우
      return WalkListUiHelper.buildEmptyPetButton(
        onTap: () => context.push('/daily-pet-registration'),
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

            return WalkListUiHelper.buildPetCard(
              pet: pet,
              isSelected: isSelected,
              onTap: () => WalkListPetHelper.handlePetToggle(
                pet: pet,
                controller: _controller,
                ref: ref,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showStartWalkDialog() async {
    await WalkListStartHelper.showStartWalkDialog(
      context: context,
      ref: ref,
      controller: _controller,
    );
  }

  /// 타이머 시작
  void _startTimer() {
    _timer = WalkListTimerHelper.startTimer(
      onTick: () {
        if (mounted) {
          // ✅ setState() 대신 ValueNotifier 업데이트 (화면 전체 rebuild 방지)
          _elapsedSecondsNotifier.value++;
        }
      },
      shouldTick: () => !_isPaused && mounted,
    );
  }

  /// 산책 일시정지/재시작
  void _pauseWalk() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      // 위치 추적 중지
      ref.read(locationTrackingProvider.notifier).stopTracking();
    } else {
      // 위치 추적 재개
      ref.read(locationTrackingProvider.notifier).startTracking();
    }
  }

  /// 펫 활동 기록 (똥/오줌)
  Future<void> _recordPetActivity(String activityType) async {
    if (!mounted) return;

    final activity = await WalkListActivityHelper.recordPetActivity(
      activityType: activityType,
      context: context,
    );

    if (activity != null) {
      setState(() {
        _petActivities.add(activity);
      });
      WalkListActivityHelper.showActivitySuccessSnackBar(context, activityType);
    } else if (mounted) {
      WalkListActivityHelper.showActivityErrorSnackBar(context);
    }
  }

  /// 산책 정보 카드
  Widget _buildWalkInfoCard(WalkRecordEntity currentWalk) {
    final selectedPets = ref.watch(selectedPetsProvider);
    final distance = currentWalk.distance ?? 0.0;
    final recommendedTime = WalkListPetHelper.getRecommendedWalkTime(
      ref: ref,
      selectedPets: selectedPets,
    );

    // ✅ ValueListenableBuilder로 타이머만 독립적으로 rebuild
    return ValueListenableBuilder<int>(
      valueListenable: _elapsedSecondsNotifier,
      builder: (context, elapsedSeconds, child) {
        return WalkListUiHelper.buildWalkInfoCard(
          elapsedSeconds: elapsedSeconds,
          distance: distance,
          recommendedTime: recommendedTime,
        );
      },
    );
  }

  /// 산책 종료 확인 다이얼로그
  void _showEndWalkDialog() {
    final currentWalk = ref.read(currentWalkProvider);
    if (currentWalk == null) return;

    WalkListDialogHelper.showEndWalkDialog(
      context: context,
      currentWalk: currentWalk,
      elapsedSeconds: _elapsedSecondsNotifier.value,
      controller: _controller,
      petActivities: _petActivities,
      onEndSuccess: () {
        if (mounted) {
          setState(() {
            _petActivities.clear();
            _isPaused = false;
          });
          _elapsedSecondsNotifier.value = 0; // ✅ ValueNotifier 업데이트
        }
      },
    );
  }

  /// 지도 위젯 빌드
  Widget _buildMapWidget(
    List<WalkRecordEntity> walkRecords,
    List<WalkPetInfo> selectedPets,
  ) {
    return MapWidget(
      key: const ValueKey('walk_map_widget'),
      walkRecords: walkRecords,
      // selectedPet은 MapWidget 내부에서 selectedPetsProvider를 watch하여 처리
      petActivities: _petActivities,
      onActivityMarkerTap: (index) => _deleteActivityMarker(index),
    );
  }

  /// 활동 마커 삭제
  void _deleteActivityMarker(int index) {
    if (index < 0 || index >= _petActivities.length) return;

    final activity = _petActivities[index];
    final type = activity['type'] as String;

    WalkListDialogHelper.showDeleteActivityDialog(
      context: context,
      activityType: type,
      onDelete: () {
        if (mounted) {
          setState(() {
            _petActivities.removeAt(index);
          });
        }
      },
    );
  }

  /// 현재 위치로 지도 이동
  Future<void> _moveToCurrentLocation() async {
    await WalkListLocationHelper.moveToCurrentLocation(
      context: context,
      ref: ref,
    );
  }

  void _showWalkRecordsList() {
    // 산책 기록 달력 페이지로 이동
    context.push('/walk/calendar');
  }
}
