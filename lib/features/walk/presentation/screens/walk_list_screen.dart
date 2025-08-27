import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../data/providers/walk_share_providers.dart';
import '../../data/walk_providers.dart';
import '../../domain/entities/walk_record_entity.dart';
import '../controllers/walk_controller.dart';
import '../widgets/map_widget.dart';
import '../widgets/walk_record_card_widget.dart';
import 'walk_detail_screen.dart';

class WalkListScreen extends ConsumerStatefulWidget {
  const WalkListScreen({super.key});

  @override
  ConsumerState<WalkListScreen> createState() => _WalkListScreenState();
}

class _WalkListScreenState extends ConsumerState<WalkListScreen> {
  late final WalkController _controller;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _controller = WalkController(ref);
    _loadInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _controller.loadWalkRecords();

    // 기본 반려동물 설정
    _controller.setSelectedPet(
      const PetInfo(
        id: 'pet1',
        name: 'Maxi',
        imagePath: 'assets/images/dogs/shiba.png',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPet = ref.watch(selectedPetNotifierProvider);
    final walkRecords = ref.watch(walkRecordsNotifierProvider);
    final mapExpanded = ref.watch(mapExpandedNotifierProvider);
    final currentWalk = ref.watch(currentWalkNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '산책',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (selectedPet != null)
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.pointBrown,
                  ),
                  child: const Icon(Icons.pets, size: 16, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  selectedPet.name,
                  style: AppFonts.fredoka(
                    fontSize: AppFonts.sm,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // 지도 섹션
          _buildMapSection(mapExpanded),

          // 산책 기록 리스트
          Expanded(child: _buildWalkRecordsList(walkRecords)),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(currentWalk),
    );
  }

  Widget _buildMapSection(bool mapExpanded) {
    return Container(
      height: mapExpanded ? MediaQuery.of(context).size.height * 0.6 : 200,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Stack(
        children: [
          // 지도 위젯
          MapWidget(
            walkRecords: ref.watch(walkRecordsNotifierProvider),
            selectedPet: ref.watch(selectedPetNotifierProvider),
          ),

          // 지도 확장 버튼
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: GestureDetector(
              onTap: _controller.toggleMapExpanded,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.pointDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  mapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalkRecordsList(List<WalkRecordEntity> walkRecords) {
    if (walkRecords.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 페이지 인디케이터
          _buildPageIndicator(),
          const SizedBox(height: AppSpacing.md),

          // 산책 기록 리스트
          Expanded(
            child: ListView.builder(
              itemCount: walkRecords.length,
              itemBuilder: (context, index) {
                final walkRecord = walkRecords[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: WalkRecordCardWidget(
                    walkRecord: walkRecord,
                    onTap: () => _showWalkDetails(walkRecord),
                    onLongPress: () => _showWalkOptions(walkRecord),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.pointBrown,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.pointGray.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.pointGray.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_walk,
            size: 64,
            color: AppColors.pointGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '散歩記録がありません。',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '一番目の散歩を始めてみてください。',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointGray.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(WalkRecordEntity? currentWalk) {
    if (currentWalk != null) {
      // 진행 중인 산책이 있는 경우
      return FloatingActionButton.extended(
        onPressed: _showCurrentWalkDialog,
        backgroundColor: AppColors.pointBrown,
        icon: const Icon(Icons.pause, color: Colors.white),
        label: Text(
          '散歩中...',
          style: AppFonts.bodyMedium.copyWith(color: Colors.white),
        ),
      );
    } else {
      // 새 산책 시작 버튼
      return FloatingActionButton.extended(
        onPressed: _showStartWalkDialog,
        backgroundColor: AppColors.pointBrown,
        icon: const Icon(Icons.directions_walk, color: Colors.white),
        label: Text(
          '散歩始め',
          style: AppFonts.bodyMedium.copyWith(color: Colors.white),
        ),
      );
    }
  }

  void _showStartWalkDialog() {
    showDialog(
      context: context,
      builder: (context) => _StartWalkDialog(controller: _controller),
    );
  }

  void _showCurrentWalkDialog() {
    final currentWalk = _controller.getCurrentWalk();
    if (currentWalk != null) {
      showDialog(
        context: context,
        builder: (context) => _CurrentWalkDialog(
          walkRecord: currentWalk,
          controller: _controller,
        ),
      );
    }
  }

  void _showWalkDetails(WalkRecordEntity walkRecord) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WalkDetailScreen(walkRecord: walkRecord),
      ),
    );
  }

  void _showWalkOptions(WalkRecordEntity walkRecord) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _WalkOptionsBottomSheet(
        walkRecord: walkRecord,
        controller: _controller,
      ),
    );
  }
}

class _StartWalkDialog extends StatefulWidget {
  final WalkController controller;

  const _StartWalkDialog({required this.controller});

  @override
  State<_StartWalkDialog> createState() => _StartWalkDialogState();
}

class _StartWalkDialogState extends State<_StartWalkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedPetId = 'pet1';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '새 산책 시작',
        style: AppFonts.fredoka(
          fontSize: AppFonts.lg,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '散歩のタイトル',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'タイトルを入力してください。';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _selectedPetId,
              decoration: const InputDecoration(
                labelText: 'ペット',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pet1', child: Text('Maxi')),
                DropdownMenuItem(value: 'pet2', child: Text('Luna')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPetId = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(onPressed: _startWalk, child: const Text('はじめ')),
      ],
    );
  }

  void _startWalk() async {
    if (_formKey.currentState!.validate()) {
      final result = await widget.controller.startNewWalk(
        title: _titleController.text,
        petId: _selectedPetId,
        petName: _selectedPetId == 'pet1' ? 'Maxi' : 'Luna',
        petImage: 'assets/images/dogs/shiba.png',
      );

      if (result.isSuccess && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _EditWalkDialog extends StatefulWidget {
  final WalkRecordEntity walkRecord;
  final WalkController controller;

  const _EditWalkDialog({required this.walkRecord, required this.controller});

  @override
  State<_EditWalkDialog> createState() => _EditWalkDialogState();
}

class _EditWalkDialogState extends State<_EditWalkDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.walkRecord.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '산책 기록 수정',
        style: AppFonts.fredoka(
          fontSize: AppFonts.lg,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '散歩のタイトル',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'タイトルを入力してください。';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text('開始時間: ${widget.walkRecord.timeString}'),
            Text('経過時間: ${widget.walkRecord.formattedDuration}'),
            Text('距離: ${widget.walkRecord.formattedDistance}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(onPressed: _updateWalk, child: const Text('更新')),
      ],
    );
  }

  void _updateWalk() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 수정된 산책 기록 생성
        final updatedWalkRecord = WalkRecordEntity(
          id: widget.walkRecord.id,
          title: _titleController.text,
          startTime: widget.walkRecord.startTime,
          endTime: widget.walkRecord.endTime,
          distance: widget.walkRecord.distance,
          duration: widget.walkRecord.duration,
          route: widget.walkRecord.route,
        );

        // 컨트롤러를 통해 수정
        await widget.controller.updateWalkRecord(updatedWalkRecord);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('散歩記録が更新されました'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('更新に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _CurrentWalkDialog extends StatelessWidget {
  final WalkRecordEntity walkRecord;
  final WalkController controller;

  const _CurrentWalkDialog({
    required this.walkRecord,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '산책 중',
        style: AppFonts.fredoka(
          fontSize: AppFonts.lg,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('散歩のタイトル: ${walkRecord.title}'),
          Text('開始時間: ${walkRecord.timeString}'),
          Text('経過時間: ${walkRecord.formattedDuration}'),
          Text('距離: ${walkRecord.formattedDistance}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            controller.pauseCurrentWalk();
          },
          child: const Text('一時停止'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await controller.endCurrentWalk();
          },
          child: const Text('終了'),
        ),
      ],
    );
  }
}

class _WalkOptionsBottomSheet extends ConsumerWidget {
  final WalkRecordEntity walkRecord;
  final WalkController controller;

  const _WalkOptionsBottomSheet({
    required this.walkRecord,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('編集'),
            onTap: () {
              Navigator.of(context).pop();
              _showEditWalkDialog(context, walkRecord);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('共有'),
            onTap: () {
              Navigator.of(context).pop();
              _showShareDialog(context, ref, walkRecord);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('削除', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(context).pop();
              controller.deleteWalkRecord(walkRecord.id);
            },
          ),
        ],
      ),
    );
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
                Navigator.of(context).pop();
                _copyToClipboard(context, ref, shareText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('画像を保存'),
              onTap: () {
                Navigator.of(context).pop();
                _saveAsImage(context, ref, walkRecord);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('システム共有'),
              onTap: () {
                Navigator.of(context).pop();
                _systemShare(context, ref, shareText);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
    final useCase = ref.read(copyToClipboardUseCaseProvider);
    final result = await useCase(text);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// 이미지로 저장
  Future<void> _saveAsImage(
    BuildContext context,
    WidgetRef ref,
    WalkRecordEntity walkRecord,
  ) async {
    final useCase = ref.read(saveAsImageUseCaseProvider);
    final result = await useCase(walkRecord);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// 시스템 공유
  Future<void> _systemShare(
    BuildContext context,
    WidgetRef ref,
    String text,
  ) async {
    final useCase = ref.read(systemShareUseCaseProvider);
    final result = await useCase(text, subject: 'あいぺっと 散歩記録共有');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// 산책 기록 수정 다이얼로그 표시
  void _showEditWalkDialog(BuildContext context, WalkRecordEntity walkRecord) {
    showDialog(
      context: context,
      builder: (context) =>
          _EditWalkDialog(walkRecord: walkRecord, controller: controller),
    );
  }
}
