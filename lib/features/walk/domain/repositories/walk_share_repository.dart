import '../entities/walk_record_entity.dart';

/// 산책 기록 공유 결과
class WalkShareResult {
  final bool isSuccess;
  final String message;
  final String? shareUrl;
  final String? imagePath;

  const WalkShareResult._({
    required this.isSuccess,
    required this.message,
    this.shareUrl,
    this.imagePath,
  });

  factory WalkShareResult.success(
    String message, {
    String? shareUrl,
    String? imagePath,
  }) => WalkShareResult._(
    isSuccess: true,
    message: message,
    shareUrl: shareUrl,
    imagePath: imagePath,
  );

  factory WalkShareResult.failure(String message) =>
      WalkShareResult._(isSuccess: false, message: message);
}

/// 산책 기록 공유 리포지토리 인터페이스
abstract class WalkShareRepository {
  /// 텍스트를 클립보드에 복사
  Future<WalkShareResult> copyToClipboard(String text);

  /// 산책 기록을 이미지로 저장
  Future<WalkShareResult> saveAsImage(WalkRecordEntity walkRecord);

  /// 시스템 공유 기능 사용
  Future<WalkShareResult> systemShare(String text, {String? subject});

  /// 공유 텍스트 생성
  String generateShareText(WalkRecordEntity walkRecord);
}
