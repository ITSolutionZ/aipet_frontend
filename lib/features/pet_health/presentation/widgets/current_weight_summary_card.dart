import 'package:aipet_frontend/features/pet_health/data/services/pet_health_local_storage_service.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentWeightSummaryCard extends ConsumerStatefulWidget {
  const CurrentWeightSummaryCard({super.key});

  @override
  ConsumerState<CurrentWeightSummaryCard> createState() =>
      _CurrentWeightSummaryCardState();
}

class _CurrentWeightSummaryCardState
    extends ConsumerState<CurrentWeightSummaryCard> {
  List<Map<String, dynamic>> _weightRecords = [];

  @override
  void initState() {
    super.initState();
    _loadWeightRecords();
  }

  Future<void> _loadWeightRecords() async {
    final records = await PetHealthLocalStorageService.getWeightRecords(
      petId: 'default',
    );
    setState(() {
      _weightRecords = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_weightRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    final weightRecords = _weightRecords;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.pointGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: const Icon(
                  Icons.monitor_weight_outlined,
                  color: AppColors.pointGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '現在の体重',
                style: AppFonts.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Column(
            children: [
              _buildWeightInfo(
                '現在',
                '${weightRecords.first['weight']}kg',
                AppColors.pointGreen,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildWeightInfo('変化', '+0.2kg', AppColors.pointBlue),
              const SizedBox(height: AppSpacing.sm),
              _buildWeightInfo('目標', '5.0kg', AppColors.pointBrown),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInfo(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(_getIconForLabel(label), color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: AppFonts.bodyMedium.copyWith(
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: AppFonts.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case '現在':
        return Icons.monitor_weight;
      case '変化':
        return Icons.trending_up;
      case '目標':
        return Icons.flag;
      default:
        return Icons.info;
    }
  }
}
