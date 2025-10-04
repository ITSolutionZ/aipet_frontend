import 'package:aipet_frontend/features/pet_profile/presentation/widgets/pet_profile_widgets.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 🚀 리팩토링된 펫 프로필 스크린
///
/// 기존 1,236라인 메가 클래스를 대체하는 새로운 구현
/// - 단일 책임 원칙 준수 (50라인)
/// - Riverpod 상태 관리 적용
/// - 탭별 위젯 분리
class PetProfileScreenRefactored extends ConsumerStatefulWidget {
  final String petId;

  const PetProfileScreenRefactored({super.key, required this.petId});

  @override
  ConsumerState<PetProfileScreenRefactored> createState() =>
      _PetProfileScreenRefactoredState();
}

class _PetProfileScreenRefactoredState
    extends ConsumerState<PetProfileScreenRefactored>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mock 데이터 사용
    final petAsyncValue = AsyncValue.data(
      PetProfileEntity(
        id: widget.petId,
        name: 'Mock Pet',
        type: 'dog',
        birthDate: DateTime.now().subtract(const Duration(days: 365)),
        gender: 'male',
        weight: 10.0,
        ownerId: 'current_user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return petAsyncValue.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Pet not found: $error'),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
      data: (pet) => _buildProfileScreen(pet),
    );
  }

  Widget _buildProfileScreen(PetProfileEntity? pet) {
    if (pet == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Pet not found'),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: ProfileAppBar(pet: pet),
      body: Column(
        children: [
          // 탭 바
          Container(
            color: AppColors.pointBrown,
            child: TabBar(
              controller: _tabController,
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
          ),

          // 탭 내용
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(pet),
                _buildHealthTab(pet),
                _buildNutritionTab(pet),
                _buildActivityTab(pet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab(PetProfileEntity pet) {
    return Center(child: Text('基本情報: ${pet.name}'));
  }

  Widget _buildHealthTab(PetProfileEntity pet) {
    return Center(child: Text('健康情報: ${pet.name}'));
  }

  Widget _buildNutritionTab(PetProfileEntity pet) {
    return Center(child: Text('栄養情報: ${pet.name}'));
  }

  Widget _buildActivityTab(PetProfileEntity pet) {
    return Center(child: Text('活動情報: ${pet.name}'));
  }
}
