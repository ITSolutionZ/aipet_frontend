import 'dart:io';

import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ペットカードセクションウィジェット
/// ペット情報カードと追加ボタンを表示
class PetCardSectionWidget extends ConsumerWidget {
  const PetCardSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Repository를 통해 PetProfileEntity 데이터 사용
    final petsAsync = ref.watch(petProfilesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ペットカード表示エリア
          const Text(
            '旅と概要登録をして様々な情報を確認しよう',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 12),

          // ペットデータに応じて表示を切り替え
          petsAsync.when(
            data: (pets) {
              // 🚫 사망한 펫과 숨김 펫 필터링 (드로워에서 표시하면 안됨)
              final activePets = pets
                  .where(
                    (pet) =>
                        pet.petStatus != PetStatus.deceased &&
                        pet.petStatus != PetStatus.hidden,
                  )
                  .toList();

              if (activePets.isEmpty) {
                // ペットがいない場合は登録促進メッセージ
                return _buildEmptyPetState(context);
              } else {
                // 複数ペット対応のスライド可能なカードビュー
                return _buildPetCardsSlider(context, activePets);
              }
            },
            loading: () => _buildLoadingState(),
            error: (error, _) => _buildErrorState(context),
          ),

          const SizedBox(height: 16),
          // ペット追加ボタン
          _buildAddPetButton(context),
        ],
      ),
    );
  }

  /// 複数ペット対応のスライド可能なカードビュー
  Widget _buildPetCardsSlider(BuildContext context, List pets) {
    if (pets.length == 1) {
      return _buildPetCard(context, pets.first);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 120, // 카드 높이를 줄임
          child: PageView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              return _buildPetCard(context, pets[index]);
            },
          ),
        ),
        const SizedBox(height: 8),
        // ページインジケーター
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pets.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ペットカードを構築（実際のペット画像付き）
  Widget _buildPetCard(BuildContext context, PetProfileEntity pet) {
    // 年齢計算
    final age = _calculateAge(pet.birthDate);

    return Container(
      padding: const EdgeInsets.all(12), // 패딩 줄임
      decoration: BoxDecoration(
        color: const Color(0xFF7B68BE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 최소 크기로 제한
        children: [
          Row(
            children: [
              // 실제 펫 이미지 표시
              Container(
                width: 32, // 이미지 크기 줄임
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  image: _getPetImage(pet),
                ),
                child: _getPetImage(pet) == null
                    ? const Icon(
                        Icons.pets,
                        color: Color(0xFF7B68BE),
                        size: 20, // 아이콘 크기 줄임
                      )
                    : null,
              ),
              const SizedBox(width: 8), // 간격 줄임
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // 폰트 크기 줄임
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _getPetBreedDisplay(pet),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // 간격 줄임
          Flexible(
            // Flexible로 변경하여 오버플로우 방지
            child: Text(
              _buildPetInfo(pet, age),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11, // 폰트 크기 줄임
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6), // 간격 줄임
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              // TextButton 대신 GestureDetector 사용
              onTap: () async {
                final petId = pet.id;

                // petId가 null이거나 비어있는 경우 에러 방지
                if (petId.isEmpty) {
                  return;
                }

                // Shell 라우트 내의 펫 프로필로 이동
                await context.push('/home/pet-profile/$petId');
                // 네비게이션 완료 후 drawer 자동으로 닫힘
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: const Text(
                  'プロフィール確認',
                  style: TextStyle(
                    fontSize: 10, // 폰트 크기 줄임
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ペット画像を取得 - 강화된 로컬 저장 지원
  DecorationImage? _getPetImage(PetProfileEntity pet) {
    try {
      // pet.imagePath가 있는 경우 실제 이미지 사용
      if (pet.imagePath != null && pet.imagePath!.isNotEmpty) {
        LoggerService.debug('🖼️ PetCardSectionWidget - imagePath: ${pet.imagePath}');

        // 상대 경로를 절대 경로로 변환
        final storageService = ImageStorageService();
        final absolutePath =
            storageService.getAbsolutePath(pet.imagePath!) ?? pet.imagePath!;
        LoggerService.debug('🖼️ PetCardSectionWidget - absolutePath: $absolutePath');

        final imageType = ImageService.getImageType(absolutePath);
        LoggerService.debug('🖼️ PetCardSectionWidget - imageType: $imageType');

        switch (imageType) {
          case ImageType.file:
            final file = File(absolutePath);
            final fileExists = file.existsSync();
            LoggerService.debug('🖼️ PetCardSectionWidget - File exists: $fileExists');

            if (!fileExists) {
              LoggerService.debug(
                '❌ PetCardSectionWidget - File does not exist: $absolutePath',
              );
              return _getDefaultPetImageDecoration(pet.type, pet.breed);
            }

            return DecorationImage(image: FileImage(file), fit: BoxFit.cover);
          case ImageType.network:
            return DecorationImage(
              image: NetworkImage(absolutePath),
              fit: BoxFit.cover,
            );
          case ImageType.asset:
            return DecorationImage(
              image: AssetImage(absolutePath),
              fit: BoxFit.cover,
            );
        }
      }

      // 품종이나 타입에 따른 기본 이미지
      if (pet.type.isNotEmpty) {
        return _getDefaultPetImageDecoration(pet.type, pet.breed);
      }
    } catch (e) {
      LoggerService.debug('❌ PetCardSectionWidget - Image load error: $e');
    }
    return null;
  }

  /// 기본 펫 이미지 DecorationImage 가져오기
  DecorationImage? _getDefaultPetImageDecoration(
    String? petType,
    String? breed,
  ) {
    final defaultImagePath = _getDefaultPetImage(petType, breed);
    if (defaultImagePath != null) {
      return DecorationImage(
        image: AssetImage(defaultImagePath),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  /// 기본 펫 이미지 경로 가져오기
  String? _getDefaultPetImage(String? petType, String? breed) {
    if (petType == 'dog') {
      switch (breed) {
        case 'shiba':
          return 'assets/images/dogs/shiba.png';
        case 'poodle':
          return 'assets/images/dogs/poodle.jpg';
        case 'pomeranian':
          return 'assets/images/dogs/pomeranian.png';
        case 'dachshund':
          return 'assets/images/dogs/dachshund.png';
        case 'chiwawa':
          return 'assets/images/dogs/chiwawa.png';
        case 'mixed':
          return 'assets/images/dogs/mixed.png';
        default:
          return 'assets/images/dogs/dogs.png';
      }
    } else if (petType == 'cat') {
      return 'assets/images/cats/cat.png';
    }
    return null;
  }

  /// 펫 품종 표시 텍스트 가져오기
  String _getPetBreedDisplay(PetProfileEntity pet) {
    if (pet.breed != null && pet.breed!.isNotEmpty) {
      return pet.breed!;
    }
    if (pet.type == 'dog') {
      return '犬';
    } else if (pet.type == 'cat') {
      return '猫';
    }
    return 'ミックス';
  }

  /// ペット情報文字列を構築
  String _buildPetInfo(PetProfileEntity pet, String age) {
    final gender = pet.gender == 'male'
        ? '男の子'
        : pet.gender == 'female'
        ? '女の子'
        : '';
    final weight = '${pet.weight}kg';

    final parts = <String>[
      if (gender.isNotEmpty) gender,
      age,
      if (weight.isNotEmpty) weight,
    ];

    return parts.join(' / ');
  }

  /// 年齢計算
  String _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return '';

    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;

    if (years > 0) {
      if (months > 0) {
        return '$years歳$months ヶ月';
      }
      return '$years歳';
    } else if (months > 0) {
      return '$months ヶ月';
    } else {
      final days = difference.inDays;
      return '$days日';
    }
  }

  /// 空のペット状態
  Widget _buildEmptyPetState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7B68BE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.pets, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          Text(
            'まだペットが登録されていません',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// ローディング状態
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7B68BE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  /// エラー状態
  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7B68BE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'ペット情報の読み込みに失敗しました',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  /// ペット追加ボタン
  Widget _buildAddPetButton(BuildContext context) {
    return Semantics(
      label: 'ペット追加ボタン',
      button: true,
      hint: 'タップして新しいペットを登録します',
      child: InkWell(
        onTap: () async {
          // 먼저 네비게이션 실행 - Daily Health 스타일로 변경
          await context.push(RouteConstants.dailyPetRegistrationRoute);
          // 네비게이션 완료 후 drawer 자동으로 닫힘
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'ペット追加',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
