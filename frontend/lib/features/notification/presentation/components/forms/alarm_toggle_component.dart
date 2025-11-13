import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../../../data/data.dart';

class AlarmToggleComponent extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AlarmToggleComponent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleSwitchComponent(
      title: title,
      subtitle: subtitle,
      icon: NotificationIconService.getToggleIcon(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
