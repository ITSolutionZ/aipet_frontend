import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/pet_profile/data/providers/pet_profile_providers.dart';


/// 병원 관리 화면 펫 프로필 헤더
class HospitalPetProfileHeader extends ConsumerWidget {
  final String? selectedPetId;

  const HospitalPetProfileHeader({super.key, required this.selectedPetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final petsAsync = ref.watch(petProfilesProvider);

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
                      child: _buildPetImage(currentPet),
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

  Widget _buildPetImage(PetProfileEntity pet) {
    if (pet.imagePath == null || pet.imagePath!.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.pets, size: 40, color: Colors.grey),
      );
    }

    LoggerService.debug('🖼️ HospitalPetProfileHeader - imagePath: ${pet.imagePath}');

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath = storageService.getAbsolutePath(pet.imagePath!) ?? pet.imagePath!;
    LoggerService.debug('🖼️ HospitalPetProfileHeader - absolutePath: $absolutePath');

    final imageType = ImageService.getImageType(absolutePath);
    LoggerService.debug('🖼️ HospitalPetProfileHeader - imageType: $imageType');

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        LoggerService.debug('🖼️ HospitalPetProfileHeader - File exists: $fileExists');

        if (!fileExists) {
          LoggerService.debug('❌ HospitalPetProfileHeader - File does not exist: $absolutePath');
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.pets, size: 40, color: Colors.grey),
          );
        }

        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ HospitalPetProfileHeader - File image error: $error');
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.pets, size: 40, color: Colors.grey),
            );
          },
        );
      case ImageType.network:
        return Image.network(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ HospitalPetProfileHeader - Network image error: $error');
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.pets, size: 40, color: Colors.grey),
            );
          },
        );
      case ImageType.asset:
        return Image.asset(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ HospitalPetProfileHeader - Asset image error: $error');
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.pets, size: 40, color: Colors.grey),
            );
          },
        );
    }
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
}
