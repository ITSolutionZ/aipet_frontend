import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/shared.dart';
import '../../../pet_registor/domain/entities/pet_profile_entity.dart';

/// 펫 프로필 공유 화면
///
/// 펫 프로필을 QR 코드나 초대 링크로 공유할 수 있는 화면입니다.
class SharingProfilesScreen extends ConsumerStatefulWidget {
  const SharingProfilesScreen({super.key});

  @override
  ConsumerState<SharingProfilesScreen> createState() =>
      _SharingProfilesScreenState();
}

class _SharingProfilesScreenState extends ConsumerState<SharingProfilesScreen> {
  int _selectedTabIndex = 0;
  List<PetProfileEntity> _pets = [];

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  void _loadPets() {
    // MockDataService에서 펫 데이터 로드
    _pets = MockDataService.getMockPets();
    setState(() {});
  }

  String _generateShareLink(PetProfileEntity pet) {
    return 'https://aipet.app/share/${pet.name.toLowerCase()}-${pet.id}';
  }

  String _getGenderString(PetProfileEntity pet) {
    // MockDataService를 통한 성별 판단
    return MockDataService.getPetGenderByName(pet.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointOffWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.pointDark,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Sharing profiles',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // 현재 선택된 펫 이름 표시
          if (_pets.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              child: Text(
                _pets.first.name,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointDark.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 탭 컨트롤
          _buildTabControl(),
          const SizedBox(height: AppSpacing.lg),

          // 탭 내용
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildGenerateCodeTab()
                : _buildScanCodeTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabControl() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.toneOffWhite,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? AppColors.pointBrown
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Text(
                  'Generate Code',
                  textAlign: TextAlign.center,
                  style: AppFonts.bodyMedium.copyWith(
                    color: _selectedTabIndex == 0
                        ? Colors.white
                        : AppColors.pointDark.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? AppColors.pointBrown
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Text(
                  'Scan Code',
                  textAlign: TextAlign.center,
                  style: AppFonts.bodyMedium.copyWith(
                    color: _selectedTabIndex == 1
                        ? Colors.white
                        : AppColors.pointDark.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateCodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // 펫 프로필 목록
          ..._pets.map((pet) => _buildPetProfileCard(pet)),
          const SizedBox(height: AppSpacing.xl),

          // 설명 텍스트
          Text(
            'Generate a QR code and invite link for each pet and easily synchronise data with other users',
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetProfileCard(PetProfileEntity pet) {
    return GestureDetector(
      onTap: () => _showQRCodeModal(pet),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 펫 프로필 이미지
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(
                pet.imagePath ?? 'assets/images/dogs/shiba.png',
              ),
              backgroundColor: AppColors.pointBrown,
            ),
            const SizedBox(width: AppSpacing.md),

            // 펫 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.lg,
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${pet.type} | ${pet.breed}',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointDark.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // 성별 아이콘
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getGenderString(pet) == 'male'
                    ? AppColors.pointBlue
                    : Colors.pink,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getGenderString(pet) == 'male' ? Icons.male : Icons.female,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCodeTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 80,
            color: AppColors.pointDark.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Scan QR Code',
            style: AppFonts.titleLarge.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'QR 코드를 스캔하여 다른 사용자의 펫 프로필을 추가하세요',
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: () async {
              final result = await context.push('/qr-scanner');
              if (result != null && result is String) {
                _handleScannedCode(result);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
            ),
            child: Text(
              'QR 코드 스캔',
              style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '또는',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () async {
              final result = await context.push('/link-registration');
              if (result == true) {
                _showSuccessMessage('펫 프로필이 성공적으로 추가되었습니다.');
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.pointBlue, width: 2),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
            ),
            child: Text(
              '링크로 등록',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 스캔된 코드 처리
  void _handleScannedCode(String code) {
    // TODO: 스캔된 코드 처리 로직 구현
    _showSuccessMessage('QR 코드가 성공적으로 스캔되었습니다: $code');
  }

  /// 성공 메시지 표시
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.pointGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 링크를 클립보드에 복사
  Future<void> _copyLinkToClipboard(String link) async {
    try {
      await Clipboard.setData(ClipboardData(text: link));
      if (mounted) {
        _showSuccessMessage('링크가 클립보드에 복사되었습니다!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('링크 복사에 실패했습니다: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 프로필 공유
  Future<void> _shareProfile(PetProfileEntity pet) async {
    try {
      final shareLink = _generateShareLink(pet);
      final shareText =
          '''
🐾 ${pet.name}의 프로필을 공유합니다!

반려동물: ${pet.type} (${pet.breed})
성별: ${_getGenderString(pet) == 'male' ? '남' : '여'}

프로필 확인: $shareLink

AiPet 앱에서 더 많은 정보를 확인하세요!
      ''';

      await Share.share(shareText, subject: '${pet.name}의 펫 프로필');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('공유에 실패했습니다: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// QR 코드 모달 표시
  void _showQRCodeModal(PetProfileEntity pet) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${pet.name}의 QR 코드',
                    style: AppFonts.titleMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // QR 코드 (더미 이미지)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(
                    color: AppColors.pointDark.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code,
                      size: 120,
                      color: AppColors.pointDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'QR Code',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 공유 링크
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.toneOffWhite,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _generateShareLink(pet),
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointDark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _copyLinkToClipboard(_generateShareLink(pet)),
                      icon: const Icon(
                        Icons.copy,
                        color: AppColors.pointBlue,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 공유 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _shareProfile(pet),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                  ),
                  child: Text(
                    '공유하기',
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
