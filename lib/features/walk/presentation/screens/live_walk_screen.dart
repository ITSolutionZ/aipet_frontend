import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/walk/live_walk_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 실시간 산책 화면
class LiveWalkScreen extends ConsumerStatefulWidget {
  final String? petId;
  final String? petName;
  final String? petImage;

  const LiveWalkScreen({super.key, this.petId, this.petName, this.petImage});

  @override
  ConsumerState<LiveWalkScreen> createState() => _LiveWalkScreenState();
}

class _LiveWalkScreenState extends ConsumerState<LiveWalkScreen> {
  String? _selectedPetId;

  @override
  void initState() {
    super.initState();
    _selectedPetId = widget.petId ?? 'pet1';
  }

  @override
  Widget build(BuildContext context) {
    final liveWalkState = ref.watch(liveWalkProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 전체 화면 지도 (상태바와 바텀 네비게이터 제외)
          Positioned.fill(
            top: 0,
            bottom: 0,
            child: LiveWalkWidget(
              petId: widget.petId ?? 'pet1',
              petName: widget.petName ?? 'マックス',
            ),
          ),

          // 상단 네비게이션 (뒤로가기 버튼)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => _handleBackButton(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),

          // 상단 오른쪽 메뉴 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _showWalkOptions,
                icon: const Icon(
                  Icons.menu,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),

          // 하단 펫 정보 카드
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 90,
            left: 0,
            right: 0,
            child: Center(child: _buildPetInfoCard()),
          ),

          // 하단 버튼들
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 20,
            right: 20,
            child: _buildBottomButtons(liveWalkState),
          ),
        ],
      ),
    );
  }

  /// 뒤로가기 버튼 처리
  void _handleBackButton(BuildContext context) {
    final liveWalkState = ref.read(liveWalkProvider);

    if (liveWalkState.isRunning || liveWalkState.isPaused) {
      // 산책 중이면 확인 다이얼로그
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('散歩を終了しますか？'),
          content: const Text('進行中の散歩を終了して戻りますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(liveWalkProvider.notifier).stopWalk();
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointPink,
                foregroundColor: Colors.white,
              ),
              child: const Text('終了して戻る'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  /// 펫 리스트 위젯
  Widget _buildPetInfoCard() {
    // Mock 펫 데이터 가져오기
    final pets = PetMockData.getMockPets();

    if (pets.isEmpty) {
      // 펫이 없는 경우: + 원형 아이콘만 표시
      return GestureDetector(
        onTap: () {
          // TODO: 펫 추가 화면으로 이동
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ペットを追加してください'),
              backgroundColor: AppColors.pointBrown,
            ),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.pointBrown.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      );
    }

    // 펫 리스트가 있는 경우: 가로 스크롤 펫 카드
    return Center(
      child: SizedBox(
        height: 145,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: pets.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final pet = pets[index];
            final isSelected = pet.id == _selectedPetId;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPetId = pet.id;
                  });
                },
                child: Container(
                  width: 110,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.pointPink.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: isSelected
                        ? Border.all(color: AppColors.pointPink, width: 3)
                        : Border.all(color: Colors.grey.shade300, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 펫 아바타
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : AppColors.pointGray.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: pet.imagePath?.isNotEmpty == true
                              ? Image.asset(
                                  pet.imagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.pets,
                                      color: isSelected
                                          ? AppColors.pointPink
                                          : AppColors.pointGray,
                                      size: 25,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.pets,
                                  color: isSelected
                                      ? AppColors.pointPink
                                      : AppColors.pointGray,
                                  size: 25,
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // 펫 이름
                      Text(
                        pet.name,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),

                      // 몸무게
                      Text(
                        '${pet.weight}kg',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '30分 권장',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 하단 버튼들
  Widget _buildBottomButtons(LiveWalkState liveWalkState) {
    return Row(
      children: [
        // 펑게 기록 버튼 (왼쪽, 흰색)
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              onPressed: _showWalkRecordsList,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                '펑게 기록',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 산책 시작/중지 버튼 (오른쪽, 갈색)
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: liveWalkState.isRunning
                  ? AppColors.pointPink
                  : AppColors.pointBrown,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color:
                      (liveWalkState.isRunning
                              ? AppColors.pointPink
                              : AppColors.pointBrown)
                          .withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () => _handleWalkButton(liveWalkState),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                liveWalkState.isRunning
                    ? '散歩終了'
                    : liveWalkState.isPaused
                    ? '散歩再開'
                    : '散歩 시작',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 산책 버튼 처리
  void _handleWalkButton(LiveWalkState state) {
    if (state.isRunning) {
      // 산책 종료
      _showStopWalkDialog();
    } else if (state.isPaused) {
      // 산책 재개
      ref.read(liveWalkProvider.notifier).resumeWalk();
    } else {
      // 산책 시작
      ref.read(liveWalkProvider.notifier).startWalk();
    }
  }

  /// 산책 종료 확인 다이얼로그
  void _showStopWalkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('散歩を終了しますか？'),
        content: const Text('散歩を終了して記録を保存しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(liveWalkProvider.notifier).stopWalk();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('散歩が保存されました'),
                  backgroundColor: AppColors.pointGreen,
                ),
              );
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
              foregroundColor: Colors.white,
            ),
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }

  /// 산책 기록 목록 표시
  void _showWalkRecordsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.pointOffWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 핸들바
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.pointGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 제목
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '散歩記録',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // TODO: 산책 기록 리스트 표시
            Expanded(
              child: Center(
                child: Text(
                  '散歩記録がありません',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 옵션 메뉴 표시
  void _showWalkOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pause),
              title: const Text('一時停止'),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(liveWalkProvider.notifier).pauseWalk();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('設定'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: 설정 화면으로 이동
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: AppColors.pointPink),
              title: const Text(
                '散歩をキャンセル',
                style: TextStyle(color: AppColors.pointPink),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showCancelWalkDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 산책 취소 확인 다이얼로그
  void _showCancelWalkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('散歩をキャンセルしますか？'),
        content: const Text('進行中の散歩データが削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(liveWalkProvider.notifier).resetWalk();
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointPink,
              foregroundColor: Colors.white,
            ),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}
