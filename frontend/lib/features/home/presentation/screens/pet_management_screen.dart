import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/pet_profile/data/providers/pet_profile_providers.dart';
import '../controllers/pet_management_controller.dart';
import '../widgets/pet_management/pet_card_widget.dart';
import '../widgets/pet_management/pet_empty_state.dart';
import '../widgets/pet_management/pet_qr_dialog.dart';
import '../widgets/pet_management/pet_swipe_background.dart';


/// ペット管理画面
///
/// 注意: 現在home_menu_items.dartでは使用中ですが、将来の機能追加のために全機能を保持
class PetManagementScreen extends ConsumerStatefulWidget {
  const PetManagementScreen({super.key});

  @override
  ConsumerState<PetManagementScreen> createState() =>
      _PetManagementScreenState();
}

class _PetManagementScreenState extends ConsumerState<PetManagementScreen> {
  // 0: 管理中のペット, 1: 非表示のペット
  int _selectedTabIndex = 0;
  late PetManagementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PetManagementController(ref);
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petProfilesProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientAppBar(
        title: '',
        actions: [
          IconButton(
            onPressed: () => context.push('/home'),
            icon: const Icon(Icons.home_outlined, color: AppColors.pointDark),
          ),
        ],
      ),
      body: Column(
        children: [
          // タブセクション
          _buildTabBar(),

          // ボタンセクション
          _buildActionButtons(context),

          // ペットリストセクション
          Expanded(child: _buildPetList(petsAsync)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/daily-pet-registration'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: AppColors.pureWhite,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// タブバーセクション
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.pureWhite,
            AppColors.pointOffWhite.withValues(alpha: 0.9),
            AppColors.pureWhite,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Row(
        children: [
          // 管理中のペット タブ
          _buildTab(
            label: '管理中のペット',
            isSelected: _selectedTabIndex == 0,
            onTap: () => setState(() => _selectedTabIndex = 0),
          ),
          // 非表示のペット タブ
          _buildTab(
            label: '非表示のペット',
            isSelected: _selectedTabIndex == 1,
            onTap: () => setState(() => _selectedTabIndex = 1),
          ),
        ],
      ),
    );
  }

  /// 個別タブ
  Widget _buildTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? AppColors.pointBrown
                    : AppColors.pointOffWhite,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.pointDark : AppColors.pointGray,
            ),
          ),
        ),
      ),
    );
  }

  /// アクションボタンセクション
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.pureWhite,
            AppColors.pointOffWhite.withValues(alpha: 0.7),
            AppColors.pureWhite,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.push('/daily-pet-registration'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                side: const BorderSide(color: AppColors.pointBrown),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '登録したペット',
                style: TextStyle(fontSize: 12, color: AppColors.pointBrown),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // TODO: 共有されたペット機能を実装
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                side: const BorderSide(color: AppColors.pointGray),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '共有されたペット',
                style: TextStyle(fontSize: 12, color: AppColors.pointGray),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ペットリストセクション
  Widget _buildPetList(AsyncValue<List<PetProfileEntity>> petsAsync) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.pointOffWhite.withValues(alpha: 0.9),
            AppColors.pointOffWhite,
            AppColors.pointOffWhite.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: petsAsync.when(
        data: (pets) {
          // タブに応じてペットをフィルタリング
          final filteredPets = _selectedTabIndex == 0
              ? pets.where((p) => p.petStatus != PetStatus.hidden).toList()
              : pets.where((p) => p.petStatus == PetStatus.hidden).toList();

          if (filteredPets.isEmpty) {
            return const PetEmptyState();
          }

          return ListView.builder(
            itemCount: filteredPets.length,
            itemBuilder: (context, index) {
              return _buildDismissiblePetCard(filteredPets[index]);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.pointBrown),
        ),
        error: (error, stack) => const Center(
          child: Text(
            'ペット情報の読み込みに失敗しました',
            style: TextStyle(color: AppColors.pointGray),
          ),
        ),
      ),
    );
  }

  /// Dismissible付きペットカード
  Widget _buildDismissiblePetCard(PetProfileEntity pet) {
    final isHiddenTab = _selectedTabIndex == 1;

    return Dismissible(
      key: Key('pet_${pet.id}'),
      direction: DismissDirection.horizontal,
      background: PetSwipeBackground(isDelete: true, isHiddenTab: isHiddenTab),
      secondaryBackground: PetSwipeBackground(
        isDelete: false,
        isHiddenTab: isHiddenTab,
      ),
      resizeDuration: const Duration(milliseconds: 200),
      confirmDismiss: (direction) async {
        return _controller.showSwipeActionDialog(
          context,
          pet,
          direction,
          isHiddenTab,
        );
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _controller.deletePet(context, pet);
        } else {
          if (isHiddenTab) {
            _controller.restorePet(
              context,
              pet,
              () => setState(() => _selectedTabIndex = 0),
            );
          } else {
            _controller.hidePet(
              context,
              pet,
              () => setState(() => _selectedTabIndex = 1),
            );
          }
        }
      },
      child: PetCardWidget(
        pet: pet,
        onTap: () => context.go('/home/pet-profile/${pet.id}?isEditMode=true'),
        onSharePressed: () => PetQRDialog.show(context, pet),
      ),
    );
  }
}
