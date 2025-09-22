import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/shared.dart';
import '../../../../../shared/ui/components/components.dart';
import '../../../../pet_registor/domain/entities/pet_profile_entity.dart';

class PetBasicInfoTab extends ConsumerStatefulWidget {
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
  ConsumerState<PetBasicInfoTab> createState() => _PetBasicInfoTabState();
}

class _PetBasicInfoTabState extends ConsumerState<PetBasicInfoTab> {
  late TextEditingController _nameController;
  late TextEditingController _appearanceController;
  late TextEditingController _weightController;
  late TextEditingController _microchipController;

  String? _editingGender;
  double? _editingWeight;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.pet.name);
    _appearanceController = TextEditingController(
      text: widget.pet.additionalInfo?['appearance'] ?? '',
    );
    _weightController = TextEditingController(
      text: widget.pet.weight.toString(),
    );
    _microchipController = TextEditingController(
      text: widget.pet.additionalInfo?['microchipId'] ?? '',
    );

    _editingGender = widget.pet.gender;
    _editingWeight = widget.pet.weight;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _appearanceController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildProfileImageSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildBasicInfoCards(),
          const SizedBox(height: AppSpacing.lg),
          _buildMicrochipCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildDateCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildCaretakerSection(),
          const SizedBox(height: AppSpacing.xl),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return GenericInfoCard.withIcon(
      icon: Icons.pets,
      iconColor: AppColors.pointBrown,
      iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
      title: widget.pet.name,
      subtitle: '${widget.pet.type} • ${widget.pet.breed}',
      badge: widget.pet.gender,
      badgeColor: widget.pet.gender == 'Male'
          ? AppColors.pointBlue
          : AppColors.pointPink,
      trailing: widget.isEditMode
          ? IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _changeProfileImage,
            )
          : null,
    );
  }

  Widget _buildBasicInfoCards() {
    return Column(
      children: [
        _buildEditableAttributeCard(
          '名前',
          widget.isEditMode ? _nameController.text : widget.pet.name,
          type: 'name',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildEditableAttributeCard(
          '性別',
          widget.isEditMode
              ? (_editingGender ?? widget.pet.gender)
              : widget.pet.gender,
          type: 'gender',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildEditableAttributeCard(
          '体重',
          widget.isEditMode
              ? '${_editingWeight ?? widget.pet.weight ?? 0}kg'
              : '${widget.pet.weight ?? 0}kg',
          type: 'weight',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildEditableAttributeCard(
          '外見',
          widget.isEditMode
              ? _appearanceController.text
              : (widget.pet.additionalInfo?['appearance'] ?? '未設定'),
          type: 'appearance',
        ),
      ],
    );
  }

  Widget _buildEditableAttributeCard(
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
      trailing: widget.isEditMode
          ? IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: () => _editAttribute(type),
            )
          : null,
    );
  }

  Widget _buildMicrochipCard() {
    final microchipId = widget.isEditMode
        ? _microchipController.text
        : widget.pet.additionalInfo?['microchipId'] ?? '';

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
      trailing: widget.isEditMode
          ? IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: () => _editMicrochip(),
            )
          : null,
    );
  }

  Widget _buildDateCard() {
    final age = widget.pet.age;
    final birthDate = widget.pet.birthDate;

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

  Widget _buildActionButtons() {
    return ActionButtonGroup.toggle(
      isEditMode: widget.isEditMode,
      onEdit: widget.onToggleEdit,
      onSave: _saveChanges,
      onCancel: _cancelEdit,
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

  void _changeProfileImage() {
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
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editAttribute(String type) {
    switch (type) {
      case 'name':
        _showEditNameDialog();
        break;
      case 'gender':
        _showEditGenderDialog();
        break;
      case 'weight':
        _showEditWeightDialog();
        break;
      case 'appearance':
        _showEditAppearanceDialog();
        break;
    }
  }

  void _editMicrochip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('マイクロチップ編集'),
        content: TextField(
          controller: _microchipController,
          decoration: const InputDecoration(
            labelText: 'マイクロチップID',
            hintText: 'マイクロチップIDを入力してください',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    // バリデーション
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('名前を入力してください')));
      return;
    }

    if (_editingWeight != null && _editingWeight! <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('体重は0より大きい値を入力してください')));
      return;
    }

    // 変更を保存
    final updatedPet = widget.pet.copyWith(
      name: _nameController.text.trim(),
      gender: _editingGender ?? widget.pet.gender,
      weight: _editingWeight ?? widget.pet.weight,
      additionalInfo: {
        ...widget.pet.additionalInfo ?? {},
        'appearance': _appearanceController.text.trim(),
        'microchipId': _microchipController.text.trim(),
      },
    );

    // TODO: API 호출로 실제 저장
    // await ref.read(petRepositoryProvider).updatePet(updatedPet);
    // updatedPet 변수는 추후 API 호출 시 사용됩니다

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ペット情報を保存しました')));

    widget.onToggleEdit();
  }

  void _cancelEdit() {
    // Reset controllers to original values
    _initializeControllers();
    widget.onToggleEdit();
  }

  void _pickImageFromCamera() {
    // TODO: Implement camera functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('カメラ機能は実装予定です')));
  }

  void _pickImageFromGallery() {
    // TODO: Implement gallery picker functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ギャラリー選択機能は実装予定です')));
  }

  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('名前編集'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'ペットの名前',
            hintText: '名前を入力してください',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showEditGenderDialog() {
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
              groupValue: _editingGender,
              onChanged: (value) {
                setState(() {
                  _editingGender = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('メス'),
              value: 'Female',
              groupValue: _editingGender,
              onChanged: (value) {
                setState(() {
                  _editingGender = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showEditWeightDialog() {
    final weightController = TextEditingController(
      text: _editingWeight?.toString() ?? '',
    );

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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                setState(() {
                  _editingWeight = weight;
                  _weightController.text = weight.toString();
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('有効な体重を入力してください')));
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showEditAppearanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('外見編集'),
        content: TextField(
          controller: _appearanceController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '外見の特徴',
            hintText: 'ペットの外見について説明してください',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
