import 'package:aipet_frontend/features/walk/data/providers/walk_providers.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/walk_detail_map_widget.dart';
import 'package:aipet_frontend/features/walk/presentation/widgets/walk_info_bottom_sheet.dart';
import 'package:aipet_frontend/shared/shared.dart'
    hide WalkDetailMapWidget, WalkInfoBottomSheet;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WalkDetailScreen extends ConsumerWidget {
  final WalkRecordEntity walkRecord;

  const WalkDetailScreen({super.key, required this.walkRecord});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider에서 최신 데이터 가져오기 (수정 반영을 위해)
    final walkRecords = ref.watch(walkRecordsNotifierProvider);
    final currentWalkRecord = walkRecords.firstWhere(
      (r) => r.id == walkRecord.id,
      orElse: () => walkRecord, // 찾지 못하면 원본 사용
    );

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context, currentWalkRecord),

            // 지도 섹션
            Expanded(child: _buildMapSection(currentWalkRecord)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WalkRecordEntity currentWalkRecord,
  ) {
    // 이 산책에 참여한 펫만 가져오기
    final pets = PetMockData.getMockPets();
    final walkPet = pets.firstWhere(
      (p) => p.id == currentWalkRecord.petId,
      orElse: () => pets.first,
    );

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
        child: Image.asset(
          pet?.imagePath ?? 'assets/images/dogs/shiba.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.pointGray.withValues(alpha: 0.3),
              child: Icon(
                Icons.pets,
                color: AppColors.pointGray,
                size: size * 0.5,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapSection(WalkRecordEntity currentWalkRecord) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Stack(
        children: [
          // 지도 위젯
          WalkDetailMapWidget(walkRecord: currentWalkRecord),

          // 하단 정보 카드
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Consumer(
              builder: (context, ref, child) {
                // Provider에서 최신 데이터 가져오기
                final walkRecords = ref.watch(walkRecordsNotifierProvider);
                final latestWalkRecord = walkRecords.firstWhere(
                  (r) => r.id == currentWalkRecord.id,
                  orElse: () => currentWalkRecord,
                );
                return WalkInfoBottomSheet(walkRecord: latestWalkRecord);
              },
            ),
          ),
        ],
      ),
    );
  }
}
