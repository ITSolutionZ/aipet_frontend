import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';

import 'package:aipet_frontend/shared/ui/components/cards/info_card.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/facility/facility_mock_service.dart';
import 'package:aipet_frontend/shared/foundation/error_handler/app_error_handler.dart';
import 'package:flutter/material.dart';

class FacilityFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FacilityFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.pointBrown.withValues(alpha: 0.2),
      checkmarkColor: AppColors.pointBrown,
    );
  }
}
