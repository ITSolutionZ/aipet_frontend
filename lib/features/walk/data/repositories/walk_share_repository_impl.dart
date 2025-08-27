import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/walk_record_entity.dart';
import '../../domain/repositories/walk_share_repository.dart';

/// 산책 기록 공유 리포지토리 구현체
class WalkShareRepositoryImpl implements WalkShareRepository {
  @override
  Future<WalkShareResult> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return WalkShareResult.success('텍스트가 클립보드에 복사되었습니다');
    } catch (e) {
      if (kDebugMode) {
        print('클립보드 복사 실패: $e');
      }
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

      // TODO: 추후 API 연동 시 실제 이미지 생성 로직으로 교체
      // 현재는 텍스트 파일로 저장하여 파일 시스템 접근 확인

      return WalkShareResult.success('산책 기록이 저장되었습니다', imagePath: file.path);
    } catch (e) {
      if (kDebugMode) {
        print('이미지 저장 실패: $e');
      }
      return WalkShareResult.failure('이미지 저장에 실패했습니다');
    }
  }

  @override
  Future<WalkShareResult> systemShare(String text, {String? subject}) async {
    try {
      await Share.share(text, subject: subject ?? 'AI Pet 산책 기록');
      return WalkShareResult.success('시스템 공유가 실행되었습니다');
    } catch (e) {
      if (kDebugMode) {
        print('시스템 공유 실패: $e');
      }
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
      case WalkStatus.completed:
        return '完了';
      case WalkStatus.paused:
        return '一時停止';
      case WalkStatus.cancelled:
        return 'キャンセル';
    }
  }
}
