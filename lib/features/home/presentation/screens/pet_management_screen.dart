import 'dart:io';

import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// 펫 관리 화면
class PetManagementScreen extends ConsumerStatefulWidget {
  const PetManagementScreen({super.key});

  @override
  ConsumerState<PetManagementScreen> createState() =>
      _PetManagementScreenState();
}

class _PetManagementScreenState extends ConsumerState<PetManagementScreen> {
  // 0: 관리중인 반려동물, 1: 숨김 반려동물
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petProfilesProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientAppBar(
        title: '',
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.pureWhite,
                  AppColors.pointOffWhite.withValues(alpha: 0.9),
                  AppColors.pureWhite,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Row(
              children: [
                // 관리중인 반려동물 탭
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 0
                                ? AppColors.pointBrown
                                : AppColors.pointOffWhite,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '관리중인 반려동물',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedTabIndex == 0
                              ? AppColors.pointDark
                              : AppColors.pointGray,
                        ),
                      ),
                    ),
                  ),
                ),
                // 숨김 반려동물 탭
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 1
                                ? AppColors.pointBrown
                                : AppColors.pointOffWhite,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '숨김 반려동물',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedTabIndex == 1
                              ? AppColors.pointDark
                              : AppColors.pointGray,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 버튼 섹션
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.pureWhite,
                  AppColors.pointOffWhite.withValues(alpha: 0.7),
                  AppColors.pureWhite,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.pointOffWhite.withValues(alpha: 0.9),
                    AppColors.pointOffWhite,
                    AppColors.pointOffWhite.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: petsAsync.when(
                data: (pets) {
                  // 탭에 따라 펫 필터링
                  final filteredPets = _selectedTabIndex == 0
                      ? pets
                            .where((p) => p.petStatus != PetStatus.hidden)
                            .toList()
                      : pets
                            .where((p) => p.petStatus == PetStatus.hidden)
                            .toList();

                  if (filteredPets.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.builder(
                    itemCount: filteredPets.length,
                    itemBuilder: (context, index) {
                      return _buildPetCard(context, filteredPets[index]);
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
        backgroundColor: AppColors.pointBrown,
        foregroundColor: AppColors.pureWhite,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 펫 카드 위젯
  Widget _buildPetCard(BuildContext context, PetProfileEntity pet) {
    // 숨김 탭 여부 확인
    final isHiddenTab = _selectedTabIndex == 1;

    return Dismissible(
      key: Key('pet_${pet.id}'),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(true, isHiddenTab), // 삭제 배경
      secondaryBackground: _buildSwipeBackground(false, isHiddenTab), // 숨김/복원 배경
      resizeDuration: const Duration(milliseconds: 200),
      confirmDismiss: (direction) async {
        return _showSwipeActionDialog(context, pet, direction);
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _deletePet(context, pet);
        } else {
          // 숨김 탭이면 복원, 아니면 숨김
          if (isHiddenTab) {
            _restorePet(context, pet);
          } else {
            _hidePet(context, pet);
          }
        }
      },
      child: GestureDetector(
        onTap: () => _navigateToEditScreen(context, pet),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.pureWhite,
                AppColors.pointOffWhite.withValues(alpha: 0.3),
                AppColors.pureWhite,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.pointGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '의료병원 • 없음',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.pointGray,
                      ),
                    ),
                  ],
                ),
              ),

              // 공유 버튼
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
      ),
    );
  }

  /// 스와이프 배경 위젯
  Widget _buildSwipeBackground(bool isDelete, bool isHiddenTab) {
    // 숨김 탭에서는 오른쪽 스와이프가 "복원"
    final isRestore = !isDelete && isHiddenTab;
    final icon = isDelete
        ? Icons.delete
        : (isRestore ? Icons.visibility : Icons.visibility_off);
    final label = isDelete ? '삭제' : (isRestore ? '복원' : '숨김');
    final color = isDelete
        ? Colors.red
        : (isRestore ? Colors.green : Colors.orange);

    return Container(
      alignment: isDelete ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isDelete ? Alignment.centerLeft : Alignment.centerRight,
          end: isDelete ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 스와이프 액션 다이얼로그 표시
  Future<bool> _showSwipeActionDialog(
    BuildContext context,
    PetProfileEntity pet,
    DismissDirection direction,
  ) async {
    final isDelete = direction == DismissDirection.startToEnd;
    final isHiddenTab = _selectedTabIndex == 1;
    final isRestore = !isDelete && isHiddenTab;

    final action = isDelete ? '삭제' : (isRestore ? '복원' : '숨김');
    final message = isDelete
        ? '${pet.name}을(를) 영구적으로 삭제하시겠습니까?'
        : (isRestore
            ? '${pet.name}을(를) 다시 관리중으로 복원하시겠습니까?'
            : '${pet.name}을(를) 숨김 처리하시겠습니까?');
    final actionColor =
        isDelete ? Colors.red : (isRestore ? Colors.green : Colors.orange);

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('펫 $action'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: actionColor,
                ),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// 펫 삭제 처리
  void _deletePet(BuildContext context, PetProfileEntity pet) {
    final petName = pet.name;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 리포지토리를 통해 삭제
    final notifier = ref.read(petProfilesProvider.notifier);
    notifier
        .deletePet(pet.id)
        .then((_) {
          // mounted 체크 후 성공 메시지 표시
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('$petName이(가) 삭제되었습니다'),
                backgroundColor: Colors.red,
              ),
            );
          }
        })
        .catchError((error) {
          // mounted 체크 후 에러 메시지 표시
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('삭제 중 오류가 발생했습니다: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }

  /// 펫 숨김 처리
  void _hidePet(BuildContext context, PetProfileEntity pet) {
    // 펫 상태를 숨김으로 업데이트
    final hiddenPet = pet.copyWith(petStatus: PetStatus.hidden);
    final petName = pet.name;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 즉시 탭을 숨김 탭으로 전환
    setState(() {
      _selectedTabIndex = 1;
    });

    // 리포지토리를 통해 업데이트
    final notifier = ref.read(petProfilesProvider.notifier);
    notifier
        .updatePet(hiddenPet)
        .then((_) {
          // mounted 체크 후 성공 메시지 표시
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('$petName이(가) 숨김 처리되었습니다'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        })
        .catchError((error) {
          // 에러 발생 시 탭을 원래대로 되돌림
          if (mounted) {
            setState(() {
              _selectedTabIndex = 0;
            });

            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('숨김 처리 중 오류가 발생했습니다: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }

  /// 펫 복원 처리 (숨김 해제)
  void _restorePet(BuildContext context, PetProfileEntity pet) {
    // 펫 상태를 활성으로 업데이트
    final activePet = pet.copyWith(petStatus: PetStatus.active);
    final petName = pet.name;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 즉시 탭을 관리중인 반려동물 탭으로 전환
    setState(() {
      _selectedTabIndex = 0;
    });

    // 리포지토리를 통해 업데이트
    final notifier = ref.read(petProfilesProvider.notifier);
    notifier
        .updatePet(activePet)
        .then((_) {
          // mounted 체크 후 성공 메시지 표시
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('$petName이(가) 관리중으로 복원되었습니다'),
                backgroundColor: Colors.green,
              ),
            );
          }
        })
        .catchError((error) {
          // 에러 발생 시 탭을 원래대로 되돌림
          if (mounted) {
            setState(() {
              _selectedTabIndex = 1;
            });

            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('복원 중 오류가 발생했습니다: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
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
                  embeddedImage: const AssetImage(
                    'assets/icons/logo_notinclude_text.png',
                  ),
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                    size: Size(40, 40), // QR 코드 크기의 약 22% (180의 22%)
                    color: AppColors.pointBrown,
                  ),
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

  /// 펫 이미지 빌드 - 강화된 로컬 저장 지원
  Widget _buildPetImage(PetProfileEntity pet) {
    if (pet.imagePath == null || pet.imagePath!.isEmpty) {
      return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
    }

    LoggerService.debug('🖼️ PetManagementScreen - imagePath: ${pet.imagePath}');

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath =
        storageService.getAbsolutePath(pet.imagePath!) ?? pet.imagePath!;
    LoggerService.debug('🖼️ PetManagementScreen - absolutePath: $absolutePath');

    final imageType = ImageService.getImageType(absolutePath);
    LoggerService.debug('🖼️ PetManagementScreen - imageType: $imageType');

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        LoggerService.debug('🖼️ PetManagementScreen - File exists: $fileExists');

        if (!fileExists) {
          LoggerService.debug(
            '❌ PetManagementScreen - File does not exist: $absolutePath',
          );
          return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
        }

        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ PetManagementScreen - File image error: $error');
            return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
          },
        );
      case ImageType.network:
        return Image.network(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ PetManagementScreen - Network image error: $error');
            return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
          },
        );
      case ImageType.asset:
        return Image.asset(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ PetManagementScreen - Asset image error: $error');
            return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
          },
        );
    }
  }
}
