import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/pet_profile/data/providers/pet_profile_providers.dart';
import 'qr_code/qr_code_handler.dart';
import 'qr_code/qr_code_pet_registration_tab.dart';
import 'qr_code/qr_code_reservation_tab.dart';
import 'qr_code_scanner_screen.dart';


/// QRコードボトムシート (70%サイズ)
///
/// ペット登録用と予約用のQRコード機能を提供
/// 注意: 現在home_menu_items.dartでコメントアウトされていますが、将来の使用のために保持
class QRCodeBottomSheet extends ConsumerStatefulWidget {
  const QRCodeBottomSheet({super.key});

  @override
  ConsumerState<QRCodeBottomSheet> createState() => _QRCodeBottomSheetState();

  /// ボトムシート表示ヘルパーメソッド
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QRCodeBottomSheet(),
    );
  }
}

class _QRCodeBottomSheetState extends ConsumerState<QRCodeBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petProfilesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // ヘッダー (タイトル + 閉じるボタン)
          _buildHeader(context),

          // 区切り線
          Divider(height: 1, color: Colors.grey.shade300),

          // タブバー
          _buildTabBar(),

          // タブビューコンテンツ
          Expanded(
            child: petsAsync.when(
              data: (pets) => _buildTabView(pets),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.pointBrown),
              ),
              error: (error, stack) => _buildErrorView(),
            ),
          ),

          // 閉じるボタン (固定)
          _buildCloseButton(context),
        ],
      ),
    );
  }

  /// ヘッダーセクション
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // バランス調整
          Text(
            'QRコードスキャナー',
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 28),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// タブバー
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.pointBrown,
        indicatorWeight: 3,
        labelColor: AppColors.pointDark,
        unselectedLabelColor: AppColors.pointGray,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        tabs: const [
          Tab(text: 'ペット登録'),
          Tab(text: '予約'),
        ],
      ),
    );
  }

  /// タブビュー
  Widget _buildTabView(List<PetProfileEntity> pets) {
    // アクティブなペットのみフィルタリング
    final activePets = pets
        .where((p) => p.petStatus != PetStatus.hidden)
        .toList();

    return TabBarView(
      controller: _tabController,
      children: [
        // ペット登録タブ
        QRCodePetRegistrationTab(
          activePets: activePets,
          onScanPressed: _scanQRCode,
        ),
        // 予約タブ
        QRCodeReservationTab(
          activePets: activePets,
          onScanPressed: _scanQRCode,
        ),
      ],
    );
  }

  /// エラービュー
  Widget _buildErrorView() {
    return Center(
      child: Text(
        'エラーが発生しました',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// 閉じるボタン
  Widget _buildCloseButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pointBrown,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Text(
            '閉じる',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// QRコードスキャンメソッド
  void _scanQRCode(BuildContext context, String scanType) {
    Navigator.of(context).pop(); // 現在のボトムシートを閉じる

    // QRコードスキャン画面に移動
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRCodeScannerScreen(
          onQRCodeScanned: (String qrData) {
            final handler = QRCodeHandler(ref, context);
            handler.handleQRCodeScanned(qrData, scanType);
          },
        ),
      ),
    );
  }
}
