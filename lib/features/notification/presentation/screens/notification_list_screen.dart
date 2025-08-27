import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/design/design.dart';
import '../../../../shared/widgets/notification/notification_list_widget.dart';
import '../controllers/notification_ui_controller.dart';

/// 알림 목록 화면
class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen({super.key});

  @override
  ConsumerState<NotificationListScreen> createState() =>
      _NotificationListScreenState();
}

class _NotificationListScreenState extends ConsumerState<NotificationListScreen> {
  late final NotificationUIController _uiController;

  @override
  void initState() {
    super.initState();
    _uiController = NotificationUIController(ref);
  }

  @override
  void dispose() {
    _uiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Text(
          '通知一覧',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              context.push(RouteConstants.pushNotificationRoute);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: const NotificationListWidget(
        showEmptyState: true,
        maxItems: 50,
      ),
    );
  }
}
