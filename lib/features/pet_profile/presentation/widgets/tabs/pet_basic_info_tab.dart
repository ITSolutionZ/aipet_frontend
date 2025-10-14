import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/ui/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'helpers/helpers.dart';

/// Pet Basic Info Tab 상태 관리
final petBasicInfoTabProvider =
    StateNotifierProvider.family<
      PetBasicInfoTabController,
      PetBasicInfoTabState,
      String
    >((ref, tabId) => PetBasicInfoTabController());

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

  void updateSelectedImage(String? imagePath) {
    state = state.copyWith(selectedImagePath: imagePath);
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
  final String? selectedImagePath;

  const PetBasicInfoTabState({
    this.nameController,
    this.appearanceController,
    this.weightController,
    this.microchipController,
    this.editingGender,
    this.editingWeight,
    this.selectedImagePath,
  });

  PetBasicInfoTabState copyWith({
    TextEditingController? nameController,
    TextEditingController? appearanceController,
    TextEditingController? weightController,
    TextEditingController? microchipController,
    String? editingGender,
    double? editingWeight,
    String? selectedImagePath,
  }) {
    return PetBasicInfoTabState(
      nameController: nameController ?? this.nameController,
      appearanceController: appearanceController ?? this.appearanceController,
      weightController: weightController ?? this.weightController,
      microchipController: microchipController ?? this.microchipController,
      editingGender: editingGender ?? this.editingGender,
      editingWeight: editingWeight ?? this.editingWeight,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
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
          _buildProfileImageSection(context, ref, tabId),
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

  Widget _buildProfileImageSection(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    final tabState = ref.watch(petBasicInfoTabProvider(tabId));
    final displayImagePath = tabState.selectedImagePath ?? pet.imagePath;
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.pointGray.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: displayImagePath != null
                ? PetInfoImageHelper.buildImageWidget(displayImagePath)
                : Container(
                    color: AppColors.pointGray.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.pets,
                      size: 40,
                      color: AppColors.pointGray,
                    ),
                  ),
          ),
        ),
        if (isEditMode) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => PetInfoImageHelper.showChangeProfileImageModal(
              context,
              ref,
              tabId,
              pet.id,
            ),
            icon: const Icon(Icons.camera_alt),
            label: const Text('写真を変更'),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        GenericInfoCard.withIcon(
          icon: Icons.pets,
          iconColor: AppColors.pointBrown,
          iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
          title: pet.name,
          subtitle: '${pet.type} • ${pet.breed}',
          badge: pet.gender,
          badgeColor: pet.gender == 'Male'
              ? AppColors.pointBlue
              : AppColors.pointPink,
        ),
      ],
    );
  }

  Widget _buildBasicInfoCards(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    final tabState = ref.watch(petBasicInfoTabProvider(tabId));

    return Column(
      children: [
        _buildEditableAttributeCard(
          context,
          ref,
          tabId,
          '名前',
          isEditMode
              ? (tabState.nameController?.text.isNotEmpty == true
                    ? tabState.nameController!.text
                    : pet.name)
              : pet.name,
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
          isEditMode
              ? '${tabState.editingWeight ?? pet.weight}kg'
              : '${pet.weight}kg',
          type: 'weight',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildEditableAttributeCard(
          context,
          ref,
          tabId,
          '外見',
          isEditMode
              ? (tabState.appearanceController?.text ??
                    pet.additionalInfo?['appearance'] ??
                    '未設定')
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
      icon: PetInfoUiHelper.getAttributeIcon(type),
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

  Widget _buildMicrochipCard(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    final tabState = ref.watch(petBasicInfoTabProvider(tabId));
    final microchipId = isEditMode
        ? (tabState.microchipController?.text ??
              pet.additionalInfo?['microchipId'] ??
              '')
        : pet.additionalInfo?['microchipId'] ?? '';

    return GenericInfoCard.withIcon(
      icon: Icons.memory,
      iconColor: AppColors.pointBlue,
      iconBackgroundColor: AppColors.pointBlue.withValues(alpha: 0.1),
      title: 'マイクロチップ',
      subtitle: microchipId.isEmpty ? '未登録' : microchipId,
      badge: microchipId.isEmpty ? '未登録' : '登録済み',
      badgeColor: microchipId.isEmpty
          ? AppColors.pointGray
          : AppColors.pointGreen,
      trailing: isEditMode
          ? IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: () => PetInfoDialogHelper.showEditMicrochipDialog(
                context,
                ref,
                tabId,
              ),
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
      subtitle: '${birthDate.year}年${birthDate.month}月${birthDate.day}日',
      badge: '$age歳',
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

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    return ActionButtonGroup.toggle(
      isEditMode: isEditMode,
      onEdit: onToggleEdit,
      onSave: () => PetInfoValidationHelper.saveChanges(
        context,
        ref,
        tabId,
        pet,
        onToggleEdit,
      ),
      onCancel: () =>
          PetInfoValidationHelper.cancelEdit(ref, tabId, pet, onToggleEdit),
      editLabel: '編集',
      saveLabel: '保存',
      cancelLabel: 'キャンセル',
    );
  }

  void _editAttribute(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    String type,
  ) {
    switch (type) {
      case 'name':
        PetInfoDialogHelper.showEditNameDialog(context, ref, tabId);
        break;
      case 'gender':
        PetInfoDialogHelper.showEditGenderDialog(context, ref, tabId);
        break;
      case 'weight':
        PetInfoDialogHelper.showEditWeightDialog(context, ref, tabId);
        break;
      case 'appearance':
        PetInfoDialogHelper.showEditAppearanceDialog(context, ref, tabId);
        break;
    }
  }
}
