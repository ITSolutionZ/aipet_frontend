import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/pet_profile_entity.dart';
import '../controllers/controllers.dart';
import '../widgets/widgets.dart';

class PetProfileScreen extends ConsumerStatefulWidget {
  final String petId;

  const PetProfileScreen({super.key, required this.petId});

  @override
  ConsumerState<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen>
    with SingleTickerProviderStateMixin {
  
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    
    _controllers = {
      'name': TextEditingController(),
      'appearance': TextEditingController(),
      'weight': TextEditingController(),
      'microchip': TextEditingController(),
    };
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabController = TabController(length: 4, vsync: this);
      ref.read(petProfileNotifierProvider.notifier).setTabController(tabController);
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    // TabController는 자동으로 정리됨
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petProfileState = ref.watch(petProfileNotifierProvider);

    // 프로필 로드가 처음 실행되지 않았다면 실행
    if (!petProfileState.hasProfile && !petProfileState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(petProfileNotifierProvider.notifier).loadPetProfile(
          petId: widget.petId,
          requesterId: 'current_user_id', // TODO: 실제 사용자 ID로 교체
        );
      });
    }

    if (petProfileState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (petProfileState.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${petProfileState.errorMessage}'),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final pet = petProfileState.selectedPet;
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

    return _buildProfileContent(pet);
  }

  Widget _buildProfileContent(PetProfileEntity pet) {
    return Consumer(
      builder: (context, ref, child) {
        final profileState = ref.watch(petProfileNotifierProvider);
        final editState = ref.watch(petEditNotifierProvider);

        return Scaffold(
          backgroundColor: AppColors.pointOffWhite,
          appBar: SoftGradientDrawerAppBar(
            title: 'ペットのプロフィール',
            selectedPetInfo: _buildPetSelector(pet),
          ),
          body: Column(
            children: [
              _buildTabBar(profileState),
              Expanded(
                child: _buildTabContent(pet, editState),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomButtons(pet, editState),
        );
      },
    );
  }

  Widget _buildPetSelector(PetProfileEntity pet) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: GestureDetector(
        onTap: () => _showPetSelectionModal(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              backgroundImage: pet.imagePath != null
                  ? AssetImage(pet.imagePath!)
                  : null,
              child: pet.imagePath == null
                  ? const Icon(
                      Icons.pets,
                      size: 16,
                      color: AppColors.pointBrown,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              pet.name,
              style: AppFonts.bodyMedium.copyWith(
                color: const Color(0xFF5B4034),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF5B4034),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(PetProfileState profileState) {
    if (profileState.tabController == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: AppColors.pointBrown,
      child: TabBar(
        controller: profileState.tabController,
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

  Widget _buildTabContent(PetProfileEntity pet, PetEditState editState) {
    final profileState = ref.watch(petProfileNotifierProvider);
    
    if (profileState.tabController == null) {
      return _buildAboutTab(pet, editState);
    }

    return TabBarView(
      controller: profileState.tabController,
      children: [
        _buildAboutTab(pet, editState),
        _buildHealthTab(),
        _buildNutritionTab(),
        ActivityTab(petId: widget.petId),
      ],
    );
  }

  Widget _buildAboutTab(PetProfileEntity pet, PetEditState editState) {
    return AboutTab(
      pet: pet,
      isEditMode: editState.isEditMode,
      editingValues: editState.editingValues,
      selectedImagePath: editState.selectedImagePath,
      onImageTap: _showImageSourceSelection,
      onValueChanged: (key, value) {
        ref.read(petEditNotifierProvider.notifier).updateEditingValue(key, value);
      },
      controllers: _controllers,
    );
  }

  Widget _buildHealthTab() {
    return HealthTab(petId: widget.petId);
  }

  Widget _buildNutritionTab() {
    return NutritionTab(petId: widget.petId);
  }

  Widget _buildBottomButtons(PetProfileEntity pet, PetEditState editState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: editState.isEditMode
          ? Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _cancelEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointGray,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.large),
                      ),
                    ),
                    child: Text(
                      'キャンセル',
                      style: AppFonts.fredoka(
                        fontSize: AppFonts.lg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: editState.isLoading ? null : () => _saveChanges(pet),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.large),
                      ),
                    ),
                    child: editState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            '完了',
                            style: AppFonts.fredoka(
                              fontSize: AppFonts.lg,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startEdit(pet),
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
    );
  }

  void _startEdit(PetProfileEntity pet) {
    ref.read(petEditNotifierProvider.notifier).startEdit(pet);

    _controllers['name']!.text = pet.name;
    _controllers['appearance']!.text = pet.customFields?['appearance']?.toString() ?? '';
    _controllers['weight']!.text = pet.healthInfo?.weight?.toStringAsFixed(1) ?? '';
    _controllers['microchip']!.text = pet.customFields?['microchipId']?.toString() ?? '';
  }

  void _cancelEdit() {
    ref.read(petEditNotifierProvider.notifier).cancelEdit();
    for (final controller in _controllers.values) {
      controller.clear();
    }
  }

  Future<void> _saveChanges(PetProfileEntity pet) async {
    final success = await ref.read(petEditNotifierProvider.notifier).saveChanges(pet, 'current_user_id');
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ペット情報が正常にアップデートされました。'),
          backgroundColor: AppColors.pointGreen,
        ),
      );
    } else if (mounted) {
      final errorMessage = ref.read(petEditNotifierProvider).errorMessage;
      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.pointPink,
          ),
        );
      }
    }
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'プロフィール写真변경',
              style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  Icons.photo_library,
                  'ギャラリー',
                  AppColors.pointBlue,
                  _selectImageFromGallery,
                ),
                _buildImageOption(
                  Icons.pets,
                  'デフォルト',
                  AppColors.pointBrown,
                  _selectDefaultImage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label),
      ],
    );
  }

  void _selectImageFromGallery() {
    final availableImages = [
      'assets/images/dogs/pomeranian.png',
      'assets/images/dogs/dachshund.png',
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('写真選択'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableImages
              .map((imagePath) => ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage(imagePath)),
                    title: Text(imagePath.split('/').last.split('.').first),
                    onTap: () {
                      ref.read(petEditNotifierProvider.notifier).selectImage(imagePath);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _selectDefaultImage() {
    ref.read(petEditNotifierProvider.notifier).selectImage('default_pet_image');
  }

  void _showPetSelectionModal() {
    // Pet Profile 기능에서는 Pet Selection이 필요 없음
    // 이미 특정 petId로 프로필을 로드하므로 이 메서드는 사용되지 않음
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pet selection not available')),
    );
  }
}