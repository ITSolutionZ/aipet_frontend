import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../controllers/health_summary_controller.dart';

class HealthSummarySection extends ConsumerStatefulWidget {
  const HealthSummarySection({
    super.key,
    this.petId = '1',
  });

  final String petId;

  @override
  ConsumerState<HealthSummarySection> createState() => _HealthSummarySectionState();
}

class _HealthSummarySectionState extends ConsumerState<HealthSummarySection> {
  late HealthSummaryController _controller;
  List<HealthItemData>? _healthItems;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = HealthSummaryController(ref);
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    final result = await _controller.loadHealthSummary(widget.petId);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _healthItems = result.data as List<HealthItemData>;
        }
      });
    }
  }

  void _handleHealthItemTap(String route) {
    _controller.handleHealthItemTap(route).then((result) {
      if (result.isSuccess && mounted) {
        context.push(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '健康のまとめ',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLoadingCard(),
          const SizedBox(height: AppSpacing.md),
          _buildLoadingCard(),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '健康のまとめ',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_healthItems != null)
          ...(_healthItems!).map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildHealthCard(
                context,
                item.title,
                item.value,
                item.icon,
                item.route,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHealthCard(
    BuildContext context,
    String title, 
    String value, 
    IconData icon, 
    String route,
  ) {
    return GestureDetector(
      onTap: () => _handleHealthItemTap(route),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.pointBrown.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.pointBrown, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.pointGray),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  height: 12,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
