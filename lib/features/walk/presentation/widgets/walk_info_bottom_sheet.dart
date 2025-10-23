import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:flutter/material.dart';

import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';
/// 산책 정보 바텀시트
class WalkInfoBottomSheet extends StatelessWidget {
  final WalkRecordEntity walkRecord;
  final bool showHeader;

  const WalkInfoBottomSheet({
    super.key,
    required this.walkRecord,
    this.showHeader = true,
  });

  static Future<void> show(BuildContext context, WalkRecordEntity walkRecord) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WalkInfoBottomSheet(walkRecord: walkRecord),
    );
  }

  /// 활동 데이터 파싱
  List<Map<String, dynamic>> _parseActivities() {
    if (walkRecord.notes == null || walkRecord.notes!.isEmpty) {
      return [];
    }

    try {
      final notesStr = walkRecord.notes!;
      if (notesStr.startsWith('activities:')) {
        final activitiesStr = notesStr.replaceFirst('activities:', '');

        LoggerService.debug('📝 활동 파싱 시도: $activitiesStr');

        // 더 간단한 파싱 방식 사용
        final activities = <Map<String, dynamic>>[];
        final regExp = RegExp(r"'type':\s*'(\w+)'.*?'latitude':\s*([\d.]+).*?'longitude':\s*([\d.]+)");
        final matches = regExp.allMatches(activitiesStr);

        for (final match in matches) {
          activities.add({
            'type': match.group(1),
            'latitude': double.parse(match.group(2)!),
            'longitude': double.parse(match.group(3)!),
            'timestamp': DateTime.now().toIso8601String(),
          });
        }

        return activities;
      }
    } catch (e) {
      LoggerService.debug('❌ 활동 파싱 오류: $e');
    }

    return [];
  }

  /// 활동 타입 라벨
  String _getActivityLabel(String type) {
    switch (type.toLowerCase()) {
      case 'poop':
        return '배변 💩';
      case 'pee':
      case 'marking':
        return '배뇨 (마킹) 💧';
      case 'no-entry':
        return '금지구역 🚫';
      default:
        return type;
    }
  }

  /// 활동 타입 색상
  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'poop':
        return Colors.orange;
      case 'pee':
      case 'marking':
        return Colors.blue;
      case 'no-entry':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 시간 포맷팅 (HH:MM 형식)
  String _formatTime(DateTime dateTime) {
    return DateTimeUtils.formatTime(dateTime);
  }

  /// 시간 문자열 포맷팅
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours時間$minutes分';
    } else {
      return '$minutes分';
    }
  }

  /// 거리 포맷팅
  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(2)}km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activities = _parseActivities();
    final duration = walkRecord.calculatedDuration;
    final distance = walkRecord.calculatedDistance;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들 바 (showHeader가 true일 때만 표시)
          if (showHeader) ...[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 제목
          const Text(
            '산책 정보',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 펫 정보
          Row(
            children: [
              const Icon(Icons.pets, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    walkRecord.petName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    walkRecord.dateString,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 산책 시간 정보
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '시간',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(walkRecord.startTime),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('~', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      walkRecord.endTime != null
                          ? _formatTime(walkRecord.endTime!)
                          : '진행 중',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: walkRecord.endTime == null ? Colors.orange : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 산책 기간 및 거리
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '기간',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '거리',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDistance(distance),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 활동 기록
          if (activities.isNotEmpty) ...[
            Text(
              '활동 기록 (${activities.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final activityType = activity['type'] as String? ?? 'unknown';
                final timestamp = activity['timestamp'] is String
                    ? DateTime.parse(activity['timestamp'] as String)
                    : DateTime.now();
                final latitude = activity['latitude'] as double? ?? 0.0;
                final longitude = activity['longitude'] as double? ?? 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _getActivityColor(activityType).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _getActivityColor(activityType).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: _getActivityIcon(activityType),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getActivityLabel(activityType),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _getActivityColor(activityType),
                                  ),
                                ),
                                Text(
                                  _formatTime(timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '위치: $latitude, $longitude',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '기록된 활동이 없습니다',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
          if (showHeader) ...[
            const SizedBox(height: 20),
            // 닫기 버튼 (모달로 사용될 때만 표시)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 활동 타입에 따른 아이콘 반환
  Widget _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'poop':
        return const Text(
          '💩',
          style: TextStyle(fontSize: 16),
        );
      case 'pee':
      case 'marking':
        return const Icon(
          Icons.water_drop,
          size: 16,
          color: Colors.blue,
        );
      case 'no-entry':
        return const Icon(
          Icons.block,
          size: 16,
          color: Colors.red,
        );
      default:
        return const Icon(
          Icons.info,
          size: 16,
          color: Colors.grey,
        );
    }
  }
}
