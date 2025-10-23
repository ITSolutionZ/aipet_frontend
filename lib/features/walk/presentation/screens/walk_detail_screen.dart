import 'dart:io';

import 'package:aipet_frontend/features/walk/data/providers/walk_providers.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/walk_detail_map_widget.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/walk_info_bottom_sheet.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../pet_profile/data/providers/pet_profile_providers.dart';

class WalkDetailScreen extends ConsumerWidget {
  final WalkRecordEntity walkRecord;

  const WalkDetailScreen({super.key, required this.walkRecord});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider에서 최신 데이터 가져오기 (수정 반영을 위해)
    final walkRecords = ref.watch(walkRecordsProvider);
    final currentWalkRecord = walkRecords.firstWhere(
      (r) => r.id == walkRecord.id,
      orElse: () => walkRecord, // 찾지 못하면 원본 사용
    );

    // SQLite에서 펫 데이터 가져오기
    final petsAsync = ref.watch(petProfilesProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: SafeArea(
        child: petsAsync.when(
          data: (pets) => Column(
            children: [
              // 헤더
              _buildHeader(context, currentWalkRecord, pets),

              // 지도 섹션
              Expanded(child: _buildMapSection(currentWalkRecord)),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('エラー: $error')),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WalkRecordEntity currentWalkRecord,
    List<PetProfileEntity> pets,
  ) {
    // 이 산책에 참여한 펫만 가져오기
    final walkPet = pets.isNotEmpty
        ? pets.firstWhere(
            (p) => p.id == currentWalkRecord.petId,
            orElse: () => pets.first,
          )
        : null;

    if (walkPet == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // 뒤로가기 버튼
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.pointDark,
              size: AppSpacing.md,
            ),
          ),

          const Spacer(),

          // 이 산책에 참여한 펫 이미지만 표시
          _buildPetImages([walkPet]),
        ],
      ),
    );
  }

  Widget _buildPetImages(List pets) {
    if (pets.isEmpty) {
      return _buildSinglePetImage(null);
    }

    if (pets.length == 1) {
      return _buildSinglePetImage(pets.first);
    }

    // 2마리: 겹쳐서 표시
    return SizedBox(
      width: 60, // 2개 겹칠 공간
      height: 40,
      child: Stack(
        children: [
          // 두 번째 펫 (뒤쪽)
          Positioned(
            right: 0,
            child: _buildSinglePetImage(
              pets[1],
              borderColor: Colors.white,
              size: 40,
            ),
          ),
          // 첫 번째 펫 (앞쪽)
          Positioned(
            left: 0,
            child: _buildSinglePetImage(
              pets[0],
              borderColor: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePetImage(
    dynamic pet, {
    Color borderColor = Colors.transparent,
    double size = 40,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor == Colors.transparent
              ? AppColors.pointBrown.withValues(alpha: 0.3)
              : borderColor,
          width: borderColor == Colors.transparent ? 1 : 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: _buildPetImage(pet?.imagePath, size),
      ),
    );
  }

  /// 펫 이미지 위젯 빌드 - 강화된 로컬 저장 지원
  Widget _buildPetImage(String? imagePath, double size) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        color: AppColors.pointGray.withValues(alpha: 0.3),
        child: Icon(Icons.pets, color: AppColors.pointGray, size: size * 0.5),
      );
    }

    LoggerService.debug('🖼️ WalkDetailScreen - imagePath: $imagePath');

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath = storageService.getAbsolutePath(imagePath) ?? imagePath;
    LoggerService.debug('🖼️ WalkDetailScreen - absolutePath: $absolutePath');

    final imageType = ImageService.getImageType(absolutePath);
    LoggerService.debug('🖼️ WalkDetailScreen - imageType: $imageType');

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        LoggerService.debug('🖼️ WalkDetailScreen - File exists: $fileExists');

        if (!fileExists) {
          LoggerService.debug('❌ WalkDetailScreen - File does not exist: $absolutePath');
          return Container(
            color: AppColors.pointGray.withValues(alpha: 0.3),
            child: Icon(
              Icons.pets,
              color: AppColors.pointGray,
              size: size * 0.5,
            ),
          );
        }

        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ WalkDetailScreen - File image error: $error');
            return Container(
              color: AppColors.pointGray.withValues(alpha: 0.3),
              child: Icon(
                Icons.pets,
                color: AppColors.pointGray,
                size: size * 0.5,
              ),
            );
          },
        );
      case ImageType.network:
        return Image.network(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ WalkDetailScreen - Network image error: $error');
            return Container(
              color: AppColors.pointGray.withValues(alpha: 0.3),
              child: Icon(
                Icons.pets,
                color: AppColors.pointGray,
                size: size * 0.5,
              ),
            );
          },
        );
      case ImageType.asset:
        return Image.asset(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ WalkDetailScreen - Asset image error: $error');
            return Container(
              color: AppColors.pointGray.withValues(alpha: 0.3),
              child: Icon(
                Icons.pets,
                color: AppColors.pointGray,
                size: size * 0.5,
              ),
            );
          },
        );
    }
  }

  Widget _buildMapSection(WalkRecordEntity currentWalkRecord) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Stack(
        children: [
          // 지도 위젯
          WalkDetailMapWidget(walkRecord: currentWalkRecord),

          // 드래그 가능한 바텀시트
          Consumer(
            builder: (context, ref, child) {
              // Provider에서 최신 데이터 가져오기
              final walkRecords = ref.watch(walkRecordsProvider);
              final latestWalkRecord = walkRecords.firstWhere(
                (r) => r.id == currentWalkRecord.id,
                orElse: () => currentWalkRecord,
              );
              return DraggableScrollableSheet(
                initialChildSize: 0.3, // 30% 높이로 시작
                minChildSize: 0.15, // 최소 15% (최소화)
                maxChildSize: 0.8, // 최대 80% (확장)
                snap: true,
                snapSizes: const [0.15, 0.3, 0.8], // 스냅 포인트
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        // 핸들 바
                        SliverAppBar(
                          automaticallyImplyLeading: false,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          flexibleSpace: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(top: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          toolbarHeight: 28,
                        ),

                        // 산책 정보 내용
                        SliverList(
                          delegate: SliverChildListDelegate([
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: WalkInfoBottomSheet(
                                walkRecord: latestWalkRecord,
                                showHeader: false, // 내부 핸들 바 숨김
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
