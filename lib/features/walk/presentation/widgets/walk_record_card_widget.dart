import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:flutter/material.dart';

import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';
/// 산책 기록 카드 위젯
class WalkRecordCardWidget extends StatelessWidget {
  final WalkRecordEntity walkRecord;
  final VoidCallback? onTap;

  const WalkRecordCardWidget({super.key, required this.walkRecord, this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedTime = _formatTime(walkRecord.startTime);
    final formattedDuration = _formatDuration(walkRecord.calculatedDuration);
    final formattedDistance = _formatDistance(walkRecord.distance ?? 0.0);
    final statusLabel = _getStatusLabel(walkRecord.status);
    final statusColor = _getStatusColor(walkRecord.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 산책 기록 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.pets, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          walkRecord.petName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          statusLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),

              // 산책 정보
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    formattedTime,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    formattedDuration,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.route, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '$formattedDistance km (経路: ${walkRecord.route.length}ポイント)',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateTimeUtils.formatTime(dateTime);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    return '$minutes分';
  }

  String _formatDistance(double distance) {
    return distance.toStringAsFixed(2);
  }

  String _getStatusLabel(WalkStatus status) {
    switch (status) {
      case WalkStatus.completed:
        return '完了';
      case WalkStatus.inProgress:
        return '進行中';
      case WalkStatus.paused:
        return '一時停止';
      case WalkStatus.cancelled:
        return 'キャンセル';
    }
  }

  Color _getStatusColor(WalkStatus status) {
    switch (status) {
      case WalkStatus.completed:
        return Colors.green;
      case WalkStatus.inProgress:
        return Colors.blue;
      case WalkStatus.paused:
        return Colors.orange;
      case WalkStatus.cancelled:
        return Colors.red;
    }
  }
}
