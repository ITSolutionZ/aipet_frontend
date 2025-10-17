import 'package:aipet_frontend/features/walk/data/providers/walk_share_providers.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pet_profile/data/providers/pet_profile_providers.dart';
import 'dialogs/edit_walk_bottom_sheet.dart';
import 'helpers/helpers.dart';

part 'walk_info_bottom_sheet.g.dart';

/// 🎯 Walk Info Bottom Sheet Expansion Controller
@riverpod
class WalkInfoExpansionController extends _$WalkInfoExpansionController {
  @override
  bool build(String sheetId) {
    return false;
  }

  void toggle() {
    state = !state;
  }
}

class WalkInfoBottomSheet extends ConsumerWidget {
  final WalkRecordEntity walkRecord;

  const WalkInfoBottomSheet({super.key, required this.walkRecord});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheetId = walkRecord.id;
    final isExpanded = ref.watch(walkInfoExpansionControllerProvider(sheetId));

    return GestureDetector(
      onVerticalDragEnd: (details) {
        // 위로 스와이프하면 확장
        if (details.primaryVelocity! < -500 && !isExpanded) {
          ref
              .read(walkInfoExpansionControllerProvider(sheetId).notifier)
              .toggle();
        }
        // 아래로 스와이프하면 축소
        else if (details.primaryVelocity! > 500 && isExpanded) {
          ref
              .read(walkInfoExpansionControllerProvider(sheetId).notifier)
              .toggle();
        }
      },
      onTap: () {
        // 탭으로도 토글 가능
        ref
            .read(walkInfoExpansionControllerProvider(sheetId).notifier)
            .toggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        constraints: BoxConstraints(
          maxHeight: isExpanded
              ? MediaQuery.of(context).size.height * 0.75
              : 220,
          minHeight: 220,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.large),
            topRight: Radius.circular(AppRadius.large),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            _buildDragHandle(),

            // 헤더
            _buildHeader(context, ref, sheetId, isExpanded),

            // 기본 정보 (항상 표시)
            _buildBasicInfo(),

            // 확장 상태일 때 추가 정보 표시
            if (isExpanded)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: _buildExpandedContent(context, ref),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return WalkInfoUiHelper.buildDragHandle();
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    String sheetId,
    bool isExpanded,
  ) {
    // 로컬 저장소에서 펫 정보 가져오기
    final petsAsync = ref.watch(petProfilesProvider);
    final pet = petsAsync.maybeWhen(
      data: (pets) {
        if (pets.isEmpty) return null;
        return pets.firstWhere(
          (p) => p.id == walkRecord.petId,
          orElse: () => pets.first,
        );
      },
      orElse: () => null,
    );

    if (pet == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // 펫 프로필 이미지
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.pointBrown.withValues(alpha: 0.3),
                width: 2,
              ),
              image: pet.imagePath != null
                  ? DecorationImage(
                      image: AssetImage(pet.imagePath!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: pet.imagePath == null
                ? ClipOval(
                    child: Image.asset(
                      'assets/icons/aipet_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.pets,
                          color: AppColors.pointBrown,
                          size: 24,
                        );
                      },
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),

          // 펫 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  walkRecord.petName,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${pet.type} • ${pet.breed}',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
          ),

          // 확장/축소 아이콘
          Icon(
            isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
            color: AppColors.pointGray,
            size: 24,
          ),
        ],
      ),
    );
  }

  /// 기본 정보 (항상 표시)
  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow('開始時間', walkRecord.timeString),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('距離', walkRecord.formattedDistance),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('時間', walkRecord.formattedDuration),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  /// 확장된 콘텐츠 (드래그하면 표시)
  Widget _buildExpandedContent(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: AppColors.pointGray.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.md),

          // 추가 정보
          _buildInfoRow('日付', walkRecord.dateString),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('状態', _getStatusText(walkRecord.status)),

          // 펫 활동 정보
          if (walkRecord.notes != null &&
              walkRecord.notes!.contains('activities:')) ...[
            const SizedBox(height: AppSpacing.md),
            _buildMemoSection(walkRecord.notes!),
          ],

          const SizedBox(height: AppSpacing.lg),

          // 액션 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showShareDialog(context, ref, walkRecord);
                  },
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('共有'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.pointBrown,
                    side: const BorderSide(color: AppColors.pointBrown),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showEditWalkDialog(context, ref, walkRecord);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('編集'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBrown,
                    foregroundColor: AppColors.pointOffWhite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return WalkInfoUiHelper.buildInfoRow(label, value);
  }

  /// 메모 섹션 빌드 (activities JSON 처리)
  Widget _buildMemoSection(String notes) {
    // activities JSON이 포함된 경우 파싱하여 별도 표시
    if (notes.startsWith('activities:')) {
      return _buildActivitiesSection(notes);
    }

    // 일반 메모
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'メモ',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.pointOffWhite,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Text(
            notes,
            style: AppFonts.bodySmall.copyWith(color: AppColors.pointDark),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 펫 활동 섹션 빌드
  Widget _buildActivitiesSection(String notes) {
    try {
      // "activities:[...]" 형식에서 JSON 부분 추출
      final jsonStr = notes.substring('activities:'.length);
      // activities 개수만 표시 (전체 JSON은 숨김)
      final activityCount = _countActivities(jsonStr);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ペット活動',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointOffWhite,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              children: [
                const Icon(Icons.pets, size: 16, color: AppColors.pointBrown),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$activityCount回の活動記録',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      // 파싱 실패 시 간단히 표시
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'メモ',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointOffWhite,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Text(
              'ペット活動記録',
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointDark),
            ),
          ),
        ],
      );
    }
  }

  /// activities 개수 카운트
  int _countActivities(String jsonStr) {
    return WalkInfoUiHelper.countActivities(jsonStr);
  }

  String _getStatusText(WalkStatus status) {
    return WalkInfoUiHelper.getStatusText(status);
  }

  /// 산책 기록 공유 다이얼로그 표시
  void _showShareDialog(
    BuildContext context,
    WidgetRef ref,
    WalkRecordEntity walkRecord,
  ) {
    final shareText = ref.read(shareTextProvider(walkRecord));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('共有'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('テキストをコピー'),
              onTap: () {
                context.pop();
                _copyToClipboard(context, ref, shareText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('画像を保存'),
              onTap: () {
                context.pop();
                _saveAsImage(context, ref, walkRecord);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('システム共有'),
              onTap: () {
                context.pop();
                _systemShare(context, ref, shareText);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  /// 클립보드에 복사
  Future<void> _copyToClipboard(
    BuildContext context,
    WidgetRef ref,
    String text,
  ) async {
    await WalkInfoShareHelper.copyToClipboard(
      context: context,
      ref: ref,
      text: text,
    );
  }

  /// 이미지로 저장
  Future<void> _saveAsImage(
    BuildContext context,
    WidgetRef ref,
    WalkRecordEntity walkRecord,
  ) async {
    await WalkInfoShareHelper.saveAsImage(
      context: context,
      ref: ref,
      walkRecord: walkRecord,
    );
  }

  /// 시스템 공유
  Future<void> _systemShare(
    BuildContext context,
    WidgetRef ref,
    String text,
  ) async {
    await WalkInfoShareHelper.systemShare(
      context: context,
      ref: ref,
      text: text,
    );
  }

  /// 산책 기록 수정 바텀 시트 표시
  void _showEditWalkDialog(
    BuildContext context,
    WidgetRef ref,
    WalkRecordEntity walkRecord,
  ) {
    EditWalkBottomSheet.show(context, walkRecord, WalkController(ref));
  }
}
