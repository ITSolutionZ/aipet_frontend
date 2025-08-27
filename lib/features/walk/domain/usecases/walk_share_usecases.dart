import '../entities/walk_record_entity.dart';
import '../repositories/walk_share_repository.dart';

/// 클립보드 복사 UseCase
class CopyToClipboardUseCase {
  final WalkShareRepository _repository;

  CopyToClipboardUseCase(this._repository);

  Future<WalkShareResult> call(String text) async {
    return _repository.copyToClipboard(text);
  }
}

/// 이미지 저장 UseCase
class SaveAsImageUseCase {
  final WalkShareRepository _repository;

  SaveAsImageUseCase(this._repository);

  Future<WalkShareResult> call(WalkRecordEntity walkRecord) async {
    return _repository.saveAsImage(walkRecord);
  }
}

/// 시스템 공유 UseCase
class SystemShareUseCase {
  final WalkShareRepository _repository;

  SystemShareUseCase(this._repository);

  Future<WalkShareResult> call(String text, {String? subject}) async {
    return _repository.systemShare(text, subject: subject);
  }
}

/// 공유 텍스트 생성 UseCase
class GenerateShareTextUseCase {
  final WalkShareRepository _repository;

  GenerateShareTextUseCase(this._repository);

  String call(WalkRecordEntity walkRecord) {
    return _repository.generateShareText(walkRecord);
  }
}
