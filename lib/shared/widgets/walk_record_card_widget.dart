import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:flutter/material.dart';

/// 산책 기록 카드 위젯
class WalkRecordCardWidget extends StatelessWidget {
  final WalkRecordEntity walkRecord;
  final VoidCallback? onTap;

  const WalkRecordCardWidget({
    super.key,
    required this.walkRecord,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 산책 기록 헤더
              Row(
                children: [
                  const Icon(
                    Icons.pets,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '산책 기록',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 산책 정보
              const Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '시간 정보가 여기에 표시됩니다',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.route, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '경로 정보가 여기에 표시됩니다',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}