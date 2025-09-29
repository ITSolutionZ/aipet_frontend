import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 산책 공유 결과 타입
typedef WalkShareResult = Result<void>;

/// 산책 공유 리포지토리 인터페이스
abstract class WalkShareRepository {
  /// 클립보드에 복사
  Future<WalkShareResult> copyToClipboard(String text);

  /// 이미지로 저장
  Future<WalkShareResult> saveAsImage(WalkRecordEntity walkRecord);

  /// 시스템 공유
  Future<WalkShareResult> systemShare(String text, {String? subject});

  /// 공유 텍스트 생성
  String generateShareText(WalkRecordEntity walkRecord);
}