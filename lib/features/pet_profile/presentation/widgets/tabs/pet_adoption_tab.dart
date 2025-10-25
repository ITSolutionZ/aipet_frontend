import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_unified_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 공동 양육자 데이터 모델
class CoOwner {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String relationship; // 관계 (家族、友人、パートナーなど)
  final DateTime addedDate;

  CoOwner({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.relationship,
    required this.addedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'relationship': relationship,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  factory CoOwner.fromMap(Map<String, dynamic> map) {
    return CoOwner(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      relationship: map['relationship'] as String,
      addedDate: DateTime.parse(map['addedDate'] as String),
    );
  }
}

/// 공동 양육자 관리 탭 위젯
class PetAdoptionTab extends ConsumerStatefulWidget {
  final PetProfileEntity pet;
  final bool isEditMode;

  const PetAdoptionTab({required this.pet, this.isEditMode = false, super.key});

  @override
  ConsumerState<PetAdoptionTab> createState() => _PetAdoptionTabState();
}

class _PetAdoptionTabState extends ConsumerState<PetAdoptionTab> {
  late List<CoOwner> _coOwners;

  @override
  void initState() {
    super.initState();
    _loadCoOwners();
  }

  @override
  void didUpdateWidget(PetAdoptionTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pet.id != widget.pet.id ||
        (oldWidget.isEditMode && !widget.isEditMode)) {
      _loadCoOwners();
    }
  }

  void _loadCoOwners() {
    final additionalInfo = widget.pet.additionalInfo ?? {};
    final coOwnersData = additionalInfo['coOwners'] as List<dynamic>?;

    if (coOwnersData != null && coOwnersData.isNotEmpty) {
      _coOwners = coOwnersData
          .map((e) => CoOwner.fromMap(e as Map<String, dynamic>))
          .toList();
    } else {
      _coOwners = [];
    }

    LoggerService.debug('✅ 共同養育者 ${_coOwners.length}名 로드');
  }

  void _saveCoOwners() {
    final coOwnersData = _coOwners.map((e) => e.toMap()).toList();
    ref
        .read(petProfileUnifiedControllerProvider.notifier)
        .updateFormData('coOwners', coOwnersData);
    LoggerService.debug('💾 共同養育者 저장: ${coOwnersData.length}명');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildCoOwnersSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.pointBrown.withValues(alpha: 0.1),
            AppColors.pointGreen.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.pointBrown.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Icon(
              Icons.group,
              color: AppColors.pointBrown,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '共同養育者',
                  style: AppFonts.titleLarge.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${widget.pet.name}を一緒にお世話する人を管理',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoOwnersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '養育者リスト',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            if (widget.isEditMode)
              TextButton.icon(
                onPressed: _showAddCoOwnerDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('追加'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.pointBrown,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_coOwners.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.pointOffWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.group_add,
                  size: 48,
                  color: AppColors.pointGray.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '共同養育者がいません',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '編集モードで「追加」ボタンから養育者を追加できます',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._coOwners.map((coOwner) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildCoOwnerCard(coOwner),
              )),
      ],
    );
  }

  Widget _buildCoOwnerCard(CoOwner coOwner) {
    final Color relationColor = _getRelationshipColor(coOwner.relationship);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: relationColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(
              _getRelationshipIcon(coOwner.relationship),
              color: relationColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      coOwner.name,
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: relationColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        coOwner.relationship,
                        style: AppFonts.bodySmall.copyWith(
                          color: relationColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  coOwner.email,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
                if (coOwner.phone != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    coOwner.phone!,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.isEditMode)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.pointRed, size: 20),
              onPressed: () => _deleteCoOwner(coOwner),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Color _getRelationshipColor(String relationship) {
    switch (relationship) {
      case '家族':
        return AppColors.pointGreen;
      case 'パートナー':
        return AppColors.pointPink;
      case '友人':
        return AppColors.pointBlue;
      default:
        return AppColors.pointGray;
    }
  }

  IconData _getRelationshipIcon(String relationship) {
    switch (relationship) {
      case '家族':
        return Icons.family_restroom;
      case 'パートナー':
        return Icons.favorite;
      case '友人':
        return Icons.people;
      default:
        return Icons.person;
    }
  }

  void _showAddCoOwnerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRelationship = '家族';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('養育者を追加'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '名前 *',
                    hintText: '例: 山田太郎',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス *',
                    hintText: '例: example@email.com',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: '電話番号',
                    hintText: '例: 090-1234-5678',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: selectedRelationship,
                  decoration: const InputDecoration(
                    labelText: '関係 *',
                    prefixIcon: Icon(Icons.group),
                  ),
                  items: ['家族', 'パートナー', '友人', 'その他']
                      .map((relation) => DropdownMenuItem(
                            value: relation,
                            child: Text(relation),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedRelationship = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty) {
                  SnackBarService.showWarning(
                      context, '名前とメールアドレスを入力してください');
                  return;
                }

                final newCoOwner = CoOwner(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text.isEmpty
                      ? null
                      : phoneController.text,
                  relationship: selectedRelationship,
                  addedDate: DateTime.now(),
                );

                setState(() {
                  _coOwners.add(newCoOwner);
                });

                _saveCoOwners();

                Navigator.pop(dialogContext);
                SnackBarService.showSuccess(
                    context, '${newCoOwner.name}を追加しました');
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCoOwner(CoOwner coOwner) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('${coOwner.name}を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _coOwners.removeWhere((c) => c.id == coOwner.id);
              });
              _saveCoOwners();
              Navigator.pop(dialogContext);
              SnackBarService.showSuccess(context, '${coOwner.name}を削除しました');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.pointRed),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
