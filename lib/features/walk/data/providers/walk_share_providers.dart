import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/walk_record_entity.dart';
import '../../domain/repositories/walk_share_repository.dart';
import '../../domain/usecases/walk_share_usecases.dart';
import '../repositories/walk_share_repository_impl.dart';

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
  final useCase = ref.watch(generateShareTextUseCaseProvider);
  return useCase(walkRecord);
}
