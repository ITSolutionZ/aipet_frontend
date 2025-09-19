import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../../pet_activities/data/providers/pet_activities_providers.dart';
import '../../../pet_activities/domain/entities/trick_entity.dart';
import '../../../pet_registor/data/providers/pet_providers.dart';
import '../../../pet_registor/domain/entities/pet_profile_entity.dart';
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
  // 편집 모드 상태
  bool _isEditMode = false;

  // 편집을 위한 컨트롤러들
  late TextEditingController _nameController;
  late TextEditingController _appearanceController;
  late TextEditingController _weightController;
  late TextEditingController _microchipController;

  // 편집 가능한 값들
  String? _editingGender;
  String? _editingSize;
  double? _editingWeight;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();

    // 컨트롤러 초기화
    _nameController = TextEditingController();
    _appearanceController = TextEditingController();
    _weightController = TextEditingController();
    _microchipController = TextEditingController();
    // 컨트롤러를 통해 탭 컨트롤러 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabController = TabController(length: 4, vsync: this);
      ref
          .read(petProfileNotifierProvider.notifier)
          .initializeTabController(tabController);
    });
  }

  @override
  void dispose() {
    // 컨트롤러들 정리
    _nameController.dispose();
    _appearanceController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    // 컨트롤러를 통해 탭 컨트롤러 정리
    ref.read(petProfileNotifierProvider.notifier).disposeTabController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Load pet data based on petId
    final petAsyncValue = ref.watch(petByIdProvider(widget.petId));

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
      data: (pet) {
        // Set the pet data in the controller
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pet != null) {
            ref.read(petProfileNotifierProvider.notifier).selectPet(pet);
          }
        });

        return _buildProfileContent(pet);
      },
    );
  }

  Widget _buildProfileContent(PetProfileEntity? pet) {
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
            child: Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(petProfileNotifierProvider);
                if (state.tabController == null) {
                  return const SizedBox.shrink(); // TabController가 없을 때는 빈 위젯 표시
                }
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
                final state = ref.watch(petProfileNotifierProvider);
                if (state.tabController == null) {
                  return AboutTabWidget(
                    isEditMode: _isEditMode,
                    nameController: _nameController,
                    appearanceController: _appearanceController,
                    microchipController: _microchipController,
                    weightController: _weightController,
                    selectedImagePath: _selectedImagePath,
                    editingGender: _editingGender,
                    editingSize: _editingSize,
                    editingWeight: _editingWeight,
                    onImageSourceSelection: _showImageSourceSelection,
                    onGenderChanged: (value) =>
                        setState(() => _editingGender = value),
                    onSizeChanged: (value) =>
                        setState(() => _editingSize = value),
                    onWeightChanged: (value) =>
                        setState(() => _editingWeight = value),
                  ); // TabController가 없을 때는 기본 탭만 표시
                }
                return TabBarView(
                  controller: state.tabController,
                  children: [
                    AboutTabWidget(
                      isEditMode: _isEditMode,
                      nameController: _nameController,
                      appearanceController: _appearanceController,
                      microchipController: _microchipController,
                      weightController: _weightController,
                      selectedImagePath: _selectedImagePath,
                      editingGender: _editingGender,
                      editingSize: _editingSize,
                      editingWeight: _editingWeight,
                      onImageSourceSelection: _showImageSourceSelection,
                      onGenderChanged: (value) =>
                          setState(() => _editingGender = value),
                      onSizeChanged: (value) =>
                          setState(() => _editingSize = value),
                      onWeightChanged: (value) =>
                          setState(() => _editingWeight = value),
                    ),
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
        child: ProfileEditButtons(
          isEditMode: _isEditMode,
          onEdit: () => _startEdit(pet),
          onSave: () => _saveChanges(pet),
          onCancel: _cancelEdit,
        ),
      ),
    );
  }

  /// 편집 시작
  void _startEdit(PetProfileEntity? pet) {
    if (pet == null) return;

    setState(() {
      _isEditMode = true;
      // 현재 값들을 편집 필드에 설정
      _nameController.text = pet.name;
      _appearanceController.text = pet.additionalInfo?['appearance'] ?? '';
      _editingGender = pet.additionalInfo?['gender'];
      _editingSize = pet.additionalInfo?['size'];
      _editingWeight = pet.additionalInfo?['weight']?.toDouble();
      _weightController.text = _editingWeight?.toStringAsFixed(1) ?? '';
      _microchipController.text = pet.additionalInfo?['microchipId'] ?? '';
      _selectedImagePath = null;
    });
  }

  /// 편집 취소
  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      // 편집 값들 초기화
      _nameController.clear();
      _appearanceController.clear();
      _weightController.clear();
      _microchipController.clear();
      _editingGender = null;
      _editingSize = null;
      _editingWeight = null;
      _selectedImagePath = null;
    });
  }

  /// 변경사항 저장
  Future<void> _saveChanges(PetProfileEntity? pet) async {
    if (pet == null) return;

    try {
      // 업데이트된 펫 프로필 생성
      final updatedPet = pet.copyWith(
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : pet.name,
        imagePath: _selectedImagePath ?? pet.imagePath,
        additionalInfo: {
          ...?pet.additionalInfo,
          if (_appearanceController.text.trim().isNotEmpty)
            'appearance': _appearanceController.text.trim(),
          if (_editingGender != null) 'gender': _editingGender,
          if (_editingSize != null) 'size': _editingSize,
          if (_editingWeight != null) 'weight': _editingWeight,
          if (_microchipController.text.trim().isNotEmpty)
            'microchipId': _microchipController.text.trim(),
        },
      );

      // 펫 정보 업데이트
      await ref.read(petsNotifierProvider.notifier).updatePet(updatedPet);

      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('펫 정보가 성공적으로 업데이트되었습니다.'),
            backgroundColor: AppColors.pointGreen,
          ),
        );
      }

      // 편집 모드 종료
      setState(() {
        _isEditMode = false;
      });
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('업데이트 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.pointPink,
          ),
        );
      }
    }
  }

  /// 이미지 소스 선택 다이얼로그 표시
  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '프로필 사진 변경',
              style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 갤러리에서 선택
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _selectImageFromGallery();
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.pointBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: AppColors.pointBlue,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('ギャラリー'),
                  ],
                ),
                // 기본 이미지로 변경
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _selectDefaultImage();
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.pointBrown.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: AppColors.pointBrown,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('デフォルト'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  /// 갤러리에서 이미지 선택 (시뮬레이션)
  void _selectImageFromGallery() {
    // 실제 구현에서는 image_picker를 사용하지만,
    // 여기서는 시뮬레이션을 위해 기본 이미지 중 하나를 선택
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
              .map(
                (imagePath) => ListTile(
                  leading: CircleAvatar(backgroundImage: AssetImage(imagePath)),
                  title: Text(imagePath.split('/').last.split('.').first),
                  onTap: () {
                    setState(() {
                      _selectedImagePath = imagePath;
                    });
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  /// 기본 이미지로 변경
  void _selectDefaultImage() {
    setState(() {
      _selectedImagePath = null;
    });
  }

  Widget _buildEditableAttributeCard(
    String label,
    String value, {
    required String type,
  }) {
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
          if (_isEditMode)
            _buildEditableField(type, value)
          else
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

  Widget _buildEditableField(String type, String currentValue) {
    switch (type) {
      case 'gender':
        return DropdownButton<String>(
          value: _editingGender,
          hint: const Text('選択'),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('オス')),
            DropdownMenuItem(value: 'female', child: Text('メス')),
          ],
          onChanged: (value) {
            setState(() {
              _editingGender = value;
            });
          },
        );
      case 'size':
        return DropdownButton<String>(
          value: _editingSize,
          hint: const Text('選択'),
          items: const [
            DropdownMenuItem(value: 'small', child: Text('小型')),
            DropdownMenuItem(value: 'medium', child: Text('中型')),
            DropdownMenuItem(value: 'large', child: Text('大型')),
          ],
          onChanged: (value) {
            setState(() {
              _editingSize = value;
            });
          },
        );
      case 'weight':
        return SizedBox(
          width: 100,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            decoration: const InputDecoration(
              suffix: Text('kg'),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              border: OutlineInputBorder(),
            ),
            controller: _weightController,
            onChanged: (value) {
              _editingWeight = double.tryParse(value);
            },
          ),
        );
      default:
        return Text(currentValue);
    }
  }

  Widget _buildMicrochipCard(PetProfileEntity pet) {
    final microchipId = _isEditMode
        ? _microchipController.text
        : pet.additionalInfo?['microchipId'] ?? '';

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
              color: AppColors.pointGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.memory,
              color: AppColors.pointGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'マイクロチップ番号',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (_isEditMode)
                  TextField(
                    controller: _microchipController,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'マイクロチップ番号を入力',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                    ),
                  )
                else
                  Text(
                    microchipId.isEmpty ? '未登録' : microchipId,
                    style: AppFonts.bodyMedium.copyWith(
                      color: microchipId.isEmpty
                          ? AppColors.pointGray
                          : AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
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
              '次に学ぶトリック',
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
              label: const Text('教育動画を見る'),
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
              ? '完了！(${trick.progress ?? 0}%)'
              : trick.description ?? '説明なし',
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
