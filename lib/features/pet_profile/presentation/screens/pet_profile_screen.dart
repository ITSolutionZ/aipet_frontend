import 'package:aipet_frontend/features/pet_profile/presentation/constants/pet_profile_constants.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_unified_controller.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/widgets/tabs/pet_activity_tab.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/widgets/tabs/pet_adoption_tab.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/widgets/tabs/pet_basic_info_tab.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/widgets/tabs/pet_health_tab.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/widgets/tabs/pet_nutrition_tab.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pet Profile 화면
///
/// Clean Architecture를 적용하여 로직과 UI를 완전히 분리했습니다.
/// 재사용 가능한 컴포넌트들을 사용하여 유지보수성을 높였습니다.
class PetProfileScreen extends ConsumerStatefulWidget {
  final String petId;

  const PetProfileScreen({super.key, required this.petId});

  @override
  ConsumerState<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _loadPetProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Widget이 dispose되기 전에 ref 사용을 피함
    super.dispose();
  }

  void _initializeTabController() {
    _tabController = TabController(
      length: PetProfileConstants.tabCount,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(petProfileUnifiedControllerProvider.notifier)
          .initializeTabController(_tabController);
    });
  }

  void _loadPetProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(petProfileUnifiedControllerProvider.notifier)
          .loadPetProfile(widget.petId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(petProfileUnifiedControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: _buildAppBar(context, state),
      body: _buildBody(context, state),
      bottomNavigationBar: _buildBottomNavigationBar(context, state),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    PetProfileUnifiedState state,
  ) {
    // 에러 상태나 펫을 찾을 수 없는 상태에서는 뒤로가기 버튼과 액션 버튼들을 숨김
    if (state.errorMessage != null || state.selectedPet == null) {
      return const SoftGradientAppBar(
        title: 'ペットプロフィール',
        leading: null, // 뒤로가기 버튼 제거
        actions: null, // 액션 버튼들 제거
      );
    }

    return SoftGradientAppBar(
      title: state.selectedPet?.name ?? 'ペットプロフィール',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (!state.isEditMode) ...[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditScreen(context, state.selectedPet!),
            tooltip: PetProfileConstants.editLabel,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(context),
            tooltip: 'メニュー',
          ),
        ],
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pointOffWhite,
        border: Border(
          bottom: BorderSide(
            color: AppColors.pointGray.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: AppColors.pointBrown,
          indicatorWeight: 3,
          labelColor: AppColors.pointDark,
          unselectedLabelColor: AppColors.pointGray,
          labelStyle: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppFonts.bodyMedium,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          tabAlignment: TabAlignment.fill,
          tabs: PetProfileConstants.tabTitles
              .map((title) => Tab(text: title))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PetProfileUnifiedState state) {
    debugPrint(
      '🔍 PetProfileScreen _buildBody: isLoading=${state.isLoading}, errorMessage=${state.errorMessage}, selectedPet=${state.selectedPet?.name}',
    );

    if (state.isLoading) {
      debugPrint('🔍 Showing loading widget');
      return const _LoadingWidget();
    }

    if (state.errorMessage != null) {
      debugPrint('🔍 Showing error widget: ${state.errorMessage}');
      return _ErrorWidget(
        error: state.errorMessage!,
        onRetry: () => _loadPetProfile(),
      );
    }

    if (state.selectedPet == null) {
      debugPrint('🔍 Showing pet not found widget');
      return const _PetNotFoundWidget();
    }

    debugPrint(
      '🔍 Showing pet profile content for: ${state.selectedPet!.name}',
    );

    return Column(
      children: [
        // TabBar 추가
        Container(color: AppColors.pointOffWhite, child: _buildTabBar()),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              PetBasicInfoTab(
                pet: state.selectedPet!,
                isEditMode: state.isEditMode,
                onToggleEdit: _toggleEditMode,
              ),
              PetHealthTab(pet: state.selectedPet!),
              PetNutritionTab(pet: state.selectedPet!),
              PetActivityTab(pet: state.selectedPet!),
              PetAdoptionTab(pet: state.selectedPet!),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _buildBottomNavigationBar(
    BuildContext context,
    PetProfileUnifiedState state,
  ) {
    if (state.selectedPet == null || state.isEditMode) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ElevatedButton(
        onPressed: () => _navigateToEditScreen(context, state.selectedPet!),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointBrown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        child: const Text(PetProfileConstants.editLabel),
      ),
    );
  }

  void _toggleEditMode() {
    ref.read(petProfileUnifiedControllerProvider.notifier).toggleEditMode();
  }

  /// 편집 화면으로 이동 (펫 등록 화면을 편집 모드로 사용)
  void _navigateToEditScreen(BuildContext context, PetProfileEntity pet) {
    context.go('/daily-pet-registration?petId=${pet.id}');
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text(PetProfileConstants.shareLabel),
              onTap: () {
                Navigator.pop(context);
                _shareProfile(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.pointRed),
              title: const Text(
                PetProfileConstants.deleteLabel,
                style: TextStyle(color: AppColors.pointRed),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareProfile(BuildContext context) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('共有機能は今後実装予定です')));
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(PetProfileConstants.deleteConfirmDialogTitle),
        content: const Text(PetProfileConstants.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(PetProfileConstants.cancelLabel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProfile(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointRed,
              foregroundColor: Colors.white,
            ),
            child: const Text(PetProfileConstants.deleteLabel),
          ),
        ],
      ),
    );
  }

  void _deleteProfile(BuildContext context) async {
    try {
      await ref
          .read(petProfileUnifiedControllerProvider.notifier)
          .deletePetProfile();

      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          PetProfileConstants.deleteSuccessMessage,
        );
        context.go('/home');
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(
          context,
          PetProfileConstants.deleteErrorMessage,
        );
      }
    }
  }
}

/// 로딩 위젯
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.pointBrown),
          SizedBox(height: AppSpacing.md),
          Text(
            PetProfileConstants.loadingMessage,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// 에러 위젯
class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const _ErrorWidget({required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.pointRed),
          const SizedBox(height: AppSpacing.lg),
          Text(
            PetProfileConstants.errorMessage,
            style: AppFonts.headlineSmall.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            error,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (onRetry != null)
            ElevatedButton(onPressed: onRetry, child: const Text('再試行')),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text(PetProfileConstants.goHomeButton),
          ),
        ],
      ),
    );
  }
}

/// 펫을 찾을 수 없을 때 위젯
class _PetNotFoundWidget extends StatelessWidget {
  const _PetNotFoundWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, size: 64, color: AppColors.pointBrown),
          const SizedBox(height: AppSpacing.lg),
          Text(
            PetProfileConstants.petNotFoundMessage,
            style: AppFonts.headlineSmall.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text(PetProfileConstants.goHomeButton),
              ),
              const SizedBox(width: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  // 현재 화면을 다시 로드
                  final petId = (context.widget as PetProfileScreen).petId;
                  context.go('/pet-profile/$petId');
                },
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
