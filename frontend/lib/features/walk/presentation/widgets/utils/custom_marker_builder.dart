import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../shared/shared.dart';

/// 커스텀 마커 빌더
class CustomMarkerBuilder {
  /// 원형 배경 + 아이콘 형태의 마커 생성
  static Future<BitmapDescriptor> createCircleMarker({
    required String iconPath,
    required Color backgroundColor,
    double size = 80,
  }) async {
    try {
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final paint = Paint()..isAntiAlias = true;

      final circleRadius = size / 2;

      // 그림자 그리기
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(
        Offset(circleRadius, circleRadius + 2),
        circleRadius,
        shadowPaint,
      );

      // 원형 배경 그리기
      paint.color = backgroundColor;
      canvas.drawCircle(
        Offset(circleRadius, circleRadius),
        circleRadius,
        paint,
      );

      // 테두리 그리기
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(
        Offset(circleRadius, circleRadius),
        circleRadius - 1.5,
        borderPaint,
      );

      // 아이콘 이미지 로드 (rootBundle 사용)
      final data = await rootBundle.load(iconPath);
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: (size * 0.5).toInt(),
        targetHeight: (size * 0.5).toInt(),
      );
      final frame = await codec.getNextFrame();
      final iconImage = frame.image;

      // 아이콘을 중앙에 그리기
      final iconSize = size * 0.5;
      final iconOffset = (size - iconSize) / 2;

      canvas.drawImageRect(
        iconImage,
        Rect.fromLTWH(
          0,
          0,
          iconImage.width.toDouble(),
          iconImage.height.toDouble(),
        ),
        Rect.fromLTWH(iconOffset, iconOffset, iconSize, iconSize),
        Paint(),
      );

      // 이미지로 변환
      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      return BitmapDescriptor.bytes(pngBytes);
    } catch (e) {
      LoggerService.debug('⚠️ CustomMarker 생성 실패: $e');
      // 폴백: 기본 마커
      return BitmapDescriptor.defaultMarker;
    }
  }

  /// Widget을 BitmapDescriptor로 변환
  static Future<BitmapDescriptor> createFromWidget(
    Widget widget, {
    Size size = const Size(100, 100),
  }) async {
    final repaintBoundary = RenderRepaintBoundary();
    final renderView = RenderView(
      view: WidgetsBinding.instance.platformDispatcher.views.first,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first,
      ),
    );

    final pipelineOwner = PipelineOwner()..rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(textDirection: TextDirection.ltr, child: widget),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(pngBytes);
  }
}
