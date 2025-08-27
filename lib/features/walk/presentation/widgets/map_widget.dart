import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../data/walk_providers.dart';
import '../../domain/entities/walk_record_entity.dart';

class MapWidget extends StatelessWidget {
  final List<WalkRecordEntity> walkRecords;
  final PetInfo? selectedPet;

  const MapWidget({super.key, required this.walkRecords, this.selectedPet});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Stack(
          children: [
            // 지도 배경 (스타일화된 지도)
            _buildMapBackground(),

            // 산책 경로 표시
            _buildWalkRoutes(),

            // 반려동물 위치 마커
            _buildPetMarker(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: CustomPaint(painter: MapBackgroundPainter(), size: Size.infinite),
    );
  }

  Widget _buildWalkRoutes() {
    if (walkRecords.isEmpty) return const SizedBox.shrink();

    return CustomPaint(
      painter: WalkRoutePainter(walkRecords: walkRecords),
      size: Size.infinite,
    );
  }

  Widget _buildPetMarker() {
    if (selectedPet == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Positioned(
          left: constraints.maxWidth * 0.4,
          top: constraints.maxHeight * 0.15,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                selectedPet!.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.pets, color: Colors.grey[600], size: 30),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 도로/경로 그리기
    final path = Path();

    // 수평 도로들
    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i * 0.2);
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    }

    // 수직 도로들
    for (int i = 1; i <= 3; i++) {
      final x = size.width * (i * 0.25);
      path.moveTo(x, 0);
      path.lineTo(x, size.height);
    }

    canvas.drawPath(path, paint);

    // 건물/지역 표시
    final buildingPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    // 몇 개의 건물 표시
    final buildings = [
      Rect.fromLTWH(size.width * 0.1, size.height * 0.1, 40, 30),
      Rect.fromLTWH(size.width * 0.7, size.height * 0.3, 50, 35),
      Rect.fromLTWH(size.width * 0.2, size.height * 0.6, 45, 25),
      Rect.fromLTWH(size.width * 0.6, size.height * 0.7, 35, 40),
    ];

    for (final building in buildings) {
      canvas.drawRect(building, buildingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WalkRoutePainter extends CustomPainter {
  final List<WalkRecordEntity> walkRecords;

  WalkRoutePainter({required this.walkRecords});

  @override
  void paint(Canvas canvas, Size size) {
    if (walkRecords.isEmpty) return;

    // 최근 산책 경로만 표시
    final recentWalk = walkRecords.first;
    if (recentWalk.route.length < 2) return;

    final paint = Paint()
      ..color = AppColors.pointBrown
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // 경로 그리기
    for (int i = 0; i < recentWalk.route.length; i++) {
      final x = size.width * (0.3 + (i * 0.1));
      final y = size.height * (0.4 + (i * 0.05 * (i % 2 == 0 ? 1 : -1)));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    final startX = size.width * 0.3;
    final startY = size.height * 0.4;
    final endX = size.width * (0.3 + (recentWalk.route.length - 1) * 0.1);
    final endY =
        size.height *
        (0.4 +
            (recentWalk.route.length - 1) *
                0.05 *
                ((recentWalk.route.length - 1) % 2 == 0 ? 1 : -1));

    // 시작점 (초록색)
    final startPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(startX, startY), 6, startPaint);

    // 끝점 (빨간색)
    final endPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(endX, endY), 6, endPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
