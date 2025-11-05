import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';


import '../../../../shared/shared.dart';
import 'facility_list_screen.dart';


class FacilityTypeSelectionScreen extends ConsumerStatefulWidget {
  const FacilityTypeSelectionScreen({super.key});

  @override
  ConsumerState<FacilityTypeSelectionScreen> createState() =>
      _FacilityTypeSelectionScreenState();
}

class _FacilityTypeSelectionScreenState
    extends ConsumerState<FacilityTypeSelectionScreen> {
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
            // 헤더 섹션
            _buildHeaderSection(),
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
                child: _buildFacilityTypeCards(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFB89B8A),
      foregroundColor: AppColors.pointOffWhite,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        '시설 검색',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            '어떤 시설을 찾고 계신가요?',
            style: AppFonts.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointOffWhite,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '동물병원 또는 기타 시설을 선택해주세요',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointOffWhite.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityTypeCards() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          // 가로 배치된 시설 카드들
          Row(
            children: [
              // 왼쪽: 동물병원 카드
              Expanded(
                child: _buildFacilityTypeCard(
                  title: '動物病院',
                  subtitle: '救急室、24時間、特殊診療など',
                  icon: Icons.local_hospital,
                  iconColor: const Color(0xFF4A90E2),
                  backgroundColor: const Color(
                    0xFF4A90E2,
                  ).withValues(alpha: 0.1),
                  onTap: () => _navigateToHospitalList(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // 오른쪽: 기타 시설 카드
              Expanded(
                child: _buildFacilityTypeCard(
                  title: 'その他の施設',
                  subtitle: 'グルーミング、カフェ、ホテル、遊び場、教育センター',
                  icon: Icons.place,
                  iconColor: const Color(0xFFB89B8A),
                  backgroundColor: const Color(
                    0xFFB89B8A,
                  ).withValues(alpha: 0.1),
                  onTap: () => _navigateToFacilityList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // 도움말 섹션
          _buildHelpSection(),
        ],
      ),
    );
  }

  Widget _buildFacilityTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Icon(Icons.arrow_forward_ios, color: iconColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.toneOffWhite,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.toneLightGray, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline,
                color: AppColors.pointBrown,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '도움말',
                style: AppFonts.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '• 동물병원: 응급실, 24시간 진료, 특수진료 등',
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '• 기타 시설: 미용실, 카페, 호텔, 놀이터, 교육센터',
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _navigateToHospitalList() {
    context.push('/home/hospital-list');
  }

  void _navigateToFacilityList() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FacilityListScreen()));
  }
}
