import 'package:aipet_frontend/features/home/presentation/widgets/appbar_banner_image.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 홈 화면 상단 펫 프로필 배너
class PetProfileBanner extends ConsumerWidget {
  final double scrollOffset;

  const PetProfileBanner({super.key, this.scrollOffset = 0.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petProfilesNotifierProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.35, // 배너 높이 더 증가
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Stack(
          children: [
            // 배너 이미지 (배경)
            const Positioned.fill(child: AppbarBannerImage()),
            // 그라데이션 오버레이 (동적 투명도)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent, // 상단은 항상 투명
                      scrollOffset > 0
                          ? Colors.white.withValues(alpha: 0.8) // 스크롤 시 하단 흰색
                          : Colors.transparent, // 스크롤 없을 때 하단도 투명
                    ],
                  ),
                ),
              ),
            ),
            // 콘텐츠 (펫 프로필) - SafeArea 제거하여 화면 최상단부터 시작
            Padding(
              padding: EdgeInsets.only(
                top:
                    MediaQuery.of(context).padding.top +
                    AppSpacing.xl, // 상태바 높이 + 여백
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: 0, // 하단 패딩 삭제
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 펫 프로필 섹션
                  Expanded(
                    child: petsAsync.when(
                      data: (pets) {
                        if (pets.isEmpty) {
                          return _buildEmptyState(context);
                        }
                        return _buildPetProfiles(context, pets);
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      error: (error, _) => _buildErrorState(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetProfiles(BuildContext context, List<PetProfileEntity> pets) {
    // 펫 프로필과 추가 버튼을 완전히 숨김
    return const SizedBox.shrink();
  }

  Widget _buildPetAvatar(BuildContext context, PetProfileEntity pet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: GestureDetector(
        onTap: () {
          context.push('/pet-profile/${pet.id}');
        },
        onLongPress: () {
          _showPetOptionsBottomSheet(context, pet);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(child: _getPetImage(pet)),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              pet.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPetButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: GestureDetector(
        onTap: () {
          context.push('/daily/pet-registration');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 40),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              '追加',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const SizedBox.shrink(); // 빈 위젯으로 완전히 숨김
  }

  Widget _buildErrorState(BuildContext context) {
    return const Center(
      child: Text(
        'データの読み込みに失敗しました',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _getPetImage(PetProfileEntity pet) {
    // 펫 이미지가 있는 경우
    if (pet.imagePath != null && pet.imagePath!.isNotEmpty) {
      return Image.asset(
        pet.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _getDefaultPetIcon(pet);
        },
      );
    }

    // 기본 펫 이미지
    return _getDefaultPetIcon(pet);
  }

  Widget _getDefaultPetIcon(PetProfileEntity pet) {
    IconData iconData;
    if (pet.type == 'dog') {
      iconData = Icons.pets;
    } else if (pet.type == 'cat') {
      iconData = Icons.pets;
    } else {
      iconData = Icons.pets;
    }

    return Container(
      color: AppColors.pointGreen.withValues(alpha: 0.2),
      child: Icon(iconData, color: AppColors.pointGreen, size: 40),
    );
  }

  /// 펫 옵션 바텀 시트 표시
  void _showPetOptionsBottomSheet(BuildContext context, PetProfileEntity pet) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 핸들 바
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 펫 정보 헤더
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.pointGreen,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(child: _getPetImage(pet)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: AppFonts.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              pet.type == 'dog'
                                  ? '犬'
                                  : pet.type == 'cat'
                                  ? '猫'
                                  : 'ペット',
                              style: AppFonts.bodySmall.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 옵션 리스트
                  Column(
                    children: [
                      _buildOptionTile(
                        context,
                        icon: Icons.edit,
                        title: 'プロフィール編集',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/pet-profile/${pet.id}/edit');
                        },
                      ),
                      _buildOptionTile(
                        context,
                        icon: Icons.delete_outline,
                        title: 'ペットを削除',
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteConfirmDialog(context, pet);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 옵션 타일 위젯
  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey[700]),
      title: Text(
        title,
        style: AppFonts.bodyMedium.copyWith(color: textColor ?? Colors.black),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
    );
  }

  /// 삭제 확인 다이얼로그 표시
  void _showDeleteConfirmDialog(BuildContext context, PetProfileEntity pet) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'ペット削除確認',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '「${pet.name}」を削除しますか？',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'この操作は取り消せません。',
                    style: TextStyle(fontSize: 14, color: Colors.red[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'キャンセル',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _deletePet(context, ref, pet);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('削除'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 펫 삭제 실행
  Future<void> _deletePet(
    BuildContext context,
    WidgetRef ref,
    PetProfileEntity pet,
  ) async {
    try {
      // 로딩 인디케이터 표시
      // ignore: unawaited_futures
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 펫 삭제 실행
      await ref.read(petProfilesNotifierProvider.notifier).deletePet(pet.id);

      // 로딩 인디케이터 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // 성공 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pet.name}を削除しました'),
            backgroundColor: AppColors.pointGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 로딩 인디케이터 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // 에러 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('削除に失敗しました: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
