import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/domain/entities/pet_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/live_walk/live_walk_widget.dart'
    show
        LiveWalkWidget,
        liveWalkControllerProvider,
        WalkTimerState;
import 'helpers/live/helpers.dart';

/// 실시간 산책 화면
class LiveWalkScreen extends ConsumerStatefulWidget {
  final String? petId;
  final String? petName;
  final String? petImage;

  const LiveWalkScreen({super.key, this.petId, this.petName, this.petImage});

  @override
  ConsumerState<LiveWalkScreen> createState() => _LiveWalkScreenState();
}

class _LiveWalkScreenState extends ConsumerState<LiveWalkScreen> {
  String? _selectedPetId;

  @override
  void initState() {
    super.initState();
    _selectedPetId = widget.petId ?? 'pet1';
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 ref.watch() 제거 - LiveWalkScreen은 상태를 감시하지 않음
    // 각 하위 위젯이 필요한 상태만 독립적으로 감시하여 불필요한 rebuild 방지

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 전체 화면 지도 (상태바와 바텀 네비게이터 제외)
          Positioned.fill(
            top: 0,
            bottom: 0,
            child: LiveWalkWidget(
              petId: widget.petId ?? 'pet1',
              petName: widget.petName ?? 'マックス',
            ),
          ),

          // 상단 네비게이션 (뒤로가기 버튼)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: LiveWalkUiHelper.buildCircleButton(
              icon: Icons.arrow_back,
              onPressed: () => _handleBackButton(context),
            ),
          ),

          // 상단 오른쪽 메뉴 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: LiveWalkUiHelper.buildCircleButton(
              icon: Icons.menu,
              onPressed: _showWalkOptions,
            ),
          ),

          // 하단 펫 정보 카드
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 90,
            left: 0,
            right: 0,
            child: Center(child: _buildPetInfoCard()),
          ),

          // 하단 버튼들 (독립적으로 상태 감시)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 20,
            right: 20,
            child: const _BottomButtonsWidget(),
          ),
        ],
      ),
    );
  }

  /// 뒤로가기 버튼 처리
  void _handleBackButton(BuildContext context) {
    final liveWalkState = ref.read(liveWalkControllerProvider);

    if (liveWalkState.isRunning || liveWalkState.isPaused) {
      // 산책 중이면 확인 다이얼로그
      LiveWalkDialogHelper.showBackConfirmDialog(
        context: context,
        ref: ref,
        onConfirm: () =>
            ref.read(liveWalkControllerProvider.notifier).stopWalk(),
      );
    } else {
      context.pop();
    }
  }

  /// 펫 리스트 위젯
  Widget _buildPetInfoCard() {
    // ConsumerWidget으로 분리하여 펫 목록 변경 시에만 rebuild
    return _PetInfoCard(
      selectedPetId: _selectedPetId,
      onPetSelected: (petId) {
        setState(() {
          _selectedPetId = petId;
        });
      },
    );
  }


  /// 옵션 메뉴 표시
  void _showWalkOptions() {
    LiveWalkSheetHelper.showWalkOptionsSheet(
      context: context,
      ref: ref,
      onPause: () => ref.read(liveWalkControllerProvider.notifier).pauseWalk(),
      onCancel: _showCancelWalkDialog,
    );
  }

  /// 산책 취소 확인 다이얼로그
  void _showCancelWalkDialog() {
    LiveWalkDialogHelper.showCancelWalkDialog(
      context: context,
      onConfirm: () =>
          ref.read(liveWalkControllerProvider.notifier).resetWalk(),
    );
  }
}

/// 하단 버튼 위젯 (독립적으로 상태 감시하여 rebuild)
class _BottomButtonsWidget extends ConsumerWidget {
  const _BottomButtonsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🚀 필요한 상태만 select해서 watch
    // timerState만 변경될 때만 이 위젯만 rebuild됨
    final timerState = ref.watch(
      liveWalkControllerProvider.select((state) => state.timerState),
    );

    final isRunning = timerState == WalkTimerState.running;
    final isPaused = timerState == WalkTimerState.paused;

    return LiveWalkUiHelper.buildBottomButtons(
      isRunning: isRunning,
      isPaused: isPaused,
      onShowRecords: () => _showWalkRecordsList(context),
      onWalkButtonPress: () => _handleWalkButton(context, ref),
    );
  }

  /// 산책 버튼 처리
  void _handleWalkButton(BuildContext context, WidgetRef ref) {
    final state = ref.read(liveWalkControllerProvider);
    final notifier = ref.read(liveWalkControllerProvider.notifier);

    if (state.isRunning) {
      // 산책 종료
      _showStopWalkDialog(context, ref);
    } else if (state.isPaused) {
      // 산책 재개
      notifier.resumeWalk();
    } else {
      // 산책 시작
      notifier.startWalk();
    }
  }

  /// 산책 종료 확인 다이얼로그
  void _showStopWalkDialog(BuildContext context, WidgetRef ref) {
    LiveWalkDialogHelper.showStopWalkDialog(
      context: context,
      onConfirm: () => ref.read(liveWalkControllerProvider.notifier).stopWalk(),
    );
  }

  /// 산책 기록 목록 표시
  void _showWalkRecordsList(BuildContext context) {
    LiveWalkSheetHelper.showWalkRecordsSheet(context);
  }
}

/// 펫 정보 카드 위젯 (독립적으로 rebuild)
class _PetInfoCard extends ConsumerWidget {
  final String? selectedPetId;
  final Function(String) onPetSelected;

  const _PetInfoCard({
    required this.selectedPetId,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 이 위젯만 petProfilesProvider를 watch하므로
    // 펫 목록이 변경되어도 LiveWalkScreen 전체는 rebuild되지 않음
    final petsAsync = ref.watch(petProfilesProvider);

    return petsAsync.when(
      data: (pets) => _buildPetList(context, pets),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => const Icon(Icons.error),
    );
  }

  Widget _buildPetList(BuildContext context, List<PetProfileEntity> pets) {
    if (pets.isEmpty) {
      return LiveWalkPetHelper.buildEmptyPetButton(context: context);
    }

    // 펫 리스트가 있는 경우: 가로 스크롤 펫 카드
    return Center(
      child: SizedBox(
        height: 145,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: pets.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final pet = pets[index];
            final isSelected = pet.id == selectedPetId;

            return LiveWalkPetHelper.buildPetCard(
              pet: pet,
              isSelected: isSelected,
              onTap: () => onPetSelected(pet.id),
            );
          },
        ),
      ),
    );
  }
}
