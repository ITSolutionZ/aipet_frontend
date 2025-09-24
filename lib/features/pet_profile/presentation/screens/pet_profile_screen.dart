import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_controller.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/widgets/pet_profile_widgets.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 리팩토링된 Pet Profile 화면
///
/// 기존 1,229라인에서 약 150라인으로 축소
/// 로직과 UI 완전 분리, 재사용 가능한 위젯들로 구성

class PetProfileScreen extends ConsumerStatefulWidget {
  final String petId;

  const PetProfileScreen({super.key, required this.petId});

  @override
  ConsumerState<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _initializeTabController();
  }

  @override
  void dispose() {
    _disposeTabController();
    super.dispose();
  }

  void _initializeTabController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabController = TabController(length: 4, vsync: this);
      ref
          .read(petProfileNotifierProvider.notifier)
          .initializeTabController(tabController);
    });
  }

  void _disposeTabController() {
    ref.read(petProfileNotifierProvider.notifier).disposeTabController();
  }

  @override
  Widget build(BuildContext context) {
    final petAsyncValue = ref.watch(petByIdProvider(widget.petId));

    return petAsyncValue.when(
      loading: () => const _LoadingScreen(),
      error: (error, stackTrace) => _ErrorScreen(error: error),
      data: (pet) => pet != null
          ? _PetProfileContent(pet: pet)
          : const _PetNotFoundScreen(),
    );
  }
}

/// 로딩 화면
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.pointBrown),
      ),
    );
  }
}

/// 에러 화면
class _ErrorScreen extends StatelessWidget {
  final Object error;

  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.pointPink,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '펫을 찾을 수 없습니다',
              style: AppFonts.headlineSmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              error.toString(),
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            CommonButton(
              text: '홈으로 돌아가기',
              type: ButtonType.primary,
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 펫을 찾을 수 없을 때 화면
class _PetNotFoundScreen extends StatelessWidget {
  const _PetNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 64, color: AppColors.pointBrown),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '펫을 찾을 수 없습니다',
              style: AppFonts.headlineSmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            CommonButton(
              text: '홈으로 돌아가기',
              type: ButtonType.primary,
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 메인 펫 프로필 컨텐츠
class _PetProfileContent extends ConsumerStatefulWidget {
  final PetProfileEntity pet;

  const _PetProfileContent({required this.pet});

  @override
  ConsumerState<_PetProfileContent> createState() => _PetProfileContentState();
}

class _PetProfileContentState extends ConsumerState<_PetProfileContent> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 펫 데이터를 컨트롤러에 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petProfileNotifierProvider.notifier).selectPet(widget.pet);
    });

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: DynamicAppBarStyles.brown(
        scrollController: _scrollController,
        title: widget.pet.name,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to edit screen or show edit options
            },
            icon: const Icon(Icons.edit),
            tooltip: '編集',
          ),
          IconButton(
            onPressed: () {
              // Show more options menu
            },
            icon: const Icon(Icons.more_vert),
            tooltip: 'メニュー',
          ),
        ],
      ),
      body: Column(
        children: [
          _PetProfileTabBar(),
          Expanded(child: _PetProfileTabContent(pet: widget.pet)),
        ],
      ),
      bottomNavigationBar: PetProfileActionButtons(
        pet: widget.pet,
        onEditComplete: () {
          // 편집 완료 후 추가 작업이 필요하면 여기에 구현
        },
      ),
    );
  }
}

/// 탭 바 위젯
class _PetProfileTabBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(petProfileNotifierProvider);

    if (state.tabController == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: AppColors.pointBrown,
      child: TabBar(
        controller: state.tabController,
        indicatorColor: Colors.yellow,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        tabs: const [
          Tab(text: '基本情報'),
          Tab(text: '健康'),
          Tab(text: '栄養'),
          Tab(text: '活動'),
        ],
      ),
    );
  }
}

/// 탭 컨텐츠 위젯
class _PetProfileTabContent extends ConsumerWidget {
  final PetProfileEntity pet;

  const _PetProfileTabContent({required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(petProfileNotifierProvider);

    if (state.tabController == null) {
      return _BasicInfoTab(pet: pet);
    }

    return TabBarView(
      controller: state.tabController,
      children: [
        _BasicInfoTab(pet: pet),
        _HealthTab(pet: pet),
        _NutritionTab(pet: pet),
        _ActivityTab(pet: pet),
      ],
    );
  }
}

/// 기본 정보 탭
class _BasicInfoTab extends ConsumerWidget {
  final PetProfileEntity pet;

  const _BasicInfoTab({required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100), // 하단 버튼 공간 확보
      child: PetProfileBasicInfoForm(
        pet: pet,
        onImageTap: () => PetProfileImagePicker.show(context, ref),
      ),
    );
  }
}

/// 건강 탭 (임시 구현)
class _HealthTab extends StatelessWidget {
  final PetProfileEntity pet;

  const _HealthTab({required this.pet});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '건강 정보\n(구현 예정)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: AppColors.pointDark),
      ),
    );
  }
}

/// 영양 탭 (임시 구현)
class _NutritionTab extends StatelessWidget {
  final PetProfileEntity pet;

  const _NutritionTab({required this.pet});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '영양 정보\n(구현 예정)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: AppColors.pointDark),
      ),
    );
  }
}

/// 활동 탭 (임시 구현)
class _ActivityTab extends StatelessWidget {
  final PetProfileEntity pet;

  const _ActivityTab({required this.pet});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '활동 정보\n(구현 예정)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: AppColors.pointDark),
      ),
    );
  }
}
