import 'package:aipet_frontend/features/daily/data/providers/hospital_registration_provider.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 내원 병원 관리 화면
class HospitalManagementScreen extends ConsumerStatefulWidget {
  const HospitalManagementScreen({super.key});

  @override
  ConsumerState<HospitalManagementScreen> createState() =>
      _HospitalManagementScreenState();
}

class _HospitalManagementScreenState
    extends ConsumerState<HospitalManagementScreen> {
  String? selectedPetId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB89B8A), // 갈색 그라데이션 시작
              Color(0xFFA08A7A), // 갈색 그라데이션 중간
              Color(0xFF967E6D), // 갈색 그라데이션 끝
            ],
          ),
        ),
        child: Column(
          children: [
            // 펫 프로필 헤더 섹션
            _buildPetProfileHeader(),
            // 메인 콘텐츠
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundGray,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),

                      // 등록된 병원 목록
                      _buildRegisteredHospitalsList(),
                      const SizedBox(height: AppSpacing.md),

                      // 액션 버튼들
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.pointBrown,
      elevation: 0,
      automaticallyImplyLeading: true,
      title: const Text(
        '병원 관리',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.pointBrown,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildPetProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final petsAsync = ref.watch(petProfilesNotifierProvider);

          return petsAsync.when(
            data: (pets) {
              if (pets.isEmpty) {
                return const SizedBox.shrink();
              }

              final currentPet = pets.firstWhere(
                (pet) => pet.id == selectedPetId,
                orElse: () => pets.first,
              );

              return Row(
                children: [
                  // 선택된 펫 프로필 이미지
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        PetImageUtils.getImagePath(
                          currentPet.imagePath,
                          currentPet.type,
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.pets,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  // 펫 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentPet.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _getPetTypeInJapanese(
                            currentPet.type,
                            currentPet.breed,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  String _getPetTypeInJapanese(String? type, String? breed) {
    String petType;
    switch ((type ?? '').toLowerCase()) {
      case 'dog':
        petType = '犬';
        break;
      case 'cat':
        petType = '猫';
        break;
      default:
        petType = type ?? '';
    }

    String petBreed;
    switch ((breed ?? '').toLowerCase()) {
      case 'golden retriever':
        petBreed = 'ゴールデンレトリバー';
        break;
      case 'labrador':
        petBreed = 'ラブラドール';
        break;
      case 'shiba inu':
        petBreed = '柴犬';
        break;
      case 'pomeranian':
        petBreed = 'ポメラニアン';
        break;
      case 'american shorthair':
        petBreed = 'アメリカンショートヘア';
        break;
      case 'scottish fold':
        petBreed = 'スコティッシュフォールド';
        break;
      case 'persian':
        petBreed = 'ペルシャ';
        break;
      case 'maine coon':
        petBreed = 'メインクーン';
        break;
      default:
        petBreed = breed ?? '';
    }

    return '$petType • $petBreed';
  }

  Widget _buildRegisteredHospitalsList() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.list_alt,
                    color: AppColors.pointGreen,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '登録済み病院',
                    style: AppFonts.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showAddHospitalDialog(),
                icon: const Icon(Icons.add_circle, color: AppColors.pointGreen),
                tooltip: '病院追加',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Consumer(
            builder: (context, ref, child) {
              final hospitalsAsync = ref.watch(
                registeredHospitalsNotifierProvider,
              );

              return hospitalsAsync.when(
                data: (hospitals) {
                  if (hospitals.isEmpty) {
                    return _buildEmptyHospitalsState();
                  }
                  return _buildHospitalsList(hospitals);
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => _buildErrorState(error.toString()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHospitalsState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.local_hospital_outlined,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '登録された病院がありません',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () => context.push('/home/hospital-list'),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('病院を探す'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.pointGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalsList(List<RegisteredHospital> hospitals) {
    return Column(
      children: hospitals.map((hospital) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.pointGreen.withValues(alpha: 0.1),
              child: const Icon(
                Icons.local_hospital,
                color: AppColors.pointGreen,
                size: 20,
              ),
            ),
            title: Text(
              hospital.name,
              style: AppFonts.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital.address, style: AppFonts.bodySmall),
                Text(
                  hospital.phoneNumber,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointBlue,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 20),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'call',
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 16),
                      SizedBox(width: AppSpacing.xs),
                      Text('電話'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle, size: 16, color: Colors.red),
                      SizedBox(width: AppSpacing.xs),
                      Text('削除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleHospitalAction(value, hospital),
            ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'エラーが発生しました',
            style: AppFonts.bodyMedium.copyWith(color: Colors.red[700]),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            error,
            style: AppFonts.bodySmall.copyWith(color: Colors.red[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // 동물병원 찾기 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/home/hospital-list');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
            icon: const Icon(Icons.search),
            label: Text(
              '動物病院 を探す',
              style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // 긴급 연락처 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _showEmergencyContactsDialog();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.pointRed,
              side: const BorderSide(color: AppColors.pointRed),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
            icon: const Icon(Icons.emergency),
            label: Text(
              '緊急連絡先',
              style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _handleHospitalAction(String action, RegisteredHospital hospital) async {
    switch (action) {
      case 'call':
        _makePhoneCall(hospital.phoneNumber);
        break;
      case 'remove':
        _showRemoveHospitalDialog(hospital);
        break;
    }
  }

  void _makePhoneCall(String phoneNumber) {
    // TODO: 전화 걸기 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('電話をかけています: $phoneNumber'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddHospitalDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('病院登録'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '病院名',
                hintText: '例: さくら動物病院',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: '住所',
                hintText: '例: 東京都渋谷区...',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: '電話番号',
                hintText: '例: 03-1234-5678',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  addressController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                final hospital = RegisteredHospital(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  address: addressController.text,
                  phoneNumber: phoneController.text,
                  registeredAt: DateTime.now(),
                );

                await ref
                    .read(registeredHospitalsNotifierProvider.notifier)
                    .addHospital(hospital);

                if (mounted) {
                  final currentContext = context;
                  Navigator.of(currentContext).pop();
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(
                      content: Text('病院が登録されました'),
                      backgroundColor: AppColors.pointGreen,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointGreen,
            ),
            child: const Text('登録'),
          ),
        ],
      ),
    );
  }

  void _showRemoveHospitalDialog(RegisteredHospital hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('病院削除'),
        content: Text('「${hospital.name}」を登録から削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(registeredHospitalsNotifierProvider.notifier)
                  .removeHospital(hospital.id);

              if (mounted) {
                final currentContext = context;
                Navigator.of(currentContext).pop();
                ScaffoldMessenger.of(currentContext).showSnackBar(
                  const SnackBar(
                    content: Text('病院が削除されました'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('緊急連絡先'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.local_hospital, color: Colors.red),
              title: Text('動物救急センター'),
              subtitle: Text('24時間対応'),
              trailing: Text(
                '119',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(Icons.pets, color: Colors.green),
              title: Text('ペット救急ホットライン'),
              subtitle: Text('ペットの緊急相談'),
              trailing: Text('0120-XX-XXXX', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
