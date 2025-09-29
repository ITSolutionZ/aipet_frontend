import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/walk/data/providers/walk_providers.dart';
import 'package:aipet_frontend/features/walk/domain/entities/pet_info.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/walk_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        type: 'dog',
        imageUrl: 'assets/images/dogs/shiba.png',
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
                const const const SizedBox(width: AppSpacing.xs),
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
                const const const SizedBox(width: AppSpacing.md),
              ],
            )
          : null,
    );
  }

  Widget _buildMapSection(bool mapExpanded) {
    final walkRecords = ref.watch(walkRecordsNotifierProvider);
    final selectedPet = ref.watch(selectedPetNotifierProvider);

    return Container(
      height: mapExpanded ? MediaQuery.of(context).size.height * 0.6 : 200,
      margin: const const const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Stack(
        children: [
          // 지도 위젯
          MapWidget(walkRecords: walkRecords, selectedPet: selectedPet),

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
      padding: const const const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 페이지 인디케이터
          _buildPageIndicator(),
          const const const SizedBox(height: AppSpacing.md),

          // 산책 기록 리스트
          Expanded(
            child: ListView.builder(
              itemCount: walkRecords.length,
              itemBuilder: (context, index) {
                final walkRecord = walkRecords[index];
                return Padding(
                  padding: const const const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => _showWalkDetails(walkRecord),
                    onLongPress: () => _showWalkOptions(walkRecord),
                    child: WalkRecordCardWidget(
                      walkRecord: walkRecord,
                      onTap: () => _showWalkDetails(walkRecord),
                    ),
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
        const const const SizedBox(width: AppSpacing.xs),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.pointGray.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
        const const const SizedBox(width: AppSpacing.xs),
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
          const const const SizedBox(height: AppSpacing.md),
          Text(
            '散歩記録がありません。',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
          const const const SizedBox(height: AppSpacing.sm),
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
    // TODO: StartWalkBottomSheet 구현 필요
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('산책 시작'),
        content: const Text('산책을 시작하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.startNewWalk(
                title: 'New Walk',
                petId: 'pet1',
                petName: 'Maxi',
              );
            },
            child: const Text('시작'),
          ),
        ],
      ),
    );
  }

  void _showCurrentWalkDialog() {
    final currentWalk = _controller.getCurrentWalk();
    if (currentWalk != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('진행 중인 산책'),
          content: Text('${currentWalk.petName}과(와) 산책 중입니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('계속'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.endCurrentWalk();
              },
              child: const Text('종료'),
            ),
          ],
        ),
      );
    }
  }

  void _showWalkDetails(WalkRecordEntity walkRecord) {
    context.push(AppRouter.walkDetailRoute, extra: walkRecord);
  }

  void _showWalkOptions(WalkRecordEntity walkRecord) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('수정'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: 수정 다이얼로그 구현
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('삭제'),
            onTap: () {
              Navigator.of(context).pop();
              _controller.deleteWalkRecord(walkRecord.id);
            },
          ),
        ],
      ),
    );
  }
}

// StartWalkDialog는 별도 파일로 분리됨

// EditWalkDialog는 별도 파일로 분리됨

// CurrentWalkDialog는 별도 파일로 분리됨

// WalkOptionsBottomSheet는 별도 파일로 분리됨
