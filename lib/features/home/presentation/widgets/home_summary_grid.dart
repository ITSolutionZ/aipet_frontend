import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';
import 'widgets.dart';

class HomeSummaryGrid extends StatelessWidget {
  const HomeSummaryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionTitle(),
        Transform.translate(offset: const Offset(0, -32), child: _buildGrid()),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return const Text(
      '今日のサマリー',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'MPlusRounded1c',
        color: AppColors.pointDark,
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.1,
      children: const [
        WalkSummaryCard(),
        FeedingSummaryCard(),
        WeightSummaryCard(),
        AppointmentSummaryCard(),
      ],
    );
  }
}
