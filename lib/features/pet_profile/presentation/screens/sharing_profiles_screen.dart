import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/controllers/sharing_profiles_controller.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/widgets/sharing_widgets.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SharingProfilesScreen extends ConsumerStatefulWidget {
  const SharingProfilesScreen({super.key});

  @override
  ConsumerState<SharingProfilesScreen> createState() =>
      _SharingProfilesScreenState();
}

class _SharingProfilesScreenState extends ConsumerState<SharingProfilesScreen>
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
    final petsAsync = ref.watch(petProfilesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientDrawerAppBar(title: 'プロフィール共有'),
      body: petsAsync.when(
        data: (pets) => Column(
          children: [
            _buildTabControl(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  GenerateCodeTab(pets: pets, onPetTap: _showQRCodeModal),
                  ScanCodeTab(onCodeScanned: _handleScannedCode),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
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
    final qrData = ref
        .read(sharingProfilesControllerProvider.notifier)
        .generateQRCode(pet);

    showDialog(
      context: context,
      builder: (context) => QRCodeModal(pet: pet, qrData: qrData),
    );
  }

  void _handleScannedCode(String code) {
    final result = ref
        .read(sharingProfilesControllerProvider.notifier)
        .handleScannedCode(code);

    if (result['success'] == true) {
      _showSuccessMessage(result['message']);
    } else {
      _showErrorMessage(result['error']);
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
