import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../widgets/widgets.dart';

class VaccineScreen extends ConsumerStatefulWidget {
  final String petId;

  const VaccineScreen({
    super.key,
    required this.petId,
  });

  @override
  ConsumerState<VaccineScreen> createState() =>
      _VaccineScreenState();
}

class _VaccineScreenState
    extends ConsumerState<VaccineScreen> {
  
  // Mock 백신 데이터 (실제 구현에서는 Provider에서 가져올 것)
  final List<Map<String, dynamic>> _vaccines = [
    {
      'name': '狂犬病ワクチン',
      'description': '狂犬病を予防するための必須ワクチン',
      'isCompleted': true,
      'lastDate': '2024年3月15日',
      'nextDue': '2025年3月15日',
      'interval': '年1回',
      'veterinarian': {
        'name': '田中獣医師',
        'clinic': 'ペットクリニック田中',
      },
    },
    {
      'name': '混合ワクチン（5種）',
      'description': 'ジステンパー、パルボウイルスなど5種混合',
      'isCompleted': true,
      'lastDate': '2024年2月10日',
      'nextDue': '2025年2月10日',
      'interval': '年1回',
      'veterinarian': {
        'name': '田中獣医師',
        'clinic': 'ペットクリニック田中',
      },
    },
    {
      'name': 'フィラリア予防薬',
      'description': 'フィラリア症を予防するための薬剤',
      'isCompleted': false,
      'lastDate': '2024年5月1日',
      'nextDue': '2024年6月1日',
      'interval': '月1回（4-11月）',
      'veterinarian': {
        'name': '田中獣医師',
        'clinic': 'ペットクリニック田中',
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientDrawerAppBar(
        title: 'ワクチン記録',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 정보
            _buildHeaderCard(),
            const SizedBox(height: AppSpacing.lg),

            // 백신 목록
            Text(
              'ワクチン記録',
              style: AppFonts.titleLarge.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 백신 카드들
            ..._vaccines.map((vaccine) => VaccineCard(
                  vaccine: vaccine,
                  onTap: () => _showVaccineDetailModal(vaccine),
                )),

            const SizedBox(height: AppSpacing.xl),

            // 새 백신 추가 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddVaccineDialog,
                icon: const Icon(Icons.add),
                label: const Text('新しいワクチン記録を追加'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.pointGreen.withValues(alpha: 0.1),
            AppColors.pointBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.pointGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.pointGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: AppColors.pointGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ワクチン管理',
                      style: AppFonts.titleMedium.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '愛犬の健康を守るワクチン記録を管理',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointDark.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // 통계 정보
          Row(
            children: [
              Expanded(
                child: _buildStatItem('完了', '${_vaccines.where((v) => v['isCompleted'] == true).length}'),
              ),
              Expanded(
                child: _buildStatItem('予定', '${_vaccines.where((v) => v['isCompleted'] == false).length}'),
              ),
              Expanded(
                child: _buildStatItem('総数', '${_vaccines.length}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppFonts.titleLarge.copyWith(
            color: AppColors.pointGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointDark.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  void _showVaccineDetailModal(Map<String, dynamic> vaccine) {
    showDialog(
      context: context,
      builder: (context) => VaccineDetailModal(vaccine: vaccine),
    );
  }

  void _showAddVaccineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいワクチン記録'),
        content: const Text('ワクチン追加機能は開発中です。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}