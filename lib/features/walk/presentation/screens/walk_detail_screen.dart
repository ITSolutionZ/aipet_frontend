import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/walk_record_entity.dart';
import '../widgets/walk_detail_map_widget.dart';
import '../widgets/walk_info_bottom_sheet.dart';

class WalkDetailScreen extends ConsumerStatefulWidget {
  final WalkRecordEntity walkRecord;

  const WalkDetailScreen({super.key, required this.walkRecord});

  @override
  ConsumerState<WalkDetailScreen> createState() => _WalkDetailScreenState();
}

class _WalkDetailScreenState extends ConsumerState<WalkDetailScreen> {
  bool _isBottomSheetExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(),

            // 지도 섹션
            Expanded(child: _buildMapSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // 뒤로가기 버튼
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.pointDark,
              size: 20,
            ),
          ),

          // 제목과 날짜
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.walkRecord.title,
                      style: AppFonts.fredoka(
                        fontSize: AppFonts.lg,
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.pointGray,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      widget.walkRecord.dateString,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 반려동물 정보
          _buildPetInfo(),
        ],
      ),
    );
  }

  Widget _buildPetInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.pointBrown.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 반려동물 이미지
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.pointBrown.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.walkRecord.petImage ?? 'assets/images/dogs/shiba.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.pets, color: Colors.grey[600], size: 12),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // 반려동물 이름
          Text(
            widget.walkRecord.petName ?? 'Maxi',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Stack(
        children: [
          // 지도 위젯
          WalkDetailMapWidget(walkRecord: widget.walkRecord),

          // 하단 정보 카드
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Consumer(
              builder: (context, ref, child) {
                return WalkInfoBottomSheet(
                  walkRecord: widget.walkRecord,
                  isExpanded: _isBottomSheetExpanded,
                  onToggleExpanded: () {
                    setState(() {
                      _isBottomSheetExpanded = !_isBottomSheetExpanded;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
