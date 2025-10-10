import 'package:aipet_frontend/features/daily/data/providers/hospital_registration_provider.dart';
import 'package:aipet_frontend/features/daily/presentation/screens/hospital_management_screen_widgets/hospital_management_screen_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 내원 병원 관리 화면
class HospitalManagementScreen extends ConsumerStatefulWidget {
  const HospitalManagementScreen({super.key});

  @override
  ConsumerState<HospitalManagementScreen> createState() =>
      _HospitalManagementScreenState();
}

class _HospitalManagementScreenState
    extends ConsumerState<HospitalManagementScreen> {
  String? selectedPetId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB89B8A), // 갈색 그라데이션 시작
              Color(0xFFA08A7A), // 갈색 그라데이션 중간
              Color(0xFF967E6D), // 갈색 그라데이션 끝
            ],
          ),
        ),
        child: Column(
          children: [
            // 펫 프로필 헤더 섹션
            HospitalPetProfileHeader(selectedPetId: selectedPetId),
            // 메인 콘텐츠
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundGray,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      // 등록된 병원 목록
                      RegisteredHospitalsList(
                        onHospitalAction: _handleHospitalAction,
                        onAddHospital: () =>
                            HospitalDialogs.showAddHospitalDialog(context, ref),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // 액션 버튼들
                      HospitalActionButtons(
                        onEmergencyContacts: () =>
                            HospitalDialogs.showEmergencyContactsDialog(
                              context,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.pointBrown,
      elevation: 0,
      automaticallyImplyLeading: true,
      title: const Text(
        '病院管理',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.pointBrown,
        ),
      ),
      centerTitle: true,
    );
  }

  void _handleHospitalAction(String action, RegisteredHospital hospital) async {
    switch (action) {
      case 'call':
        await HospitalDialogs.makePhoneCall(context, hospital.phoneNumber);
        break;
      case 'remove':
        HospitalDialogs.showRemoveHospitalDialog(context, ref, hospital);
        break;
    }
  }
}
