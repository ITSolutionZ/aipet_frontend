import 'package:aipet_frontend/features/walk/data/repositories/walk_share_repository_impl.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/domain/repositories/walk_share_repository.dart';
import 'package:aipet_frontend/features/walk/domain/usecases/walk_share_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'walk_share_providers.g.dart';

/// WalkShareRepository 프로바이더
@riverpod
WalkShareRepository walkShareRepository(Ref ref) {
  return WalkShareRepositoryImpl();
}

/// CopyToClipboardUseCase 프로바이더
@riverpod
CopyToClipboardUseCase copyToClipboardUseCase(Ref ref) {
  final repository = ref.watch(walkShareRepositoryProvider);
  return CopyToClipboardUseCase(repository);
}

/// SaveAsImageUseCase 프로바이더
@riverpod
SaveAsImageUseCase saveAsImageUseCase(Ref ref) {
  final repository = ref.watch(walkShareRepositoryProvider);
  return SaveAsImageUseCase(repository);
}

/// SystemShareUseCase 프로바이더
@riverpod
SystemShareUseCase systemShareUseCase(Ref ref) {
  final repository = ref.watch(walkShareRepositoryProvider);
  return SystemShareUseCase(repository);
}

/// GenerateShareTextUseCase 프로바이더
@riverpod
GenerateShareTextUseCase generateShareTextUseCase(Ref ref) {
  final repository = ref.watch(walkShareRepositoryProvider);
  return GenerateShareTextUseCase(repository);
}

/// 공유 텍스트 프로바이더
@riverpod
String shareText(Ref ref, WalkRecordEntity walkRecord) {
  // 기본 공유 텍스트 생성
  return '${walkRecord.petName}와 함께한 산책\n'
      '시간: ${walkRecord.formattedDuration}\n'
      '거리: ${walkRecord.formattedDistance}\n'
      '날짜: ${walkRecord.dateString}';
}
