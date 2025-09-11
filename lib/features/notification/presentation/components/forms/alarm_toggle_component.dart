import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';
import '../../../data/services/notification_icon_service.dart';

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
