import 'dart:io';

import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/app/widgets/widgets.dart';
import 'package:aipet_frontend/features/settings/presentation/controllers/user_profile_controller.dart';
import 'package:aipet_frontend/features/settings/presentation/widgets/settings_tile_widget.dart';
import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: SoftGradientDrawerAppBar(
        title: '設定',
        selectedPetInfo: Container(
          margin: const EdgeInsets.only(right: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _buildUserProfileImage(profileState),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ユーザー情報カード
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xl),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: _buildUserProfileImage(profileState, size: 50),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profileState.profile?.userName ?? 'ユーザー'} さん',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      profileState.profile?.email ?? 'test@test.com',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // アカウント
          const SectionHeaderWidget(title: 'アカウント'),
          SettingsTileWidget(
            icon: Icons.person,
            title: 'プロフィール編集',
            backgroundColor: const Color(0xFFA88B5A),
            tileColor: AppColors.pureWhite,
            onTap: () => context.push(AppRouter.profileEditRoute),
          ),
          // const SizedBox(height: AppSpacing.xs),
          // SettingsTileWidget(
          //   icon: Icons.pets,
          //   title: 'ペット情報編集',
          //   backgroundColor: const Color(0xFFA88B5A),
          //   tileColor: AppColors.pureWhite,
          //   onTap: () => _handlePetEdit(context, ref),
          // ),
          // const SizedBox(height: AppSpacing.xs),
          // SettingsTileWidget(
          //   icon: Icons.lock,
          //   title: 'セキュリティ設定',
          //   backgroundColor: const Color(0xFFA88B5A),
          //   tileColor: AppColors.pureWhite,
          //   onTap: () => context.push('/settings/biometric-security'),
          // ),
          const SizedBox(height: AppSpacing.xs),
          SettingsTileWidget(
            icon: Icons.delete,
            title: 'アカウント削除',
            backgroundColor: const Color(0xFFB85A5A),
            tileColor: AppColors.pureWhite,
            onTap: () => context.push(AppRouter.accountDeleteRoute),
          ),

          const SizedBox(height: AppSpacing.lg),

          // システム
          const SectionHeaderWidget(title: 'システム'),
          SettingsTileWidget(
            icon: Icons.notifications,
            title: 'アラーム設定',
            backgroundColor: const Color(0xFF7A9CC6),
            tileColor: AppColors.pureWhite,
            onTap: () => context.push('/settings/local-alarm-settings'),
          ),

          // const SizedBox(height: AppSpacing.xs),
          // SettingsTileWidget(
          //   icon: Icons.star,
          //   title: 'プレミアム管理',
          //   backgroundColor: const Color(0xFF7A9CC6),
          //   tileColor: AppColors.pureWhite,
          //   onTap: () {},
          // ),
          // const SizedBox(height: AppSpacing.xs),
          // SettingsTileWidget(
          //   icon: Icons.lightbulb,
          //   title: 'テーマ設定',
          //   backgroundColor: const Color(0xFF7A9CC6),
          //   tileColor: AppColors.pureWhite,
          //   onTap: () {},
          // ),
          const SizedBox(height: AppSpacing.lg),

          // その他
          const SectionHeaderWidget(title: 'その他'),
          // SettingsTileWidget(
          //   icon: Icons.dashboard,
          //   title: 'データベースダッシュボード (開発用)',
          //   backgroundColor: const Color(0xFF6B73FF),
          //   tileColor: AppColors.pureWhite,
          //   onTap: () => context.push('/settings/database-dashboard'),
          // ),
          // const SizedBox(height: AppSpacing.xs),
          SettingsTileWidget(
            icon: Icons.help,
            title: 'お問い合わせ',
            backgroundColor: const Color(0xFFB8A5A5),
            tileColor: AppColors.pureWhite,
            onTap: () async {
              final url = Uri.parse(
                'https://docs.google.com/forms/d/e/1FAIpQLScCCXFO2Uie5vNCye0UUpBnQtOCvXSiXpT97tzZisJjxmrS8w/viewform?usp=dialog',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          SettingsTileWidget(
            icon: Icons.info,
            title: 'アプリ情報',
            backgroundColor: const Color(0xFFB8A5A5),
            tileColor: AppColors.pureWhite,
            onTap: () => context.push('/settings/app-info'),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// 사용자 프로필 이미지 위젯
  Widget _buildUserProfileImage(
    UserProfileState profileState, {
    double size = 35,
  }) {
    // 프로필 이미지가 있으면 표시
    if (profileState.profile?.profileImage != null &&
        profileState.profile!.profileImage!.isNotEmpty) {
      return _buildProfileImageWidget(
        profileState.profile!.profileImage!,
        size: size,
      );
    }

    // 기본 이미지 표시
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.pointOffWhite,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.pointGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/logos/aipet_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: size * 0.6,
              color: AppColors.pointGray.withValues(alpha: 0.7),
            );
          },
        ),
      ),
    );
  }

  /// 프로필 이미지 위젯 빌드 (이미지 타입 감지) - 강화된 로컬 저장 지원
  Widget _buildProfileImageWidget(String imagePath, {double size = 35}) {
    LoggerService.debug('🖼️ SettingsScreen - imagePath: $imagePath');

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath = storageService.getAbsolutePath(imagePath) ?? imagePath;
    LoggerService.debug('🖼️ SettingsScreen - absolutePath: $absolutePath');

    final imageType = ImageService.getImageType(absolutePath);
    LoggerService.debug('🖼️ SettingsScreen - imageType: $imageType');

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        LoggerService.debug('🖼️ SettingsScreen - File exists: $fileExists');

        if (!fileExists) {
          LoggerService.debug(
            '❌ SettingsScreen - File does not exist: $absolutePath',
          );
          return _buildDefaultUserImage(size);
        }

        return Image.file(
          file,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug(
              '🖼️ SettingsScreen - File image error: $error',
            );
            return _buildDefaultUserImage(size);
          },
        );
      case ImageType.network:
        return Image.network(
          absolutePath,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug(
              '🖼️ SettingsScreen - Network image error: $error',
            );
            return _buildDefaultUserImage(size);
          },
        );
      case ImageType.asset:
        return Image.asset(
          absolutePath,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug(
              '🖼️ SettingsScreen - Asset image error: $error',
            );
            return _buildDefaultUserImage(size);
          },
        );
    }
  }

  /// 기본 사용자 이미지 위젯
  Widget _buildDefaultUserImage(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.pointOffWhite,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.pointGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/logos/aipet_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: size * 0.6,
              color: AppColors.pointGray.withValues(alpha: 0.7),
            );
          },
        ),
      ),
    );
  }

  // /// 펫 정보 편집 처리 (드로워에서 펫 카드 선택 후 상세보기 → 편집으로 대체)
  // Future<void> _handlePetEdit(BuildContext context, WidgetRef ref) async {
  //   try {
  //     LoggerService.debug('🔍 ペット情報編集 버튼 클릭됨');
  //
  //     // 펫 목록 가져오기 (.future로 데이터 로드 완료까지 대기)
  //     final pets = await ref.read(petProfilesProvider.future);
  //
  //     LoggerService.debug('📊 로드된 펫 수: ${pets.length}');
  //
  //     if (!context.mounted) return;
  //
  //     if (pets.isEmpty) {
  //       LoggerService.debug('📝 등록된 펫이 없음 - 새 등록 화면으로 이동');
  //       context.push('/daily-pet-registration');
  //     } else if (pets.length == 1) {
  //       // 펫이 1마리만 있으면 자동으로 해당 펫 편집
  //       final petId = pets.first.id;
  //       LoggerService.debug(
  //         '✏️ 펫 편집 모드로 이동 - petId: $petId, name: ${pets.first.name}',
  //       );
  //       context.push('/daily-pet-registration?petId=$petId');
  //     } else {
  //       // 여러 펫이 있으면 선택 다이얼로그 표시
  //       LoggerService.debug('📋 여러 펫 존재 - 선택 다이얼로그 표시');
  //       final selectedPet = await _showPetSelectionDialog(context, pets);
  //       if (selectedPet != null && context.mounted) {
  //         LoggerService.debug(
  //           '✏️ 선택된 펫 편집 - petId: ${selectedPet.id}, name: ${selectedPet.name}',
  //         );
  //         context.push('/daily-pet-registration?petId=${selectedPet.id}');
  //       }
  //     }
  //   } catch (e, stackTrace) {
  //     LoggerService.debug('❌ 펫 편집 처리 중 에러: $e');
  //     LoggerService.debug('Stack trace: $stackTrace');
  //
  //     if (context.mounted) {
  //       // 에러 메시지 표시
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('ペット情報の読み込みに失敗しました: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }
  //
  // /// 펫 선택 다이얼로그
  // Future<PetProfileEntity?> _showPetSelectionDialog(
  //   BuildContext context,
  //   List<PetProfileEntity> pets,
  // ) async {
  //   return showDialog<PetProfileEntity>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('編集するペットを選択'),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         child: ListView.builder(
  //           shrinkWrap: true,
  //           itemCount: pets.length,
  //           itemBuilder: (context, index) {
  //             final pet = pets[index];
  //             return ListTile(
  //               leading: CircleAvatar(
  //                 backgroundImage: pet.imagePath != null
  //                     ? FileImage(File(pet.imagePath!))
  //                     : null,
  //                 child: pet.imagePath == null
  //                     ? Icon(pet.type == 'dog' ? Icons.pets : Icons.settings)
  //                     : null,
  //               ),
  //               title: Text(pet.name),
  //               subtitle: Text('${pet.type} • ${pet.breed ?? ''}'),
  //               onTap: () => Navigator.of(context).pop(pet),
  //             );
  //           },
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('キャンセル'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
