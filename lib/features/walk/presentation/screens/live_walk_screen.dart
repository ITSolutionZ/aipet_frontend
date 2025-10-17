import 'package:aipet_frontend/shared/widgets/walk/live_walk_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/domain/entities/pet_profile_entity.dart';
import '../../../pet_profile/data/providers/pet_profile_providers.dart';
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
    final liveWalkState = ref.watch(liveWalkProvider);

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

          // 하단 버튼들
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 20,
            right: 20,
            child: LiveWalkUiHelper.buildBottomButtons(
              isRunning: liveWalkState.isRunning,
              isPaused: liveWalkState.isPaused,
              onShowRecords: _showWalkRecordsList,
              onWalkButtonPress: () => _handleWalkButton(liveWalkState),
            ),
          ),
        ],
      ),
    );
  }

  /// 뒤로가기 버튼 처리
  void _handleBackButton(BuildContext context) {
    final liveWalkState = ref.read(liveWalkProvider);

    if (liveWalkState.isRunning || liveWalkState.isPaused) {
      // 산책 중이면 확인 다이얼로그
      LiveWalkDialogHelper.showBackConfirmDialog(
        context: context,
        ref: ref,
        onConfirm: () => ref.read(liveWalkProvider.notifier).stopWalk(),
      );
    } else {
      context.pop();
    }
  }

  /// 펫 리스트 위젯
  Widget _buildPetInfoCard() {
    // 로컬 저장소에서 펫 데이터 가져오기
    final petsAsync = ref.watch(petProfilesProvider);

    return petsAsync.when(
      data: (pets) => _buildPetList(pets),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => const Icon(Icons.error),
    );
  }

  Widget _buildPetList(List<PetProfileEntity> pets) {
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
            final isSelected = pet.id == _selectedPetId;

            return LiveWalkPetHelper.buildPetCard(
              pet: pet,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedPetId = pet.id;
                });
              },
            );
          },
        ),
      ),
    );
  }

  /// 산책 버튼 처리
  void _handleWalkButton(LiveWalkState state) {
    if (state.isRunning) {
      // 산책 종료
      _showStopWalkDialog();
    } else if (state.isPaused) {
      // 산책 재개
      ref.read(liveWalkProvider.notifier).resumeWalk();
    } else {
      // 산책 시작
      ref.read(liveWalkProvider.notifier).startWalk();
    }
  }

  /// 산책 종료 확인 다이얼로그
  void _showStopWalkDialog() {
    LiveWalkDialogHelper.showStopWalkDialog(
      context: context,
      onConfirm: () => ref.read(liveWalkProvider.notifier).stopWalk(),
    );
  }

  /// 산책 기록 목록 표시
  void _showWalkRecordsList() {
    LiveWalkSheetHelper.showWalkRecordsSheet(context);
  }

  /// 옵션 메뉴 표시
  void _showWalkOptions() {
    LiveWalkSheetHelper.showWalkOptionsSheet(
      context: context,
      ref: ref,
      onPause: () => ref.read(liveWalkProvider.notifier).pauseWalk(),
      onCancel: _showCancelWalkDialog,
    );
  }

  /// 산책 취소 확인 다이얼로그
  void _showCancelWalkDialog() {
    LiveWalkDialogHelper.showCancelWalkDialog(
      context: context,
      onConfirm: () => ref.read(liveWalkProvider.notifier).resetWalk(),
    );
  }
}
