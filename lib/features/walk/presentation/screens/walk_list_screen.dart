import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/walk/data/providers/walk_providers.dart';
import 'package:aipet_frontend/features/walk/domain/entities/pet_info.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/walk_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart'
    hide MapWidget, WalkRecordCardWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final currentWalk = ref.watch(currentWalkNotifierProvider);

    // 새로운 전체 화면 오버레이 레이아웃
    return _buildFullScreenOverlayLayout(selectedPet, walkRecords, currentWalk);
  }

  /// 새로운 전체 화면 오버레이 레이아웃
  Widget _buildFullScreenOverlayLayout(
    PetInfo? selectedPet,
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
            child: MapWidget(
              walkRecords: walkRecords,
              selectedPet: selectedPet,
            ),
          ),

          // 상단 네비게이션 (뒤로가기, 리스트 버튼)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 왼쪽 버튼들 (세로 배치)
                Column(
                  children: [
                    // 뒤로가기/메뉴 버튼 (원형)
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
                        onPressed: widget.showBackButton
                            ? () => Navigator.of(context).pop()
                            : () => Scaffold.of(context).openDrawer(),
                        icon: Icon(
                          widget.showBackButton ? Icons.arrow_back : Icons.menu,
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
                  ],
                ),

                // 리스트 버튼 (원형)
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
              ],
            ),
          ),

          // 하단 버튼들
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 당겨 기록 & 산책 시작 버튼
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: _showWalkRecordsList,
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            '당겨 기록',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.pointBrown,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.pointBrown.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: currentWalk != null
                              ? _showCurrentWalkDialog
                              : _showStartWalkDialog,
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            currentWalk != null ? '산책 중...' : '산책 시작',
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
              ],
            ),
          ),

          // 오른쪽 하단 펫 버튼 (당겨 기록 바로 위)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 90,
            right: 20,
            child: _buildPetFloatingButton(selectedPet),
          ),
        ],
      ),
      drawer: widget.showBackButton ? null : const AppDrawer(),
    );
  }

  /// 오른쪽 하단 펫 선택 버튼 (긴 직사각형)
  Widget _buildPetFloatingButton(PetInfo? selectedPet) {
    final bool isPetSelected = selectedPet != null;

    return InkWell(
      onTap: () {
        // TODO: 펫 선택/비선택 토글
        if (isPetSelected) {
          _controller.setSelectedPet(null); // 선택 해제
        } else {
          // 펫 선택 다이얼로그 표시
          _showPetSelectionDialog();
        }
      },
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 120,
        height: 56,
        decoration: BoxDecoration(
          color: isPetSelected
              ? AppColors.pointBrown
              : AppColors.pointGray.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isPetSelected ? AppColors.pointBrown : AppColors.pointGray,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  (isPetSelected ? AppColors.pointBrown : AppColors.pointGray)
                      .withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 펫 아이콘 또는 발바닥 아이콘
            if (selectedPet?.imageUrl?.startsWith('assets/') == true)
              ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      selectedPet!.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else
              Image.asset(
                'assets/icons/paw_show.png',
                width: 28,
                height: 28,
                color: Colors.white,
              ),
            const SizedBox(width: 8),

            // 선택 표시 아이콘
            Icon(
              isPetSelected ? Icons.check_circle : Icons.add_circle_outline,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 펫 선택 다이얼로그
  void _showPetSelectionDialog() {
    final pets = PetMockData.getMockPets();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ペットを選択'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: pet.imagePath != null
                      ? AssetImage(pet.imagePath!)
                      : null,
                  backgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
                  child: pet.imagePath == null
                      ? const Icon(Icons.pets, color: AppColors.pointBrown)
                      : null,
                ),
                title: Text(
                  pet.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${pet.breed} · ${pet.weight}kg',
                  style: AppTextStyles.bodySmall,
                ),
                onTap: () {
                  // PetProfileEntity를 PetInfo로 변환
                  _controller.setSelectedPet(
                    PetInfo(
                      id: pet.id,
                      name: pet.name,
                      type: pet.type,
                      imageUrl: pet.imagePath,
                    ),
                  );
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  /// 새로운 카드 스타일 레이아웃
  Widget _buildCardStyleLayout(
    PetInfo? selectedPet,
    List<WalkRecordEntity> walkRecords,
    WalkRecordEntity? currentWalk,
  ) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointOffWhite,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              )
            : IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              ),
        title: Text(
          '散歩',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      drawer: widget.showBackButton ? null : const AppDrawer(),
      body: Stack(
        children: [
          // 전체 화면 지도
          MapWidget(walkRecords: walkRecords, selectedPet: selectedPet),

          // 하단 펫 정보 + 버튼 카드
          if (selectedPet != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 펫 정보 카드
                  _buildPetInfoCard(selectedPet),
                  const SizedBox(height: 16),

                  // 버튼 영역
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton.secondary(
                          isEnabled: true,
                          text: '당겨 기록',
                          onPressed: _showWalkRecordsList,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ActionButton.primary(
                          isEnabled: true,
                          text: currentWalk != null ? '산책 중...' : '산책 시작',
                          onPressed: currentWalk != null
                              ? _showCurrentWalkDialog
                              : _showStartWalkDialog,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 반려동물 정보 카드
  Widget _buildPetInfoCard(PetInfo selectedPet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 반려동물 아바타
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.pointBrown, width: 3),
            ),
            child: ClipOval(
              child: selectedPet.imageUrl?.startsWith('assets/') == true
                  ? Image.asset(selectedPet.imageUrl!, fit: BoxFit.cover)
                  : const Icon(
                      Icons.pets,
                      color: AppColors.pointBrown,
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // 반려동물 이름
          Text(
            selectedPet.name,
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // 몸무게와 권장 시간
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '1.9kg', // TODO: selectedPet.weight 사용
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              const SizedBox(width: 16),
              Text(
                '30분 권장', // TODO: 권장 시간 계산
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 전체 화면 맵 빌드 (앱바, 상태바 포함)
  Widget _buildFullScreenMap(
    PetInfo? selectedPet,
    List<WalkRecordEntity> walkRecords,
    WalkRecordEntity? currentWalk,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      drawer: widget.showBackButton ? null : const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          onPressed: () {
            if (widget.showBackButton) {
              Navigator.of(context).pop();
            } else {
              // 드로어 열기
              Scaffold.of(context).openDrawer();
            }
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.showBackButton ? Icons.arrow_back : Icons.menu,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '散歩マップ',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          // 산책 기록 목록 버튼
          IconButton(
            onPressed: _showWalkRecordsList,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.list, color: Colors.white, size: 20),
            ),
          ),
          if (selectedPet != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.pointBrown,
                    ),
                    child: const Icon(
                      Icons.pets,
                      size: 12,
                      color: AppColors.pointOffWhite,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    selectedPet.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // 전체 화면 지도
          MapWidget(walkRecords: walkRecords, selectedPet: selectedPet),

          // 하단 FAB
          Positioned(
            bottom: 30,
            right: 20,
            child: _buildFloatingActionButton(currentWalk),
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

  void _showWalkRecordsList() {
    final walkRecords = ref.read(walkRecordsNotifierProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.pointOffWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 핸들바
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.pointGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 제목
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '散歩記録',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 산책 기록 리스트
            Expanded(child: _buildWalkRecordsList(walkRecords)),
          ],
        ),
      ),
    );
  }

  /// 현재 위치로 지도 이동
  Future<void> _moveToCurrentLocation() async {
    final walkRecords = ref.read(walkRecordsNotifierProvider);
    final selectedPet = ref.read(selectedPetNotifierProvider);
    final params = MapWidgetParams(
      walkRecords: walkRecords,
      selectedPet: selectedPet,
    );
    final controller = ref.read(mapWidgetProvider(params).notifier);

    // 현재 위치 다시 가져오기
    await controller.getCurrentLocation();
  }
}
