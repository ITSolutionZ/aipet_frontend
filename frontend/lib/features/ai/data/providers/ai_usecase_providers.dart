import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/domain.dart';
import 'ai_providers.dart';


part 'ai_usecase_providers.g.dart';

@riverpod
InitializeChatUseCase initializeChatUseCase(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return InitializeChatUseCase(repository);
}

@riverpod
SendMessageUseCase sendMessageUseCase(Ref ref) {
  final repository = ref.watch(aiChatRepositoryProvider);
  return SendMessageUseCase(repository);
}

@riverpod
SelectPetUseCase selectPetUseCase(Ref ref) {
  return const SelectPetUseCase();
}

@riverpod
SelectCategoryUseCase selectCategoryUseCase(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return SelectCategoryUseCase(repository);
}

@riverpod
FavoriteMessageUseCase favoriteMessageUseCase(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return FavoriteMessageUseCase(repository);
}

@riverpod
SaveChatHistoryUseCase saveChatHistoryUseCase(Ref ref) {
  final repository = ref.watch(aiChatRepositoryProvider);
  return SaveChatHistoryUseCase(repository);
}

@riverpod
ClearChatHistoryUseCase clearChatHistoryUseCase(Ref ref) {
  final repository = ref.watch(aiChatRepositoryProvider);
  return ClearChatHistoryUseCase(repository);
}

@riverpod
GetChatHistoryUseCase getChatHistoryUseCase(Ref ref) {
  final repository = ref.watch(aiChatRepositoryProvider);
  return GetChatHistoryUseCase(repository);
}

@riverpod
GetSuggestedQuestionsUseCase getSuggestedQuestionsUseCase(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return GetSuggestedQuestionsUseCase(repository);
}

@riverpod
ChatSessionUseCase chatSessionUseCase(Ref ref) {
  final repository = ref.watch(aiChatRepositoryProvider);
  return ChatSessionUseCase(repository);
}

@riverpod
LoadChatHistoryUseCase loadChatHistoryUseCase(Ref ref) {
  final repository = ref.watch(aiChatRepositoryProvider);
  return LoadChatHistoryUseCase(repository);
}

@riverpod
AnalyzeMessageUseCase analyzeMessageUseCase(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return AnalyzeMessageUseCase(repository);
}

@riverpod
ToggleFavoriteUseCase toggleFavoriteUseCase(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return ToggleFavoriteUseCase(repository);
}
