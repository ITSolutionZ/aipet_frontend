import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/facility.dart';

class FacilityMapPlaceholder extends StatelessWidget {
  final List<Facility> facilities;
  final Function(Facility) onFacilityTap;

  const FacilityMapPlaceholder({
    super.key,
    required this.facilities,
    required this.onFacilityTap,
  });

  void _showFullScreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenMapDialog(
          facilities: facilities,
          onFacilityTap: onFacilityTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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

            // 시설 마커들
            _buildFacilityMarkers(),

            // 지도 확장 버튼
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: GestureDetector(
                onTap: () => _showFullScreenMap(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pointDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // 시설 개수 표시
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${facilities.length}件の施設',
                  style: AppFonts.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: CustomPaint(
        painter: FacilityMapBackgroundPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildFacilityMarkers() {
    if (facilities.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: facilities.asMap().entries.map((entry) {
            final index = entry.key;
            final facility = entry.value;

            // 시설들을 지도에 분산 배치
            final x = constraints.maxWidth * (0.2 + (index % 3) * 0.3);
            final y = constraints.maxHeight * (0.2 + (index % 2) * 0.4);

            return Positioned(
              left: x,
              top: y,
              child: GestureDetector(
                onTap: () => onFacilityTap(facility),
                child: _buildFacilityMarker(facility),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFacilityMarker(Facility facility) {
    return Column(
      children: [
        // 마커 아이콘
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.pointBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.content_cut, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 2),
        // 거리 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
            '100m',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class FacilityMapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 도로/경로 그리기
    final path = Path();

    // 수평 도로들
    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i * 0.25);
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    }

    // 수직 도로들
    for (int i = 1; i <= 2; i++) {
      final x = size.width * (i * 0.33);
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
      Rect.fromLTWH(size.width * 0.1, size.height * 0.1, 30, 20),
      Rect.fromLTWH(size.width * 0.6, size.height * 0.3, 35, 25),
      Rect.fromLTWH(size.width * 0.2, size.height * 0.6, 25, 15),
      Rect.fromLTWH(size.width * 0.7, size.height * 0.7, 30, 20),
    ];

    for (final building in buildings) {
      canvas.drawRect(building, buildingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FullScreenMapDialog extends StatelessWidget {
  final List<Facility> facilities;
  final Function(Facility) onFacilityTap;

  const _FullScreenMapDialog({
    required this.facilities,
    required this.onFacilityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '지도 보기',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('現在位置に移動'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Stack(
            children: [
              // 지도 배경 (전체 화면 크기)
              Container(
                decoration: BoxDecoration(color: Colors.grey[100]),
                child: CustomPaint(
                  painter: FacilityMapBackgroundPainter(),
                  size: Size.infinite,
                ),
              ),

              // 시설 마커들 (전체 화면에서 더 크게)
              _buildFullScreenFacilityMarkers(),

              // 줌 컨트롤
              Positioned(
                bottom: 100,
                right: AppSpacing.md,
                child: Column(
                  children: [
                    _buildZoomButton(Icons.add, () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('地図を拡大'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    _buildZoomButton(Icons.remove, () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('地図を縮小'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // 시설 개수 및 정보
              Positioned(
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '近くの施設',
                        style: AppFonts.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '合計 ${facilities.length}件の施設',
                        style: AppFonts.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'マーカーをタップして詳細情報を確認してください',
                        style: AppFonts.bodySmall.copyWith(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenFacilityMarkers() {
    if (facilities.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: facilities.asMap().entries.map((entry) {
            final index = entry.key;
            final facility = entry.value;

            // 전체 화면에서는 더 넓게 분산 배치
            final x = constraints.maxWidth * (0.1 + (index % 4) * 0.25);
            final y = constraints.maxHeight * (0.15 + (index % 3) * 0.3);

            return Positioned(
              left: x,
              top: y,
              child: GestureDetector(
                onTap: () => onFacilityTap(facility),
                child: _buildFullScreenFacilityMarker(facility),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFullScreenFacilityMarker(Facility facility) {
    return Column(
      children: [
        // 큰 마커 아이콘
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: facility.type == FacilityType.hospital
                ? Colors.red
                : AppColors.pointBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            facility.type == FacilityType.hospital
                ? Icons.local_hospital
                : Icons.content_cut,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        // 시설 이름과 거리
        Container(
          constraints: const BoxConstraints(maxWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                facility.name,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${(facility.rating * 20 + 50).toInt()}m',
                style: AppFonts.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.pointDark, size: 24),
      ),
    );
  }
}
