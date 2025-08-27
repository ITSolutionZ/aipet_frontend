import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/design/design.dart';
import '../../data/providers/notification_providers.dart';
import '../../domain/entities/entities.dart';
import '../controllers/notification_ui_controller.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  final String notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  NotificationModel? _notification;
  bool _isLoading = true;
  late final NotificationUIController _uiController;

  @override
  void initState() {
    super.initState();
    _uiController = NotificationUIController(ref);
    _loadNotification();
  }

  @override
  void dispose() {
    _uiController.dispose();
    super.dispose();
  }

  void _loadNotification() {
    setState(() => _isLoading = true);

    // Riverpod을 통해 알림 데이터 가져오기
    ref
        .read(notificationByIdProvider(widget.notificationId))
        .when(
          data: (notification) {
            setState(() {
              _notification = notification;
              _isLoading = false;
            });

            // 읽음 처리
            if (notification != null &&
                notification.status == NotificationStatus.unread) {
              _markAsRead(notification);
            }
          },
          loading: () {
            setState(() => _isLoading = true);
          },
          error: (error, stack) {
            setState(() => _isLoading = false);
            _uiController.showErrorSnackBar(
              context,
              '通知を読み込む際にエラーが発生しました: $error',
            );
          },
        );
  }

  void _markAsRead(NotificationModel notification) {
    // UI 컨트롤러를 통해 읽음 처리 (UI 피드백 포함)
    _uiController.markAsReadWithFeedback(context, notification.id);
    setState(() {
      _notification = notification;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        appBar: AppBar(
          title: const Text('通知詳細'),
          backgroundColor: AppColors.pointBrown,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final notification = _notification;
    if (notification == null) {
      return Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        appBar: AppBar(
          title: const Text('通知詳細'),
          backgroundColor: AppColors.pointBrown,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('通知を見つけることができませんでした。')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Text(
          '通知詳細',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        actions: [
          if (notification.actionUrl != null)
            TextButton(
              onPressed: () => _handleAction(notification),
              child: Text(
                '直接アクセス',
                style: AppFonts.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 카드
            Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              child: Card(
                color: Colors.white,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 타입 및 시간
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: notification.type.color.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppRadius.medium,
                              ),
                            ),
                            child: Icon(
                              notification.type.icon,
                              color: notification.type.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.type.name,
                                  style: AppFonts.bodyMedium.copyWith(
                                    color: notification.type.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatDateTime(notification.createdAt),
                                  style: AppFonts.bodySmall.copyWith(
                                    color: AppColors.pointGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (notification.petName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.pointBrown.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.small,
                                ),
                              ),
                              child: Text(
                                notification.petName!,
                                style: AppFonts.bodySmall.copyWith(
                                  color: AppColors.pointBrown,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // 제목
                      Text(
                        notification.title,
                        style: AppFonts.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.pointDark,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // 메시지
                      Text(
                        notification.body,
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.pointDark,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 메타데이터 정보 (있는 경우)
            if (notification.metadata != null &&
                notification.metadata!.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '詳細情報',
                          style: AppFonts.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.pointDark,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ..._buildMetadataWidgets(notification),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.lg),

            // 액션 버튼들
            if (notification.actionUrl != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ショットカット',
                          style: AppFonts.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.pointDark,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleAction(notification),
                            icon: Icon(_getActionIcon(notification.type)),
                            label: Text(_getActionText(notification.type)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pointBrown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _deleteNotification,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('通知を削除'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMetadataWidgets(NotificationModel notification) {
    final metadata = notification.metadata!;
    final widgets = <Widget>[];

    // 알림 유형별 메타데이터 표시
    switch (notification.type) {
      case NotificationType.feeding:
        if (metadata['amount'] != null) {
          widgets.add(_buildMetadataRow('食事量', '${metadata['amount']}g'));
        }
        if (metadata['scheduledTime'] != null) {
          widgets.add(_buildMetadataRow('予定時間', metadata['scheduledTime']));
        }
        if (metadata['mealTime'] != null) {
          final mealTimeText = metadata['mealTime'] == 'morning'
              ? '朝'
              : metadata['mealTime'] == 'lunch'
              ? '昼'
              : '夜';
          widgets.add(_buildMetadataRow('食事時間', mealTimeText));
        }
        break;

      case NotificationType.walk:
        if (metadata['recommendedDuration'] != null) {
          widgets.add(
            _buildMetadataRow('推奨時間', '${metadata['recommendedDuration']}分'),
          );
        }
        if (metadata['weather'] != null) {
          widgets.add(_buildMetadataRow('天気', metadata['weather']));
        }
        if (metadata['temperature'] != null) {
          widgets.add(_buildMetadataRow('気温', '${metadata['temperature']}°C'));
        }
        break;

      case NotificationType.health:
      case NotificationType.medical:
        if (metadata['vaccineType'] != null) {
          widgets.add(_buildMetadataRow('ワクチン種類', metadata['vaccineType']));
        }
        if (metadata['appointmentDate'] != null &&
            metadata['appointmentTime'] != null) {
          widgets.add(
            _buildMetadataRow(
              '予約日時',
              '${metadata['appointmentDate']} ${metadata['appointmentTime']}',
            ),
          );
        }
        if (metadata['hospitalName'] != null) {
          widgets.add(_buildMetadataRow('病院名', metadata['hospitalName']));
        }
        break;

      case NotificationType.reservation:
      case NotificationType.grooming:
        if (metadata['facilityName'] != null) {
          widgets.add(_buildMetadataRow('施設名', metadata['facilityName']));
        }
        if (metadata['services'] != null) {
          final services = (metadata['services'] as List).join(', ');
          widgets.add(_buildMetadataRow('サービス', services));
        }
        if (metadata['price'] != null) {
          widgets.add(
            _buildMetadataRow('価格', '${_formatCurrency(metadata['price'])}円'),
          );
        }
        break;

      case NotificationType.system:
      case NotificationType.emergency:
        if (metadata['averageIntake'] != null) {
          widgets.add(
            _buildMetadataRow('平均摂取率', '${metadata['averageIntake']}%'),
          );
        }
        if (metadata['daysObserved'] != null) {
          widgets.add(
            _buildMetadataRow('観察期間', '${metadata['daysObserved']}日'),
          );
        }
        break;

      default:
        break;
    }

    return widgets;
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(NotificationType type) {
    switch (type) {
      case NotificationType.feeding:
        return Icons.restaurant;
      case NotificationType.walk:
        return Icons.directions_walk;
      case NotificationType.medical:
        return Icons.medical_services;
      case NotificationType.grooming:
        return Icons.content_cut;
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.emergency:
        return Icons.analytics;
      default:
        return Icons.arrow_forward;
    }
  }

  String _getActionText(NotificationType type) {
    switch (type) {
      case NotificationType.feeding:
        return 'フード管理に移動';
      case NotificationType.walk:
        return '散歩記録に移動';
      case NotificationType.medical:
        return '健康管理に移動';
      case NotificationType.grooming:
        return '予約管理に移動';
      case NotificationType.appointment:
        return '予約詳細を見る';
      case NotificationType.emergency:
        return '分析結果を見る';
      default:
        return '詳細を見る';
    }
  }

  void _handleAction(NotificationModel notification) {
    if (notification.actionUrl != null) {
      final url = notification.actionUrl!;

      // URL 파싱하여 적절한 화면으로 이동
      if (url.startsWith('/event-detail/')) {
        context.push(url);
      } else if (url.startsWith('/feeding-schedule/')) {
        final petId = url.split('/')[2];
        final petName = notification.petName ?? '';
        context.push(
          '${RouteConstants.feedingScheduleRoute}/$petId?petName=$petName',
        );
      } else if (url.startsWith('/feeding-analysis/')) {
        final petId = url.split('/')[2];
        final petName = notification.petName ?? '';
        context.push(
          '${RouteConstants.feedingAnalysisRoute}/$petId?petName=$petName',
        );
      } else if (url == '/walk') {
        context.push(RouteConstants.walkRoute);
      } else if (url == '/vaccines') {
        context.push(RouteConstants.vaccinesRoute);
      } else if (url == '/reservation') {
        context.push(RouteConstants.calendarRoute);
      } else {
        // 기본적으로 URL을 그대로 사용
        context.push(url);
      }
    }
  }

  void _deleteNotification() {
    if (_notification == null) return;

    // UI 컨트롤러를 통해 삭제 확인 다이얼로그 표시
    _uiController.showDeleteConfirmationDialog(context).then((confirmed) {
      if (confirmed) {
        // UI 컨트롤러를 통해 알림 삭제 (UI 피드백 포함)
        _uiController.deleteNotificationWithFeedback(
          context,
          _notification!.id,
        );
        context.pop();
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount is int) {
      return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      );
    }
    return amount.toString();
  }
}
