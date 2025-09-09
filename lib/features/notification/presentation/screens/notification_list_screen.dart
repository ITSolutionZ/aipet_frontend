import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/notification_model.dart';
import '../components/lists/filter_chips_component.dart';
import '../controllers/notification_list_controller.dart';
import '../widgets/notification_list_widget.dart';

/// 알림 목록 화면 (리팩토링됨)
class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen({super.key});

  @override
  ConsumerState<NotificationListScreen> createState() =>
      _NotificationListScreenState();
}

class _NotificationListScreenState
    extends ConsumerState<NotificationListScreen> {
  late final NotificationListController _controller;
  NotificationType? _selectedFilter; // null = 全体 (전체)
  bool _shouldShowInfoCard = true;

  @override
  void initState() {
    super.initState();
    _controller = NotificationListController(ref);
    _checkNotificationSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 페이지가 다시 활성화될 때마다 알림 설정 확인
    _checkNotificationSettings();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 알림 설정 상태 확인
  Future<void> _checkNotificationSettings() async {
    final shouldShow = await _controller.checkNotificationSettings();
    if (mounted) {
      setState(() {
        _shouldShowInfoCard = shouldShow;
      });
    }
  }

  void _onFilterChanged(NotificationType? filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientBackAppBar(title: '通知'),
      body: Column(
        children: [
          // 상단 안내 섹션 (알림 설정이 완료되지 않았을 때만 표시)
          if (_shouldShowInfoCard) const InfoCardComponent(),

          // 동적 간격 (정보 카드가 있으면 md, 없으면 lg)
          SizedBox(height: _shouldShowInfoCard ? AppSpacing.md : AppSpacing.lg),

          // 필터 섹션 제목
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: const Text(
              '通知の種類',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.pointDark,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 필터 칩
          NotificationFilterChipsComponent(
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
          ),

          const SizedBox(height: AppSpacing.md),

          // 알림 리스트
          Expanded(
            child: NotificationListWidget(
              showEmptyState: true,
              maxItems: 50,
              filterType: _selectedFilter,
            ),
          ),
        ],
      ),
    );
  }
}
