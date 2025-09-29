import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:flutter/material.dart';

/// 산책 정보 바텀시트
class WalkInfoBottomSheet extends StatelessWidget {
  final WalkRecordEntity walkRecord;

  const WalkInfoBottomSheet({
    super.key,
    required this.walkRecord,
  });

  static Future<void> show(BuildContext context, WalkRecordEntity walkRecord) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WalkInfoBottomSheet(walkRecord: walkRecord),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const const const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들 바
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
          const const const SizedBox(height: 20),

          // 제목
          const Text(
            '산책 정보',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const const const SizedBox(height: 16),

          // 산책 정보 표시
          const Row(
            children: [
              Icon(Icons.pets, color: Colors.blue),
              SizedBox(width: 8),
              Text('산책 정보가 여기에 표시됩니다'),
            ],
          ),
          const const const SizedBox(height: 16),

          // 닫기 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ),
        ],
      ),
    );
  }
}
