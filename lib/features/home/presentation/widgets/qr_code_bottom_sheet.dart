import 'dart:async';

import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../shared/shared.dart';
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
  PetProfileEntity? _selectedPet;
  bool _showQRCode = false;
  PetProfileEntity? _selectedReservationPet;
  bool _showReservationQRCode = false;

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
    final petsAsync = ref.watch(petProfilesProvider);

    return petsAsync.when(
      data: (pets) {
        // 활성 펫만 필터링
        final activePets = pets
            .where((p) => p.petStatus != PetStatus.hidden)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 내 펫 QR 코드 섹션
              if (activePets.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pointBrown.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.pointBrown.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.pets,
                            size: 20,
                            color: AppColors.pointBrown,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '私のペットを共有',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.pointDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '他の人に共有したいペットを選択してください',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPetSelector(activePets),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
              ],

              // QR 스캔 섹션
              Text(
                'ペット登録用のQRコードをスキャンしてください。',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // QR 스캔 아이콘
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.pointBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 50,
                  color: AppColors.pointBrown,
                ),
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 16),

              // 설명 텍스트
              Text(
                '他の人が共有したペット登録用QRコードをスキャンしてください。',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.pointBrown),
      ),
      error: (error, stack) => Center(
        child: Text(
          'エラーが発生しました',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 펫 선택기 위젯
  Widget _buildPetSelector(List<PetProfileEntity> pets) {
    return Column(
      children: [
        // 펫 선택 드롭다운
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.pointGray.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PetProfileEntity>(
              isExpanded: true,
              value: _selectedPet,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'ペットを選択',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              items: pets.map((pet) {
                return DropdownMenuItem(
                  value: pet,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text(
                          pet.typeIcon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pet.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.pointDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (pet) {
                setState(() {
                  _selectedPet = pet;
                  _showQRCode = false;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // QR 코드 표시 버튼
        if (_selectedPet != null)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showQRCode = !_showQRCode;
                });
              },
              icon: Icon(_showQRCode ? Icons.visibility_off : Icons.qr_code),
              label: Text(_showQRCode ? 'QRコードを隠す' : 'QRコードを表示'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

        // QR 코드 표시
        if (_showQRCode && _selectedPet != null) ...[
          const SizedBox(height: 20),
          _buildQRCodeDisplay(_selectedPet!),
        ],
      ],
    );
  }

  /// QR 코드 표시 위젯
  Widget _buildQRCodeDisplay(PetProfileEntity pet) {
    final qrData =
        'pet_profile:${pet.id}|${pet.name}|${pet.type}|${pet.weight}kg|https://aipet.app/pet/${pet.id}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 펫 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(pet.typeIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                pet.name,
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${pet.typeName} • ${pet.weight}kg',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // QR 코드
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.pointGray.withValues(alpha: 0.3),
              ),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
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
                size: Size(40, 40),
                color: AppColors.pointBrown,
              ),
              errorStateBuilder: (cxt, err) {
                return const Center(
                  child: Text(
                    'QR コード生成エラー',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.pointGray, fontSize: 12),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 설명 텍스트
          Text(
            'このQRコードをスキャンして\n${pet.name}を共同管理者として追加できます',
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
    final petsAsync = ref.watch(petProfilesProvider);

    return petsAsync.when(
      data: (pets) {
        // 활성 펫만 필터링
        final activePets = pets
            .where((p) => p.petStatus != PetStatus.hidden)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 내 펫 QR 코드 섹션
              if (activePets.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pointBrown.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.pointBrown.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: AppColors.pointBrown,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ペットの予約QRコード',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.pointDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '予約に使用するペットを選択してください',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildReservationPetSelector(activePets),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
              ],

              // QR 스캔 섹션
              Text(
                '予約用のQRコードをスキャンしてください。',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // QR 스캔 아이콘
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.pointBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 50,
                  color: AppColors.pointBrown,
                ),
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 16),

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
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.pointBrown),
      ),
      error: (error, stack) => Center(
        child: Text(
          'エラーが発生しました',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 예약용 펫 선택기 위젯
  Widget _buildReservationPetSelector(List<PetProfileEntity> pets) {
    return Column(
      children: [
        // 펫 선택 드롭다운
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.pointGray.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PetProfileEntity>(
              isExpanded: true,
              value: _selectedReservationPet,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'ペットを選択',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              items: pets.map((pet) {
                return DropdownMenuItem(
                  value: pet,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text(
                          pet.typeIcon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pet.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.pointDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (pet) {
                setState(() {
                  _selectedReservationPet = pet;
                  _showReservationQRCode = false;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // QR 코드 표시 버튼
        if (_selectedReservationPet != null)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showReservationQRCode = !_showReservationQRCode;
                });
              },
              icon: Icon(
                _showReservationQRCode ? Icons.visibility_off : Icons.qr_code,
              ),
              label: Text(_showReservationQRCode ? 'QRコードを隠す' : 'QRコードを表示'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

        // QR 코드 표시
        if (_showReservationQRCode && _selectedReservationPet != null) ...[
          const SizedBox(height: 20),
          _buildReservationQRCodeDisplay(_selectedReservationPet!),
        ],
      ],
    );
  }

  /// 예약용 QR 코드 표시 위젯
  Widget _buildReservationQRCodeDisplay(PetProfileEntity pet) {
    // 예약용 QR 데이터: 펫 정보 + 예약 타입
    final qrData =
        'reservation:${pet.id}|${pet.name}|${pet.type}|${pet.weight}kg|https://aipet.app/reservation/${pet.id}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 펫 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(pet.typeIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                pet.name,
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${pet.typeName} • ${pet.weight}kg',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // QR 코드
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.pointGray.withValues(alpha: 0.3),
              ),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
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
                size: Size(40, 40),
                color: AppColors.pointBrown,
              ),
              errorStateBuilder: (cxt, err) {
                return const Center(
                  child: Text(
                    'QR コード生成エラー',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.pointGray, fontSize: 12),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 설명 텍스트
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.pointBrown.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.pointBrown,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '病院やサロンでこのQRコードを\nスキャンして予約できます',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.pointDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
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
      // 형식: pet_profile:{펫ID}|{이름}|{타입}|{체중}kg|https://aipet.app/pet/{펫ID}
      if (qrData.startsWith('pet_profile:')) {
        final dataWithoutPrefix = qrData.substring('pet_profile:'.length);
        final parts = dataWithoutPrefix.split('|');
        if (parts.isNotEmpty) {
          final petId = parts[0];
          final petName = parts.length > 1 ? parts[1] : '不明';
          final petType = parts.length > 2 ? parts[2] : '';
          final petWeight = parts.length > 3 ? parts[3] : '';
          _showAddFamilyDialog(context, petId, petName, petType, petWeight);
        } else {
          _showErrorMessage(context, 'QRコードの形式が正しくありません');
        }
      }
      // 레거시 형식 지원: AIPET:
      else if (qrData.startsWith('AIPET:')) {
        final parts = qrData.split(':');
        if (parts.length >= 3) {
          final petId = parts[1];
          final petName = parts[2];
          _showAddFamilyDialog(context, petId, petName, '', '');
        }
      } else {
        _showErrorMessage(context, 'ペット登録用のQRコードではありません');
      }
    } else if (scanType == 'reservation') {
      // 예약용 QR 코드 처리
      // 형식: reservation:{펫ID}|{이름}|{타입}|{체중}kg|https://aipet.app/reservation/{펫ID}
      if (qrData.startsWith('reservation:')) {
        final dataWithoutPrefix = qrData.substring('reservation:'.length);
        final parts = dataWithoutPrefix.split('|');
        if (parts.isNotEmpty) {
          final petId = parts[0];
          final petName = parts.length > 1 ? parts[1] : '不明';
          final petType = parts.length > 2 ? parts[2] : '';
          final petWeight = parts.length > 3 ? parts[3] : '';
          _showReservationDialog(context, petId, petName, petType, petWeight);
        } else {
          _showErrorMessage(context, 'QRコードの形式が正しくありません');
        }
      }
      // 레거시 형식 지원: RESERVATION:
      else if (qrData.startsWith('RESERVATION:')) {
        final parts = qrData.split(':');
        if (parts.length >= 2) {
          final reservationId = parts[1];
          _showReservationDialog(context, reservationId, '', '', '');
        }
      } else {
        _showErrorMessage(context, '予約用のQRコードではありません');
      }
    } else {
      _showErrorMessage(context, '無効なQRコードです');
    }
  }

  /// 에러 메시지 표시
  /// ✅ Shared SnackBarService 사용
  void _showErrorMessage(BuildContext context, String message) {
    SnackBarService.showError(context, message);
  }

  /// 예약 다이얼로그 표시
  void _showReservationDialog(
    BuildContext context,
    String petId,
    String petName,
    String petType,
    String petWeight,
  ) {
    // 펫 타입을 일본어로 변환
    String getTypeName(String type) {
      switch (type.toLowerCase()) {
        case 'dog':
          return '犬';
        case 'cat':
          return '猫';
        case 'bird':
          return '鳥';
        case 'hamster':
          return 'ハムスター';
        case 'rabbit':
          return 'うさぎ';
        case 'turtle':
          return '亀';
        default:
          return type;
      }
    }

    final typeDisplay = petType.isNotEmpty ? getTypeName(petType) : '';
    final weightDisplay = petWeight.isNotEmpty ? petWeight : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('予約確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (petName.isNotEmpty) ...[
              Text(
                '$petName の予約を確認しますか？',
                style: const TextStyle(fontSize: 16),
              ),
              if (typeDisplay.isNotEmpty || weightDisplay.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'ペット情報',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointBrown,
                  ),
                ),
                const SizedBox(height: 8),
                if (typeDisplay.isNotEmpty)
                  Text(
                    '種類: $typeDisplay',
                    style: const TextStyle(fontSize: 14),
                  ),
                if (weightDisplay.isNotEmpty)
                  Text(
                    '体重: $weightDisplay',
                    style: const TextStyle(fontSize: 14),
                  ),
              ],
            ] else
              Text('予約ID: $petId\nこの予約を確認しますか？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              _processReservation(context, petId, petName);
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
  void _processReservation(BuildContext context, String petId, String petName) {
    // TODO: 실제 예약 처리 로직 구현
    final displayName = petName.isNotEmpty ? petName : petId;
    // ✅ Shared SnackBarService 사용
    SnackBarService.showSuccess(context, '$displayName の予約が確認されました');
  }

  /// 가족 추가 다이얼로그
  void _showAddFamilyDialog(
    BuildContext context,
    String petId,
    String petName,
    String petType,
    String petWeight,
  ) {
    // 펫 타입을 일본어로 변환
    String getTypeName(String type) {
      switch (type.toLowerCase()) {
        case 'dog':
          return '犬';
        case 'cat':
          return '猫';
        case 'bird':
          return '鳥';
        case 'hamster':
          return 'ハムスター';
        case 'rabbit':
          return 'うさぎ';
        case 'turtle':
          return '亀';
        default:
          return type;
      }
    }

    final typeDisplay = petType.isNotEmpty ? getTypeName(petType) : '';
    final weightDisplay = petWeight.isNotEmpty ? petWeight : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('共同管理者として追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$petName を共同管理者として追加しますか？',
              style: const TextStyle(fontSize: 16),
            ),
            if (typeDisplay.isNotEmpty || weightDisplay.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'ペット情報',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointBrown,
                ),
              ),
              const SizedBox(height: 8),
              if (typeDisplay.isNotEmpty)
                Text('種類: $typeDisplay', style: const TextStyle(fontSize: 14)),
              if (weightDisplay.isNotEmpty)
                Text(
                  '体重: $weightDisplay',
                  style: const TextStyle(fontSize: 14),
                ),
            ],
          ],
        ),
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
  Future<void> _addFamilyMember(
    BuildContext dialogContext,
    String petId,
    String petName,
  ) async {
    // BuildContext를 미리 캡처
    final navigator = Navigator.of(dialogContext);
    final scaffoldMessenger = ScaffoldMessenger.of(dialogContext);
    final router = GoRouter.of(dialogContext);

    try {
      // 로딩 다이얼로그 표시 (unawaited로 처리)
      unawaited(
        showDialog(
          context: dialogContext,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.pointBrown),
          ),
        ),
      );

      // 펫 정보 로드
      final repository = ref.read(petProfileRepositoryProvider);
      final result = await repository.getPetById(petId);

      if (!mounted) return;

      // 로딩 다이얼로그 닫기
      navigator.pop();

      if (result.isSuccess && result.dataOrNull != null) {
        final pet = result.dataOrNull!;

        // 펫을 로컬 데이터베이스에 추가
        final notifier = ref.read(petProfilesProvider.notifier);
        await notifier.createPet(pet);

        if (!mounted) return;

        // 성공 메시지 표시
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('$petName を共同管理ペットとして追加しました'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: '確認',
              textColor: Colors.white,
              onPressed: () {
                router.push('/pet-management');
              },
            ),
          ),
        );
      } else {
        // 펫을 찾을 수 없음
        if (!mounted) return;

        unawaited(
          showDialog(
            context: dialogContext,
            builder: (dialogCtx) => AlertDialog(
              title: const Text('ペットが見つかりません'),
              content: const Text(
                '共有されたペットの情報を読み込めませんでした。\n'
                'ペットの所有者に確認してください。',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('確認'),
                ),
              ],
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      // 로딩 다이얼로그가 열려있으면 닫기
      navigator.pop();

      // 에러 메시지 표시
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
