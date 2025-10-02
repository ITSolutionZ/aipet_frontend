import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/ui/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pet Basic Info Tab 상태 관리
final petBasicInfoTabProvider =
    StateNotifierProvider.family<PetBasicInfoTabController, PetBasicInfoTabState, String>(
      (ref, tabId) => PetBasicInfoTabController(),
    );

class PetBasicInfoTabController extends StateNotifier<PetBasicInfoTabState> {
  PetBasicInfoTabController() : super(const PetBasicInfoTabState());

  void initialize(PetProfileEntity pet) {
    final nameController = TextEditingController(text: pet.name);
    final appearanceController = TextEditingController(
      text: pet.additionalInfo?['appearance'] ?? '',
    );
    final weightController = TextEditingController(text: pet.weight.toString());
    final microchipController = TextEditingController(
      text: pet.additionalInfo?['microchipId'] ?? '',
    );

    state = state.copyWith(
      nameController: nameController,
      appearanceController: appearanceController,
      weightController: weightController,
      microchipController: microchipController,
      editingGender: pet.gender,
      editingWeight: pet.weight,
    );
  }

  void updateGender(String? gender) {
    state = state.copyWith(editingGender: gender);
  }

  void updateWeight(double? weight) {
    state = state.copyWith(editingWeight: weight);
  }

  @override
  void dispose() {
    state.nameController?.dispose();
    state.appearanceController?.dispose();
    state.weightController?.dispose();
    state.microchipController?.dispose();
    super.dispose();
  }
}

class PetBasicInfoTabState {
  final TextEditingController? nameController;
  final TextEditingController? appearanceController;
  final TextEditingController? weightController;
  final TextEditingController? microchipController;
  final String? editingGender;
  final double? editingWeight;

  const PetBasicInfoTabState({
    this.nameController,
    this.appearanceController,
    this.weightController,
    this.microchipController,
    this.editingGender,
    this.editingWeight,
  });

  PetBasicInfoTabState copyWith({
    TextEditingController? nameController,
    TextEditingController? appearanceController,
    TextEditingController? weightController,
    TextEditingController? microchipController,
    String? editingGender,
    double? editingWeight,
  }) {
    return PetBasicInfoTabState(
      nameController: nameController ?? this.nameController,
      appearanceController: appearanceController ?? this.appearanceController,
      weightController: weightController ?? this.weightController,
      microchipController: microchipController ?? this.microchipController,
      editingGender: editingGender ?? this.editingGender,
      editingWeight: editingWeight ?? this.editingWeight,
    );
  }
}

class PetBasicInfoTab extends ConsumerWidget {
  final PetProfileEntity pet;
  final bool isEditMode;
  final VoidCallback onToggleEdit;

