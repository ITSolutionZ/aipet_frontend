import 'package:aipet_frontend/features/ai/data/providers/ai_providers.dart';
import 'package:aipet_frontend/features/ai/domain/usecases/usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_usecase_providers.g.dart';

@riverpod
InitializeChatUseCase initializeChatUseCase(InitializeChatUseCaseRef ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return InitializeChatUseCase(repository);
}

@riverpod
SendMessageUseCase sendMessageUseCase(SendMessageUseCaseRef ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return SendMessageUseCase(repository);
}

@riverpod
SelectPetUseCase selectPetUseCase(SelectPetUseCaseRef ref) {
  return const SelectPetUseCase();
}

@riverpod
SelectCategoryUseCase selectCategoryUseCase(SelectCategoryUseCaseRef ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return SelectCategoryUseCase(repository);
}

@riverpod
FavoriteMessageUseCase favoriteMessageUseCase(FavoriteMessageUseCaseRef ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return FavoriteMessageUseCase(repository);
}

@riverpod
SaveChatHistoryUseCase saveChatHistoryUseCase(SaveChatHistoryUseCaseRef ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return SaveChatHistoryUseCase(repository);
}

@riverpod
ClearChatHistoryUseCase clearChatHistoryUseCase(ClearChatHistoryUseCaseRef ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return ClearChatHistoryUseCase(repository);
}

@riverpod
GetChatHistoryUseCase getChatHistoryUseCase(GetChatHistoryUseCaseRef ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return GetChatHistoryUseCase(repository);
}

@riverpod
GetSuggestedQuestionsUseCase getSuggestedQuestionsUseCase(GetSuggestedQuestionsUseCaseRef ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return GetSuggestedQuestionsUseCase(repository);
}

@riverpod
ChatSessionUseCase chatSessionUseCase(ChatSessionUseCaseRef ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return ChatSessionUseCase(repository);
}