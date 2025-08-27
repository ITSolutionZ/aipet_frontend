import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/walk_record_entity.dart';

class WalkDetailMapWidget extends StatelessWidget {
  final WalkRecordEntity walkRecord;

  const WalkDetailMapWidget({super.key, required this.walkRecord});

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
            // 지도 배경
            _buildMapBackground(),

            // 산책 경로
            _buildWalkRoute(),

            // 위치 핀들
            _buildLocationPins(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: CustomPaint(
        painter: WalkDetailMapBackgroundPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildWalkRoute() {
    if (walkRecord.route.length < 2) return const SizedBox.shrink();

    return CustomPaint(
      painter: WalkDetailRoutePainter(walkRecord: walkRecord),
      size: Size.infinite,
    );
  }

  Widget _buildLocationPins() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 시작점 (공원) - 초록색 핀
            Positioned(
              left: constraints.maxWidth * 0.2,
              top: constraints.maxHeight * 0.15,
              child: _buildLocationPin(
                color: Colors.green,
                icon: Icons.park,
                label: '공원',
              ),
            ),

            // 중간 지점 (병원) - 흰색 핀
            Positioned(
              left: constraints.maxWidth * 0.6,
              top: constraints.maxHeight * 0.4,
              child: _buildLocationPin(
                color: Colors.white,
                icon: Icons.medical_services,
                label: '병원',
                textColor: Colors.blue,
              ),
            ),

            // 끝점 (집) - 파란색 핀
            Positioned(
              left: constraints.maxWidth * 0.7,
              top: constraints.maxHeight * 0.7,
              child: _buildLocationPin(
                color: Colors.blue,
                icon: Icons.home,
                label: '집',
                textColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationPin({
    required Color color,
    required IconData icon,
    required String label,
    Color textColor = Colors.white,
  }) {
    return Column(
      children: [
        // 핀 아이콘
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: textColor, size: 20),
        ),
        const SizedBox(height: 4),
        // 라벨
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class WalkDetailMapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 도로/경로 그리기
    final path = Path();

    // 수평 도로들
    for (int i = 1; i <= 5; i++) {
      final y = size.height * (i * 0.15);
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    }

    // 수직 도로들
    for (int i = 1; i <= 4; i++) {
      final x = size.width * (i * 0.2);
      path.moveTo(x, 0);
      path.lineTo(x, size.height);
    }

    canvas.drawPath(path, paint);

    // 건물/지역 표시
    final buildingPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    // 건물들 표시
    final buildings = [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.05, 60, 40),
      Rect.fromLTWH(size.width * 0.75, size.height * 0.25, 70, 50),
      Rect.fromLTWH(size.width * 0.15, size.height * 0.55, 55, 35),
      Rect.fromLTWH(size.width * 0.65, size.height * 0.65, 45, 45),
      Rect.fromLTWH(size.width * 0.35, size.height * 0.35, 50, 30),
    ];

    for (final building in buildings) {
      canvas.drawRect(building, buildingPaint);
    }

    // 공원 영역 표시 (초록색)
    final parkPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final parkRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.05,
      80,
      60,
    );
    canvas.drawRect(parkRect, parkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WalkDetailRoutePainter extends CustomPainter {
  final WalkRecordEntity walkRecord;

  WalkDetailRoutePainter({required this.walkRecord});

  @override
  void paint(Canvas canvas, Size size) {
    if (walkRecord.route.length < 2) return;

    // 파란색 경로 그리기
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // 실제 경로 대신 이미지와 유사한 경로 그리기
    final points = [
      Offset(size.width * 0.25, size.height * 0.2), // 시작점 (공원)
      Offset(size.width * 0.35, size.height * 0.25),
      Offset(size.width * 0.45, size.height * 0.3),
      Offset(size.width * 0.55, size.height * 0.35),
      Offset(size.width * 0.65, size.height * 0.45), // 중간점 (병원)
      Offset(size.width * 0.7, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.65),
      Offset(size.width * 0.8, size.height * 0.75), // 끝점 (집)
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // 경로 위에 작은 점들 표시
    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
