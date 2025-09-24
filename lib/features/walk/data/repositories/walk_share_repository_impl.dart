import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aipet_frontend/features/onboarding/domain/repositories/walk_share_repository.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 산책 기록 공유 리포지토리 구현체
class WalkShareRepositoryImpl implements WalkShareRepository {
  @override
  Future<WalkShareResult> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return WalkShareResult.success('텍스트가 클립보드에 복사되었습니다');
    } catch (e) {
      if (kDebugMode) {}
      return WalkShareResult.failure('클립보드 복사에 실패했습니다');
    }
  }

  @override
  Future<WalkShareResult> saveAsImage(WalkRecordEntity walkRecord) async {
    try {
      // 저장할 디렉토리 가져오기
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/walk_images');

      // 디렉토리가 없으면 생성
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // 파일명 생성
      final fileName =
          'walk_${walkRecord.id}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${imagesDir.path}/$fileName');

      // 산책 기록 정보를 텍스트 파일로 저장 (임시 구현)
      final content = _generateWalkRecordContent(walkRecord);
      await file.writeAsString(content, encoding: const Utf8Codec());

      // 실제 이미지 생성 및 저장
      final imagePath = await _generateWalkRecordImage(
        walkRecord,
        imagesDir.path,
      );

      return WalkShareResult.success(
        '산책 기록 이미지가 생성되었습니다',
        imagePath: imagePath,
      );
    } catch (e) {
      if (kDebugMode) {}
      return WalkShareResult.failure('이미지 저장에 실패했습니다');
    }
  }

  @override
  Future<WalkShareResult> systemShare(String text, {String? subject}) async {
    try {
      await Share.share(text, subject: subject ?? 'AI Pet 산책 기록');
      return WalkShareResult.success('시스템 공유가 실행되었습니다');
    } catch (e) {
      if (kDebugMode) {}
      return WalkShareResult.failure('시스템 공유에 실패했습니다');
    }
  }

  @override
  String generateShareText(WalkRecordEntity walkRecord) {
    return '''
🐕 산책 기록 공유

제목: ${walkRecord.title}
날짜: ${walkRecord.timeString}
시간: ${walkRecord.formattedDuration}
거리: ${walkRecord.formattedDistance}

#AIペット #산책기록 #${walkRecord.title}
    '''
        .trim();
  }

  /// 산책 기록 내용 생성
  String _generateWalkRecordContent(WalkRecordEntity walkRecord) {
    return '''
🐕 AI Pet - 산책 기록

제목: ${walkRecord.title}
날짜: ${walkRecord.dateString}
시작 시간: ${walkRecord.timeString}
경과 시간: ${walkRecord.formattedDuration}
거리: ${walkRecord.formattedDistance}
상태: ${_getStatusText(walkRecord.status)}
${walkRecord.notes != null ? '메모: ${walkRecord.notes}' : ''}

#AIペット #산책기록 #${walkRecord.title}
생성일시: ${DateTime.now().toString()}
    '''
        .trim();
  }

  /// 상태 텍스트 변환
  String _getStatusText(WalkStatus status) {
    switch (status) {
      case WalkStatus.inProgress:
        return '散歩中';
      case WalkStatus.paused:
        return '一時停止';
      case WalkStatus.completed:
        return '完了';
      case WalkStatus.cancelled:
        return 'キャンセル';
    }
  }

  /// 산책 기록 이미지 생성
  Future<String> _generateWalkRecordImage(
    WalkRecordEntity walkRecord,
    String directoryPath,
  ) async {
    // 이미지 파일명 생성
    final fileName =
        'walk_${walkRecord.id}_${DateTime.now().millisecondsSinceEpoch}.png';
    final imagePath = '$directoryPath/$fileName';

    // 이미지 생성
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 배경 그리기
    final paint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 600), paint);

    // 제목 그리기
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: '🐕 AI Pet - 산책 기록',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, const Offset(20, 30));

    // 정보 그리기
    final infoTexts = [
      '제목: ${walkRecord.title}',
      '날짜: ${walkRecord.dateString}',
      '시간: ${walkRecord.timeString}',
      '경과: ${walkRecord.formattedDuration}',
      '거리: ${walkRecord.formattedDistance}',
      '상태: ${_getStatusText(walkRecord.status)}',
      if (walkRecord.notes != null) '메모: ${walkRecord.notes}',
    ];

    double yOffset = 80;
    for (final text in infoTexts) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(20, yOffset));
      yOffset += 30;
    }

    // 해시태그 그리기
    final hashtagPainter = TextPainter(
      text: const TextSpan(
        text: '#AIペット #산책기록',
        style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
      ),
      textDirection: TextDirection.ltr,
    );
    hashtagPainter.layout();
    hashtagPainter.paint(canvas, Offset(20, yOffset + 20));

    // 이미지 완성 및 저장
    final picture = recorder.endRecording();
    final image = await picture.toImage(400, 600);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(bytes);

    return imagePath;
  }
}
