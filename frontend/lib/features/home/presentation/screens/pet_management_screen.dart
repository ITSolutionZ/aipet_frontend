import 'dart:io';

import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// ペット管理画面
class PetManagementScreen extends ConsumerStatefulWidget {
  const PetManagementScreen({super.key});

  @override
  ConsumerState<PetManagementScreen> createState() =>
      _PetManagementScreenState();
}

class _PetManagementScreenState extends ConsumerState<PetManagementScreen> {
  // 0: 管理中のペット, 1: 非表示のペット
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petProfilesProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientAppBar(
        title: '',
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
                // 管理中のペット タブ
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
                        '管理中のペット',
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
                // 非表示のペット タブ
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
                        '非表示のペット',
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
                      '登録したペット',
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
                      '共有されたペット',
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
                            .where(
                              (p) =>
                                  p.petStatus != PetStatus.hidden &&
                                  p.petStatus != PetStatus.deceased,
                            )
                            .toList()
                      : pets
                            .where(
                              (p) =>
                                  p.petStatus == PetStatus.hidden ||
                                  p.petStatus == PetStatus.deceased,
                            )
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
                    'ペット情報の読み込みに失敗しました',
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

  /// ペットカードウィジェット
  Widget _buildPetCard(BuildContext context, PetProfileEntity pet) {
    // 非表示タブかどうか確認
    final isHiddenTab = _selectedTabIndex == 1;
    // 사망 펫 여부 확인
    final isDeceased = pet.petStatus == PetStatus.deceased;

    return Dismissible(
      key: Key('pet_${pet.id}'),
      // 사망 펫은 삭제만 가능 (왼쪽 스와이프만)
      direction: isDeceased
          ? DismissDirection.startToEnd
          : DismissDirection.horizontal,
      background: _buildSwipeBackground(true, isHiddenTab, isDeceased), // 削除背景
      secondaryBackground: isDeceased
          ? null
          : _buildSwipeBackground(
              false,
              isHiddenTab,
              isDeceased,
            ), // 非表示/復元背景
      resizeDuration: const Duration(milliseconds: 200),
      confirmDismiss: (direction) async {
        // 사망 펫은 복원 불가
        if (isDeceased && direction == DismissDirection.endToStart) {
          return false;
        }
        return _showSwipeActionDialog(context, pet, direction);
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _deletePet(context, pet);
        } else {
          // 非表示タブなら復元、そうでなければ非表示
          if (isHiddenTab && !isDeceased) {
            _restorePet(context, pet);
          } else if (!isDeceased) {
            _hidePet(context, pet);
          }
        }
      },
      child: GestureDetector(
        onTap: () => _navigateToEditScreen(context, pet),
        child: Opacity(
          opacity: isDeceased ? 0.6 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDeceased
                    ? [
                        AppColors.pointGray.withValues(alpha: 0.3),
                        AppColors.pointGray.withValues(alpha: 0.2),
                        AppColors.pointGray.withValues(alpha: 0.3),
                      ]
                    : [
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
              // ペット画像
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

              // ペット情報
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
                        if (isDeceased) ...[
                          const Text(
                            '🕊️',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pointGray.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '追悼中',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.pointGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.pointGray,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '年齢 • ${pet.typeName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.pointGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '体重 • ${pet.weight}kg',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.pointGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '登録リクエスト者 • なし',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.pointGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '医療病院 • なし',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.pointGray,
                      ),
                    ),
                  ],
                ),
              ),

              // 공유 버튼
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 12,
              //     vertical: 6,
              //   ),
              //   decoration: BoxDecoration(
              //     color: AppColors.pointBrown.withValues(alpha: 0.1),
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   child: GestureDetector(
              //     onTap: () => _showQRCode(context, pet),
              //     child: const Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Icon(
              //           Icons.folder_shared_outlined,
              //           size: 14,
              //           color: AppColors.pointBrown,
              //         ),
              //         SizedBox(width: 4),
              //         Text(
              //           '共同管理者を招待',
              //           style: TextStyle(
              //             fontSize: 11,
              //             color: AppColors.pointBrown,
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  /// 스와이프 배경 위젯
  Widget _buildSwipeBackground(
    bool isDelete,
    bool isHiddenTab,
    bool isDeceased,
  ) {
    // 非表示タブでは右スワイプが「復元」
    final isRestore = !isDelete && isHiddenTab;
    final icon = isDelete
        ? Icons.delete
        : (isRestore ? Icons.visibility : Icons.visibility_off);
    final label = isDelete ? '削除' : (isRestore ? '復元' : '非表示');
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
          colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
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

    final action = isDelete ? '削除' : (isRestore ? '復元' : '非表示');
    final message = isDelete
        ? '${pet.name}を完全に削除しますか？'
        : (isRestore ? '${pet.name}を管理中に戻しますか？' : '${pet.name}を非表示にしますか？');
    final actionColor = isDelete
        ? Colors.red
        : (isRestore ? Colors.green : Colors.orange);

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('ペット$action'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: actionColor),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// ペット削除処理
  void _deletePet(BuildContext context, PetProfileEntity pet) {
    final petName = pet.name;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // リポジトリを通じて削除
    final notifier = ref.read(petProfilesProvider.notifier);
    notifier
        .deletePet(pet.id)
        .then((_) {
          // mounted 체크 후 성공 메시지 표시
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('$petNameが削除されました'),
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
                content: Text('削除中にエラーが発生しました: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }

  /// ペット非表示処理
  void _hidePet(BuildContext context, PetProfileEntity pet) {
    // ペット状態を非表示に更新
    final hiddenPet = pet.copyWith(petStatus: PetStatus.hidden);
    final petName = pet.name;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 即座にタブを非表示タブに切り替え
    setState(() {
      _selectedTabIndex = 1;
    });

    // リポジトリを通じて更新
    final notifier = ref.read(petProfilesProvider.notifier);
    notifier
        .updatePet(hiddenPet)
        .then((_) {
          // mounted 체크 후 성공 메시지 표시
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('$petNameが非表示になりました'),
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
                content: Text('非表示処理中にエラーが発生しました: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }

  /// ペット復元処理（非表示解除）
  void _restorePet(BuildContext context, PetProfileEntity pet) {
    // ペット状態をアクティブに更新
    final activePet = pet.copyWith(petStatus: PetStatus.active);
    final petName = pet.name;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 即座にタブを管理中のペットタブに切り替え
    setState(() {
      _selectedTabIndex = 0;
    });

    // リポジトリを通じて更新
    final notifier = ref.read(petProfilesProvider.notifier);
    notifier
        .updatePet(activePet)
        .then((_) {
          // mounted 체크 후 성공 메시지 표시
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('$petNameが管理中に復元されました'),
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
                content: Text('復元中にエラーが発生しました: ${error.toString()}'),
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
            '登録されたペットがいません',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.pointGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '新しいペットを登録してください',
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
                '${pet.name}のQRコード',
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
                    size: Size(40, 40), // QRコードサイズの約22% (180の22%)
                    color: AppColors.pointBrown,
                  ),
                  errorStateBuilder: (cxt, err) {
                    return const Center(
                      child: Text(
                        'QRコード生成中にエラーが発生しました',
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
                'QRコードをスキャンしてペット情報を共有してください',
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
                        '閉じる',
                        style: TextStyle(color: AppColors.pointGray),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // QRコード共有機能実装
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pointBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '共有',
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

  /// 編集画面に移動（ペットプロファイル画面を編集モードで開く）
  void _navigateToEditScreen(BuildContext context, PetProfileEntity pet) {
    // 사망 펫은 수정 불가
    if (pet.petStatus == PetStatus.deceased) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Text('🕊️'),
              SizedBox(width: 8),
              Text('追悼ペット'),
            ],
          ),
          content: const Text(
            '追悼中のペットは編集できません。\n記録の閲覧のみ可能です。',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 読み取り専用モードで開く
                context.go('/home/pet-profile/${pet.id}?isEditMode=false');
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.pointBrown,
              ),
              child: const Text('記録を見る'),
            ),
          ],
        ),
      );
      return;
    }

    context.go('/home/pet-profile/${pet.id}?isEditMode=true');
  }

  /// ペット画像ビルド - 強化されたローカル保存サポート
  Widget _buildPetImage(PetProfileEntity pet) {
    if (pet.imagePath == null || pet.imagePath!.isEmpty) {
      return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
    }

    LoggerService.debug(
      '🖼️ PetManagementScreen - imagePath: ${pet.imagePath}',
    );

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath =
        storageService.getAbsolutePath(pet.imagePath!) ?? pet.imagePath!;
    LoggerService.debug(
      '🖼️ PetManagementScreen - absolutePath: $absolutePath',
    );

    final imageType = ImageService.getImageType(absolutePath);
    LoggerService.debug('🖼️ PetManagementScreen - imageType: $imageType');

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        LoggerService.debug(
          '🖼️ PetManagementScreen - File exists: $fileExists',
        );

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
            LoggerService.debug(
              '🖼️ PetManagementScreen - File image error: $error',
            );
            return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
          },
        );
      case ImageType.network:
        return Image.network(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug(
              '🖼️ PetManagementScreen - Network image error: $error',
            );
            return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
          },
        );
      case ImageType.asset:
        return Image.asset(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug(
              '🖼️ PetManagementScreen - Asset image error: $error',
            );
            return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
          },
        );
    }
  }
}
