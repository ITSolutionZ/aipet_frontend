import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:flutter/material.dart';

/// 산책 상세 지도 위젯
class WalkDetailMapWidget extends StatelessWidget {
  final WalkRecordEntity walkRecord;

  const WalkDetailMapWidget({super.key, required this.walkRecord});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('지도 위젯 구현 예정', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
