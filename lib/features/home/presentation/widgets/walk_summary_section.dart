import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../controllers/walk_summary_controller.dart';

class WalkSummarySection extends ConsumerStatefulWidget {
  const WalkSummarySection({super.key});

  @override
  ConsumerState<WalkSummarySection> createState() => _WalkSummarySectionState();
}

class _WalkSummarySectionState extends ConsumerState<WalkSummarySection> {
  late WalkSummaryController _controller;
  Map<String, dynamic>? _walkData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WalkSummaryController(ref);
    _loadWalkData();
  }

  Future<void> _loadWalkData() async {
    final result = await _controller.loadWalkSummary();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _walkData = result.data as Map<String, dynamic>;
        }
      });
    }
  }

  void _handleWalkTap() {
    _controller.handleWalkTap().then((result) {
      if (result.isSuccess && mounted) {
        context.push('/walk');
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
            'お散歩のまとめ',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _buildLoadingCard()),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildLoadingCard()),
            ],
          ),
        ],
      );
    }

    final todayDistance = _walkData?['todayDistance'] ?? 12.3;
    final todayTime = _walkData?['todayTime'] ?? 30;
    
    final distanceValue = _controller.formatDistance(todayDistance);
    final distanceUnit = _controller.getDistanceUnit(todayDistance);
    final timeValue = _controller.formatTime(todayTime);
    final timeUnit = _controller.getTimeUnit(todayTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'お散歩のまとめ',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: _handleWalkTap,
          child: Row(
            children: [
              Expanded(
                child: _buildWalkStatCard(
                  distanceValue,
                  distanceUnit,
                  '距離',
                  Icons.route,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildWalkStatCard(
                  timeValue,
                  timeUnit,
                  '時間',
                  Icons.access_time,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalkStatCard(
    String value,
    String unit,
    String label,
    IconData icon,
  ) {
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
      child: Column(
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
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppFonts.fredoka(
                  fontSize: AppFonts.h1,
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                unit,
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
              ),
            ],
          ),
          Text(
            label,
            style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
          ),
        ],
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
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 24,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            height: 12,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
