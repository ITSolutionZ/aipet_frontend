import 'dart:io';

import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// 펫 관리 화면
class PetManagementScreen extends ConsumerWidget {
  const PetManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petProfilesProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.pointBrown,
        elevation: 0,
        title: const Text('반려동물관리'),
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.pointDark),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/home'),
            icon: const Icon(Icons.home_outlined, color: AppColors.pointDark),
          ),
        ],
      ),
      body: Column(
        children: [
          // 탭 섹션
          Container(
            color: AppColors.pureWhite,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.pointBrown,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      '관리중인 반려동물',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pointDark,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Text(
                      '숨김 반려동물',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.pointGray,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 버튼 섹션
          Container(
            color: AppColors.pureWhite,
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
                      '내가 등록한 반려동물',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.pointBrown,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: AppColors.pointGray),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      '공유 받은 반려동물',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.pointGray,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 펫 리스트 섹션
          Expanded(
            child: Container(
              color: AppColors.pointOffWhite,
              padding: const EdgeInsets.all(16),
              child: petsAsync.when(
                data: (pets) {
                  if (pets.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.builder(
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      return _buildPetCard(context, pets[index]);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.pointBrown),
                ),
                error: (error, stack) => const Center(
                  child: Text(
                    '펫 정보를 불러오는데 실패했습니다',
                    style: TextStyle(color: AppColors.pointGray),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/daily-pet-registration'),
        backgroundColor: AppColors.pointDark,
        child: const Icon(Icons.add, color: AppColors.pureWhite),
      ),
    );
  }

  /// 펫 카드 위젯
  Widget _buildPetCard(BuildContext context, PetProfileEntity pet) {
    return GestureDetector(
      onTap: () => _navigateToEditScreen(context, pet),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.pointGray.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 펫 이미지
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.pointOffWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: pet.imagePath != null && pet.imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildPetImage(pet),
                    )
                  : const Icon(
                      Icons.pets,
                      color: AppColors.pointGray,
                      size: 30,
                    ),
            ),
            const SizedBox(width: 12),

            // 펫 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.pointDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.edit,
                        size: 16,
                        color: AppColors.pointGray,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '나이 • ${pet.typeName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.pointGray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '몸무게 • ${pet.weight}kg',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.pointGray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '등록요청자 • 없음',
                    style: TextStyle(fontSize: 12, color: AppColors.pointGray),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '의료병원 • 없음',
                    style: TextStyle(fontSize: 12, color: AppColors.pointGray),
                  ),
                ],
              ),
            ),

            // 공유 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.pointBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: GestureDetector(
                onTap: () => _showQRCode(context, pet),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_shared_outlined,
                      size: 14,
                      color: AppColors.pointBrown,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '공동관리자 초대하기',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.pointBrown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.pointGray.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets_outlined,
              size: 40,
              color: AppColors.pointGray,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '등록된 반려동물이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.pointGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '새로운 반려동물을 등록해보세요',
            style: TextStyle(fontSize: 14, color: AppColors.pointGray),
          ),
        ],
      ),
    );
  }

  /// QR 코드 표시 다이얼로그
  void _showQRCode(BuildContext context, PetProfileEntity pet) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${pet.name}의 QR 코드',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: 20),

              // 실제 QR 코드
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.pointGray.withValues(alpha: 0.3),
                  ),
                ),
                child: QrImageView(
                  data:
                      'pet_profile:${pet.id}|${pet.name}|${pet.type}|${pet.weight}kg|https://aipet.app/pet/${pet.id}',
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: AppColors.pureWhite,
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.pointDark,
                  ),
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.pointDark,
                  ),
                  gapless: false,
                  embeddedImage: null,
                  embeddedImageStyle: null,
                  errorStateBuilder: (cxt, err) {
                    return const Center(
                      child: Text(
                        'QR 코드 생성 중 오류가 발생했습니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.pointGray,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'QR 코드를 스캔하여 반려동물 정보를 공유하세요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.pointGray),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.pointGray),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '닫기',
                        style: TextStyle(color: AppColors.pointGray),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // QR 코드 공유 기능 구현
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pointBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '공유',
                        style: TextStyle(color: AppColors.pureWhite),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 편집 화면으로 이동 (펫 등록 화면을 편집 모드로 사용)
  void _navigateToEditScreen(BuildContext context, PetProfileEntity pet) {
    context.go('/daily-pet-registration?petId=${pet.id}');
  }

  /// 펫 이미지 빌드 (파일 시스템, 에셋, 네트워크 이미지 모두 지원)
  Widget _buildPetImage(PetProfileEntity pet) {
    if (pet.imagePath == null || pet.imagePath!.isEmpty) {
      return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
    }

    // 이미지 경로 타입에 따라 다른 위젯 반환
    if (pet.imagePath!.startsWith('http') ||
        pet.imagePath!.startsWith('https')) {
      // 네트워크 이미지
      return Image.network(
        pet.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
        },
      );
    } else if (pet.imagePath!.startsWith('assets/')) {
      // 에셋 이미지
      return Image.asset(
        pet.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
        },
      );
    } else {
      // 파일 시스템 이미지
      return Image.file(
        File(pet.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
        },
      );
    }
  }
}
