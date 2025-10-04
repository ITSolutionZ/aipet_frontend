import 'package:aipet_frontend/features/daily/presentation/utils/health_status_utils.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/forms/forms.dart';
import 'package:flutter/material.dart';

/// 증상 선택 섹션 위젯
class SymptomsSelectionSection extends StatelessWidget {
  final List<String> selectedSymptoms;
  final ValueChanged<List<String>> onChanged;
  final List<String>? customSymptoms;

  const SymptomsSelectionSection({
    super.key,
    required this.selectedSymptoms,
    required this.onChanged,
    this.customSymptoms,
  });

  @override
  Widget build(BuildContext context) {
    final symptoms = customSymptoms ?? HealthStatusUtils.getAvailableSymptoms();

    return SectionCardContainer(
      title: '症状（複数選択可）',
      child: StringChipSelectorField(
        label: '',
        options: symptoms,
        selectedValues: selectedSymptoms,
        onChanged: onChanged,
      ),
    );
  }
}