  const PetBasicInfoTab({
    super.key,
    required this.pet,
    required this.isEditMode,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = DateTime.now().millisecondsSinceEpoch.toString();

    // Initialize controller after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petBasicInfoTabProvider(tabId).notifier).initialize(pet);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildProfileImageSection(context),
          const SizedBox(height: AppSpacing.lg),
          _buildBasicInfoCards(context, ref, tabId),
          const SizedBox(height: AppSpacing.lg),
          _buildMicrochipCard(context, ref, tabId),
          const SizedBox(height: AppSpacing.lg),
          _buildDateCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildCaretakerSection(),
          const SizedBox(height: AppSpacing.xl),
          _buildActionButtons(context, ref, tabId),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection(BuildContext context) {
    return GenericInfoCard.withIcon(
      icon: Icons.pets,
      iconColor: AppColors.pointBrown,
      iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
      title: pet.name,
      subtitle: '${pet.type} • ${pet.breed}',
      badge: pet.gender,
      badgeColor: pet.gender == 'Male' ? AppColors.pointBlue : AppColors.pointPink,
      trailing: isEditMode
          ? IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () => _changeProfileImage(context),
            )
          : null,
    );
  }

  Widget _buildBasicInfoCards(BuildContext context, WidgetRef ref, String tabId) {
    final tabState = ref.watch(petBasicInfoTabProvider(tabId));

    return Column(
      children: [
        _buildEditableAttributeCard(
          context,
          ref,
          tabId,
          '名前',
          isEditMode ? (tabState.nameController?.text ?? pet.name) : pet.name,
          type: 'name',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildEditableAttributeCard(
          context,
          ref,
          tabId,
          '性別',
          isEditMode ? (tabState.editingGender ?? pet.gender) : pet.gender,
          type: 'gender',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildEditableAttributeCard(
          context,
          ref,
          tabId,
          '体重',
          isEditMode ? '${tabState.editingWeight ?? pet.weight ?? 0}kg' : '${pet.weight ?? 0}kg',
          type: 'weight',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildEditableAttributeCard(
          context,
          ref,
          tabId,
          '外見',
          isEditMode
              ? (tabState.appearanceController?.text ?? pet.additionalInfo?['appearance'] ?? '未設定')
              : (pet.additionalInfo?['appearance'] ?? '未設定'),
          type: 'appearance',
        ),
      ],
    );
  }

  Widget _buildEditableAttributeCard(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    String label,
    String value, {
    required String type,
  }) {
    return GenericInfoCard.withIcon(
      icon: _getAttributeIcon(type),
      iconColor: AppColors.pointBrown,
      iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
      title: label,
      subtitle: value,
      trailing: isEditMode
          ? IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: () => _editAttribute(context, ref, tabId, type),
            )
          : null,
    );
  }

  Widget _buildMicrochipCard(BuildContext context, WidgetRef ref, String tabId) {
    final tabState = ref.watch(petBasicInfoTabProvider(tabId));
    final microchipId = isEditMode
        ? (tabState.microchipController?.text ?? pet.additionalInfo?['microchipId'] ?? '')
        : pet.additionalInfo?['microchipId'] ?? '';

    return GenericInfoCard.withIcon(
      icon: Icons.memory,
      iconColor: AppColors.pointBlue,
      iconBackgroundColor: AppColors.pointBlue.withValues(alpha: 0.1),
      title: 'マイクロチップ',
      subtitle: microchipId.isEmpty ? '未登録' : microchipId,
      badge: microchipId.isEmpty ? '未登録' : '登録済み',
      badgeColor: microchipId.isEmpty ? AppColors.pointGray : AppColors.pointGreen,
      trailing: isEditMode
          ? IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: () => _editMicrochip(context, ref, tabId),
            )
          : null,
    );
  }

  Widget _buildDateCard() {
    final age = pet.age;
    final birthDate = pet.birthDate;

    return GenericInfoCard.withIcon(
      icon: Icons.cake,
      iconColor: AppColors.pointPink,
      iconBackgroundColor: AppColors.pointPink.withValues(alpha: 0.1),
      title: '誕生日',
      subtitle: birthDate != null
          ? '${birthDate.year}年${birthDate.month}月${birthDate.day}日'
          : '未設定',
      badge: age != null ? '$age歳' : null,
      badgeColor: AppColors.pointPink,
    );
  }

  Widget _buildCaretakerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '家族',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildCaretakerCard('田中 太郎', 'tanaka@example.com'),
        const SizedBox(height: AppSpacing.sm),
        _buildCaretakerCard('田中 花子', 'hanako@example.com'),
      ],
    );
  }

  Widget _buildCaretakerCard(String name, String email) {
    return GenericInfoCard.withIcon(
      icon: Icons.person,
      iconColor: AppColors.pointGray,
      iconBackgroundColor: AppColors.pointGray.withValues(alpha: 0.1),
      title: name,
      subtitle: email,
      badge: '管理者',
      badgeColor: AppColors.pointBrown,
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, String tabId) {
    return ActionButtonGroup.toggle(
      isEditMode: isEditMode,
      onEdit: onToggleEdit,
      onSave: () => _saveChanges(context, ref, tabId),
      onCancel: () => _cancelEdit(ref, tabId),
      editLabel: '編集',
      saveLabel: '保存',
      cancelLabel: 'キャンセル',
    );
  }

  IconData _getAttributeIcon(String type) {
    switch (type) {
      case 'name':
        return Icons.badge;
      case 'gender':
        return Icons.wc;
      case 'weight':
        return Icons.monitor_weight;
      case 'appearance':
        return Icons.palette;
      default:
        return Icons.info;
    }
  }

  void _changeProfileImage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラで撮影'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editAttribute(BuildContext context, WidgetRef ref, String tabId, String type) {
    switch (type) {
      case 'name':
        _showEditNameDialog(context, ref, tabId);
        break;
      case 'gender':
        _showEditGenderDialog(context, ref, tabId);
        break;
      case 'weight':
        _showEditWeightDialog(context, ref, tabId);
        break;
      case 'appearance':
        _showEditAppearanceDialog(context, ref, tabId);
        break;
    }
  }

  void _editMicrochip(BuildContext context, WidgetRef ref, String tabId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('マイクロチップ編集'),
        content: TextField(
          controller: ref.read(petBasicInfoTabProvider(tabId)).microchipController,
          decoration: const InputDecoration(labelText: 'マイクロチップID', hintText: 'マイクロチップIDを入力してください'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _saveChanges(BuildContext context, WidgetRef ref, String tabId) {
    final tabState = ref.read(petBasicInfoTabProvider(tabId));

    // バリデーション
    if (tabState.nameController?.text.trim().isEmpty ?? true) {
      SnackBarService.showError(context, '名前を入力してください');
      return;
    }

    if (tabState.editingWeight != null && tabState.editingWeight! <= 0) {
      SnackBarService.showError(context, '体重は0より大きい値を入力してください');
      return;
    }

    // 変更を保存
    final updatedPet = pet.copyWith(
      name: tabState.nameController?.text.trim() ?? pet.name,
      gender: tabState.editingGender ?? pet.gender,
      weight: tabState.editingWeight ?? pet.weight,
      additionalInfo: {
        ...pet.additionalInfo ?? {},
        'appearance': tabState.appearanceController?.text.trim() ?? '',
        'microchipId': tabState.microchipController?.text.trim() ?? '',
      },
    );

    // TODO: API 호출로 실제 저장
    // await ref.read(petRepositoryProvider).updatePet(updatedPet);
    // updatedPet 변수는 추후 API 호출 시 사용됩니다
    // ignore: unused_local_variable
    final _ = updatedPet; // 사용하지 않는 변수 경고 제거

    SnackBarService.showSaved(context, itemName: 'ペット情報');

    onToggleEdit();
  }

  void _cancelEdit(WidgetRef ref, String tabId) {
    // Reset controllers to original values
    ref.read(petBasicInfoTabProvider(tabId).notifier).initialize(pet);
    onToggleEdit();
  }

  void _pickImageFromCamera(BuildContext context) {
    // TODO: Implement camera functionality
    SnackBarService.showInfo(context, 'カメラ機能は実装予定です');
  }

  void _pickImageFromGallery(BuildContext context) {
    // TODO: Implement gallery picker functionality
    SnackBarService.showInfo(context, 'ギャラリー選択機能は実装予定です');
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String tabId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('名前編集'),
        content: TextField(
          controller: ref.read(petBasicInfoTabProvider(tabId)).nameController,
          decoration: const InputDecoration(labelText: 'ペットの名前', hintText: '名前を入力してください'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showEditGenderDialog(BuildContext context, WidgetRef ref, String tabId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('性別編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('オス'),
              value: 'Male',
              groupValue: ref.watch(petBasicInfoTabProvider(tabId)).editingGender,
              onChanged: (value) {
                ref.read(petBasicInfoTabProvider(tabId).notifier).updateGender(value);
              },
            ),
            RadioListTile<String>(
              title: const Text('メス'),
              value: 'Female',
              groupValue: ref.watch(petBasicInfoTabProvider(tabId)).editingGender,
              onChanged: (value) {
                ref.read(petBasicInfoTabProvider(tabId).notifier).updateGender(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showEditWeightDialog(BuildContext context, WidgetRef ref, String tabId) {
    final tabState = ref.read(petBasicInfoTabProvider(tabId));
    final weightController = TextEditingController(text: tabState.editingWeight?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('体重編集'),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '体重 (kg)',
            hintText: '体重を入力してください',
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                ref.read(petBasicInfoTabProvider(tabId).notifier).updateWeight(weight);
                ref.read(petBasicInfoTabProvider(tabId)).weightController?.text = weight.toString();
                Navigator.pop(context);
              } else {
                SnackBarService.showError(context, '有効な体重を入力してください');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showEditAppearanceDialog(BuildContext context, WidgetRef ref, String tabId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('外見編集'),
        content: TextField(
          controller: ref.read(petBasicInfoTabProvider(tabId)).appearanceController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: '外見の特徴', hintText: 'ペットの外見について説明してください'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
