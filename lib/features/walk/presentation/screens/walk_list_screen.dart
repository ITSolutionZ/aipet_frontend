import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../data/walk_providers.dart';
import '../../domain/entities/walk_record_entity.dart';
import '../controllers/walk_controller.dart';
import '../widgets/dialogs/dialogs.dart';
import '../widgets/map_widget.dart';
import '../widgets/walk_record_card_widget.dart';

class WalkListScreen extends ConsumerStatefulWidget {
  final bool showBackButton;

  const WalkListScreen({super.key, this.showBackButton = false});

  @override
  ConsumerState<WalkListScreen> createState() => _WalkListScreenState();
}

class _WalkListScreenState extends ConsumerState<WalkListScreen> {
  late final WalkController _controller;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _controller = WalkController(ref);
    _loadInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _controller.loadWalkRecords();

    // 기본 반려동물 설정
    _controller.setSelectedPet(
      const PetInfo(
        id: 'pet1',
        name: 'Maxi',
        imagePath: 'assets/images/dogs/shiba.png',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPet = ref.watch(selectedPetNotifierProvider);
    final walkRecords = ref.watch(walkRecordsNotifierProvider);
    final mapExpanded = ref.watch(mapExpandedNotifierProvider);
    final currentWalk = ref.watch(currentWalkNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: widget.showBackButton ? null : const AppDrawer(),
      appBar: widget.showBackButton
          ? _buildBackAppBar()
          : _buildDrawerAppBar(selectedPet),
      body: Column(
        children: [
          // 지도 섹션
          _buildMapSection(mapExpanded),

          // 산책 기록 리스트
          Expanded(child: _buildWalkRecordsList(walkRecords)),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(currentWalk),
    );
  }

  /// 뒤로가기 버튼이 있는 AppBar (홈에서 접근 시)
  PreferredSizeWidget _buildBackAppBar() {
    return const BackAppBar(title: '散歩');
  }

  /// Drawer가 있는 AppBar (drawer에서 접근 시)
  PreferredSizeWidget _buildDrawerAppBar(PetInfo? selectedPet) {
    return DrawerAppBar(
      title: '散歩',
      selectedPetInfo: selectedPet != null
          ? Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.pointBrown,
                  ),
                  child: const Icon(
                    Icons.pets,
                    size: 16,
                    color: AppColors.pointOffWhite,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  selectedPet.name,
                  style: AppFonts.fredoka(
                    fontSize: AppFonts.lg,
                    color: AppColors.pointOffWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.pointOffWhite,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
            )
          : null,
    );
  }

  Widget _buildMapSection(bool mapExpanded) {
    return Container(
      height: mapExpanded ? MediaQuery.of(context).size.height * 0.6 : 200,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Stack(
        children: [
          // 지도 위젯
          MapWidget(
            walkRecords: ref.watch(walkRecordsNotifierProvider),
            selectedPet: ref.watch(selectedPetNotifierProvider),
          ),

          // 지도 확장 버튼
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: GestureDetector(
              onTap: _controller.toggleMapExpanded,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.pointDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  mapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: AppColors.pointOffWhite,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalkRecordsList(List<WalkRecordEntity> walkRecords) {
    if (walkRecords.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 페이지 인디케이터
          _buildPageIndicator(),
          const SizedBox(height: AppSpacing.md),

          // 산책 기록 리스트
          Expanded(
            child: ListView.builder(
              itemCount: walkRecords.length,
              itemBuilder: (context, index) {
                final walkRecord = walkRecords[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: WalkRecordCardWidget(
                    walkRecord: walkRecord,
                    onTap: () => _showWalkDetails(walkRecord),
                    onLongPress: () => _showWalkOptions(walkRecord),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.pointBrown,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.pointGray.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.pointGray.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_walk,
            size: 64,
            color: AppColors.pointGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '散歩記録がありません。',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '一番目の散歩を始めてみてください。',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointGray.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(WalkRecordEntity? currentWalk) {
    if (currentWalk != null) {
      // 진행 중인 산책이 있는 경우
      return FloatingActionButton.extended(
        onPressed: _showCurrentWalkDialog,
        backgroundColor: AppColors.pointBrown,
        icon: const Icon(Icons.pause, color: AppColors.pointOffWhite),
        label: Text(
          '散歩中...',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointOffWhite),
        ),
      );
    } else {
      // 새 산책 시작 버튼
      return FloatingActionButton.extended(
        onPressed: _showStartWalkDialog,
        backgroundColor: AppColors.pointBrown,
        icon: const Icon(Icons.directions_walk, color: AppColors.pointOffWhite),
        label: Text(
          '散歩始め',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointOffWhite),
        ),
      );
    }
  }

  void _showStartWalkDialog() {
    StartWalkBottomSheet.show(context, _controller);
  }

  void _showCurrentWalkDialog() {
    final currentWalk = _controller.getCurrentWalk();
    if (currentWalk != null) {
      showDialog(
        context: context,
        builder: (context) =>
            CurrentWalkDialog(walkRecord: currentWalk, controller: _controller),
      );
    }
  }

  void _showWalkDetails(WalkRecordEntity walkRecord) {
    context.push(AppRouter.walkDetailRoute, extra: walkRecord);
  }

  void _showWalkOptions(WalkRecordEntity walkRecord) {
    showModalBottomSheet(
      context: context,
      builder: (context) => WalkOptionsBottomSheet(
        walkRecord: walkRecord,
        controller: _controller,
      ),
    );
  }
}

// StartWalkDialog는 별도 파일로 분리됨

// EditWalkDialog는 별도 파일로 분리됨

// CurrentWalkDialog는 별도 파일로 분리됨

// WalkOptionsBottomSheet는 별도 파일로 분리됨
