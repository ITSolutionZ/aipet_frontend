import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../../pet_registor/domain/entities/pet_profile_entity.dart';
import '../widgets/sharing_widgets.dart';

class SharingProfilesScreen extends ConsumerStatefulWidget {
  const SharingProfilesScreen({super.key});

  @override
  ConsumerState<SharingProfilesScreen> createState() =>
      _SharingProfilesScreenState();
}

class _SharingProfilesScreenState extends ConsumerState<SharingProfilesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PetProfileEntity> _pets = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPets() {
    // PetMockData에서 펫 데이터 로드
    _pets = PetMockData.getMockPets();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientDrawerAppBar(title: 'プロフィール共有'),
      body: Column(
        children: [
          _buildTabControl(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                GenerateCodeTab(pets: _pets, onPetTap: _showQRCodeModal),
                ScanCodeTab(onCodeScanned: _handleScannedCode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabControl() {
    return Container(
      color: AppColors.pointBrown,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.yellow,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code, size: 20),
                SizedBox(width: 8),
                Text('コード生成'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, size: 20),
                SizedBox(width: 8),
                Text('コードスキャン'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQRCodeModal(PetProfileEntity pet) {
    final qrData = 'pet_profile:${pet.id}:${pet.name}';

    showDialog(
      context: context,
      builder: (context) => QRCodeModal(pet: pet, qrData: qrData),
    );
  }

  void _handleScannedCode(String code) {
    if (code.startsWith('pet_profile:')) {
      _showSuccessMessage('QRコードをスキャンしました: $code');
    } else {
      _showErrorMessage('無効なQRコードです');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.pointGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.pointPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }
}
