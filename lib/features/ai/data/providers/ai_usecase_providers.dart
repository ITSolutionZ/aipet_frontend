import 'package:aipet_frontend/features/ai/data/providers/ai_providers.dart';
import 'package:aipet_frontend/features/ai/domain/usecases/ai_usecases.dart';
import 'package:aipet_frontend/features/ai/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_usecase_providers.g.dart';

@riverpod
InitializeChatUseCase initializeChatUseCase(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return InitializeChatUseCase(repository);
}

@riverpod
SendMessageUseCase sendMessageUseCase(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
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
  final repository = ref.watch(aiRepositoryProvider);
  return SaveChatHistoryUseCase(repository);
}

@riverpod
ClearChatHistoryUseCase clearChatHistoryUseCase(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return ClearChatHistoryUseCase(repository);
}

@riverpod
GetChatHistoryUseCase getChatHistoryUseCase(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return GetChatHistoryUseCase(repository);
}

@riverpod
GetSuggestedQuestionsUseCase getSuggestedQuestionsUseCase(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return GetSuggestedQuestionsUseCase(repository);
}

@riverpod
ChatSessionUseCase chatSessionUseCase(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return ChatSessionUseCase(repository);
}

@riverpod
LoadChatHistoryUseCase loadChatHistoryUseCaseProvider(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return LoadChatHistoryUseCase(repository);
}

@riverpod
AnalyzeMessageUseCase analyzeMessageUseCaseProvider(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return AnalyzeMessageUseCase(repository);
}

@riverpod
ToggleFavoriteUseCase toggleFavoriteUseCaseProvider(Ref ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return ToggleFavoriteUseCase(repository);
}
