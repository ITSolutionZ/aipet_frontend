import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../../pet_activities/data/providers/pet_activities_providers.dart';
import '../../../pet_activities/domain/entities/trick_entity.dart';
import '../controllers/controllers.dart';

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
    // 컨트롤러를 통해 탭 컨트롤러 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(petProfileControllerProvider.notifier)
          .initializeTabController(this);
    });
  }

  @override
  void dispose() {
    // 컨트롤러를 통해 탭 컨트롤러 정리
    ref.read(petProfileControllerProvider.notifier).disposeTabController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: const Text('ペットのプロフィール', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // 펫 선택 드롭다운
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.pets,
                    size: 16,
                    color: AppColors.pointBrown,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(petProfileControllerProvider);
                    return Text(
                      state.selectedPetName,
                      style: AppFonts.bodyMedium.copyWith(color: Colors.white),
                    );
                  },
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 탭 바
          Container(
            color: AppColors.pointBrown,
            child: Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(petProfileControllerProvider);
                return TabBar(
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
                );
              },
            ),
          ),

          // 탭 내용
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(petProfileControllerProvider);
                return TabBarView(
                  controller: state.tabController,
                  children: [
                    _buildAboutTab(),
                    _buildHealthTab(),
                    _buildNutritionTab(),
                    _buildActivityTab(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // 편집 화면으로 이동
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.large),
              ),
            ),
            child: Text(
              '編集',
              style: AppFonts.fredoka(
                fontSize: AppFonts.lg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 펫 기본 정보
          Row(
            children: [
              // 프로필 사진
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.pets,
                  size: 50,
                  color: AppColors.pointBrown,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // 이름과 종류
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ポチ',
                          style: AppFonts.titleLarge.copyWith(
                            color: AppColors.pointDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(
                          Icons.edit,
                          size: 20,
                          color: AppColors.pointBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '犬 | ボーダーコリー',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // 외모 및 특징
          Text(
            '外観と特徴的な特徴',
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'ブラック・ダーク・ホワイトのミックス、軽い眉毛の形状と左前足の心形のパッチ。',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.8),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // 주요 속성
          Text(
            '重要な属性',
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildAttributeCard('性別', '男'),
          const SizedBox(height: AppSpacing.sm),
          _buildAttributeCard('サイズ', '中'),
          const SizedBox(height: AppSpacing.sm),
          _buildAttributeCard('体重', '22.2 kg'),

          const SizedBox(height: AppSpacing.xl),

          // 중요 날짜
          Text(
            '重要な日付',
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDateCard(Icons.cake, '誕生日', '2019年11月3日', '3歳'),
          const SizedBox(height: AppSpacing.sm),
          _buildDateCard(Icons.home, '領養日', '2020年1月6日', null),

          const SizedBox(height: AppSpacing.xl),

          // 보호자
          Text(
            '飼い主',
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildCaretakerCard('エスター・ハワード', 'esther.howard@gmail.com'),
          const SizedBox(height: AppSpacing.sm),
          _buildCaretakerCard('ギャ・ハワード', 'guyhawkins@gmail.com'),
        ],
      ),
    );
  }

  Widget _buildAttributeCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(IconData icon, String label, String date, String? age) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pointBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.pointBlue, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  date,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (age != null)
            Text(
              age,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaretakerCard(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
            child: const Icon(
              Icons.person,
              color: AppColors.pointBrown,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  email,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildHealthCard(
            icon: Icons.security,
            title: '保険',
            iconColor: AppColors.pointBlue,
            onTap: () {
              // 보험 정보 화면으로 이동
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildHealthCard(
            icon: Icons.medical_services,
            title: 'Vaccines',
            iconColor: AppColors.pointGreen,
            onTap: () {
              // 백신 화면으로 이동
              context.push('${AppRouter.vaccinesRoute}?petId=${widget.petId}');
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildHealthCard(
            icon: Icons.medication,
            title: '寄生虫治療',
            iconColor: AppColors.pointPink,
            onTap: () {
              // 구충제/기생충 치료 정보 화면으로 이동
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildHealthCard(
            icon: Icons.hearing,
            title: '医療介入',
            iconColor: Colors.orange,
            onTap: () {
              // 의료 시술/수술 정보 화면으로 이동
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildHealthCard(
            icon: Icons.healing,
            title: 'その他の治療',
            iconColor: Colors.red,
            onTap: () {
              // 기타 치료 정보 화면으로 이동
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),

            // 제목
            Expanded(
              child: Text(
                title,
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // 추가 버튼
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.pointBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.pointBlue,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 음식 타입 카드
          Row(
            children: [
              Expanded(
                child: _buildFoodTypeCard(
                  icon: Icons.eco,
                  title: 'Kibble / Dry',
                  isSelected: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildFoodTypeCard(
                  icon: Icons.restaurant,
                  title: 'Home cooked',
                  isSelected: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // 레시피 및 음식 일지
          _buildNutritionItem(
            icon: Icons.book,
            title: 'Recipes',
            iconColor: AppColors.pointBlue,
            onTap: () {
              // 레시피 화면으로 이동 (Pet Feeding feature)
              context.push('/recipes?petId=${widget.petId}');
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildNutritionItem(
            icon: Icons.pets,
            title: 'Food Journal',
            iconColor: Colors.orange,
            onTap: () {
              // 음식 일지 화면으로 이동
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // 예약된 식사
          Text(
            'Scheduled Meals',
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          _buildScheduledMealCard(
            title: 'Breakfast',
            schedule: 'everyday',
            time: '10:00',
            isEnabled: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildScheduledMealCard(
            title: 'Dinner',
            schedule: 'everyday',
            time: '20:00',
            isEnabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTypeCard({
    required IconData icon,
    required String title,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        // 음식 타입 선택 로직
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointBrown.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isSelected
                ? AppColors.pointBrown
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.pointBrown.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.pointBrown : Colors.grey,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppFonts.bodyMedium.copyWith(
                color: isSelected ? AppColors.pointBrown : AppColors.pointDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                title,
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.pointBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.pointBlue,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledMealCard({
    required String title,
    required String schedule,
    required String time,
    required bool isEnabled,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      schedule,
                      style: AppFonts.bodyMedium.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      time,
                      style: AppFonts.bodyMedium.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              // 스케줄 활성화/비활성화 로직
            },
            activeColor: AppColors.pointBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    final tricksState = ref.watch(allTricksProvider);

    return tricksState.when(
      data: (tricks) => _buildActivityContent(tricks),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('활동 데이터를 불러오는 중 오류가 발생했습니다: $error')),
    );
  }

  Widget _buildActivityContent(List<TrickEntity> tricks) {
    final learnedTricks = tricks
        .where((trick) => trick.progress != null)
        .toList();
    final availableTricks = tricks
        .where((trick) => trick.progress == null)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 배운 트릭 섹션
          if (learnedTricks.isNotEmpty) ...[
            Text(
              '배운 트릭',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...learnedTricks
                .take(3)
                .map((trick) => _buildTrickCard(trick, true)),
            const SizedBox(height: AppSpacing.lg),
          ],

          // 배울 수 있는 트릭 섹션
          if (availableTricks.isNotEmpty) ...[
            Text(
              '다음에 배울 트릭',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...availableTricks
                .take(2)
                .map((trick) => _buildTrickCard(trick, false)),
          ],

          const Spacer(),

          // 교육 영상 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/training-videos'),
              icon: const Icon(Icons.ondemand_video),
              label: const Text('교육 영상 보기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrickCard(TrickEntity trick, bool isLearned) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isLearned
                ? AppColors.pointGreen.withValues(alpha: 0.1)
                : AppColors.pointBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isLearned ? Icons.check : Icons.school,
            color: isLearned ? AppColors.pointGreen : AppColors.pointBlue,
            size: 20,
          ),
        ),
        title: Text(
          trick.name,
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.pointDark,
          ),
        ),
        subtitle: Text(
          isLearned
              ? '완료! (${trick.progress ?? 0}%)'
              : trick.description ?? '설명 없음',
          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
        ),
        trailing: isLearned
            ? const Icon(Icons.check_circle, color: AppColors.pointGreen)
            : const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.pointGray,
                size: 16,
              ),
      ),
    );
  }
}
