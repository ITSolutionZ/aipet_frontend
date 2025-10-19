import 'package:aipet_frontend/shared/design/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/design/tokens/tokens.dart';
import 'qr_code_scanner_screen.dart';

/// QR 코드 바텀시트 위젯 (70% 크기)
class QRCodeBottomSheet extends ConsumerStatefulWidget {
  const QRCodeBottomSheet({super.key});

  @override
  ConsumerState<QRCodeBottomSheet> createState() => _QRCodeBottomSheetState();

  /// 바텀시트 표시 헬퍼 메서드
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
          // 헤더 (제목 + 닫기 버튼)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40), // 균형 맞추기
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
          ),

          // 구분선
          Divider(height: 1, color: Colors.grey.shade300),

          // 탭 바
          Container(
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
          ),

          // 탭 뷰 컨텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 펫 등록 탭
                _buildPetRegistrationTab(),
                // 예약 탭
                _buildReservationTab(),
              ],
            ),
          ),

          // 닫기 버튼 (고정)
          Padding(
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
          ),
        ],
      ),
    );
  }

  /// 펫 등록 탭 위젯
  Widget _buildPetRegistrationTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // 설명 텍스트
          Text(
            'ペット登録用のQRコードをスキャンしてください。',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // QR 스캔 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              size: 60,
              color: AppColors.pointBrown,
            ),
          ),

          const SizedBox(height: 40),

          // 스캔 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _scanQRCode(context, 'pet_registration'),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('ペット登録用QRスキャン'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 설명 텍스트
          Text(
            '動物病院で発行されたペット登録用QRコードをスキャンしてください。',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 예약 탭 위젯
  Widget _buildReservationTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // 설명 텍스트
          Text(
            '予約用のQRコードをスキャンしてください。',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // QR 스캔 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              size: 60,
              color: AppColors.pointBrown,
            ),
          ),

          const SizedBox(height: 40),

          // 스캔 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _scanQRCode(context, 'reservation'),
              icon: const Icon(Icons.calendar_today),
              label: const Text('予約用QRスキャン'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 설명 텍스트
          Text(
            '動物病院やペットサロンで発行された予約用QRコードをスキャンしてください。',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// QR 코드 스캔 메서드
  void _scanQRCode(BuildContext context, String scanType) {
    Navigator.of(context).pop(); // 현재 바텀시트 닫기

    // QR 코드 스캔 화면으로 이동
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRCodeScannerScreen(
          onQRCodeScanned: (String qrData) {
            _handleQRCodeScanned(context, qrData, scanType);
          },
        ),
      ),
    );
  }

  /// QR 코드 스캔 결과 처리
  void _handleQRCodeScanned(
    BuildContext context,
    String qrData,
    String scanType,
  ) {
    if (scanType == 'pet_registration') {
      // 펫 등록용 QR 코드 처리
      if (qrData.startsWith('AIPET:')) {
        final parts = qrData.split(':');
        if (parts.length >= 3) {
          final petId = parts[1];
          final petName = parts[2];
          _showAddFamilyDialog(context, petId, petName);
        }
      } else {
        _showErrorMessage(context, 'ペット登録用のQRコードではありません');
      }
    } else if (scanType == 'reservation') {
      // 예약용 QR 코드 처리
      if (qrData.startsWith('RESERVATION:')) {
        final parts = qrData.split(':');
        if (parts.length >= 2) {
          final reservationId = parts[1];
          _showReservationDialog(context, reservationId);
        }
      } else {
        _showErrorMessage(context, '予約用のQRコードではありません');
      }
    } else {
      _showErrorMessage(context, '無効なQRコードです');
    }
  }

  /// 에러 메시지 표시
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// 예약 다이얼로그 표시
  void _showReservationDialog(BuildContext context, String reservationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('予約確認'),
        content: Text('予約ID: $reservationId\nこの予約を確認しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              _processReservation(context, reservationId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
              foregroundColor: Colors.white,
            ),
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }

  /// 예약 처리
  void _processReservation(BuildContext context, String reservationId) {
    // TODO: 실제 예약 처리 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('予約 $reservationId が確認されました'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 가족 추가 다이얼로그
  void _showAddFamilyDialog(
    BuildContext context,
    String petId,
    String petName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('家族を追加'),
        content: Text('$petName の家族として追加しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              _addFamilyMember(context, petId, petName);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
              foregroundColor: Colors.white,
            ),
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  /// 가족 멤버 추가
  void _addFamilyMember(BuildContext context, String petId, String petName) {
    // TODO: 실제 가족 추가 로직 구현
    // 현재는 성공 메시지만 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$petName を家族として追加しました'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
