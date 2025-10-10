import 'package:flutter_riverpod/flutter_riverpod.dart';

/// YouTube 비디오 폼 상태
class YouTubeFormState {
  final bool isLoading;
  final List<String> tags;
  final String url;
  final String title;
  final String description;
  final String urlError;
  final bool isValid;

  const YouTubeFormState({
    this.isLoading = false,
    this.tags = const [],
    this.url = '',
    this.title = '',
    this.description = '',
    this.urlError = '',
    this.isValid = false,
  });

  YouTubeFormState copyWith({
    bool? isLoading,
    List<String>? tags,
    String? url,
    String? title,
    String? description,
    String? urlError,
    bool? isValid,
  }) {
    return YouTubeFormState(
      isLoading: isLoading ?? this.isLoading,
      tags: tags ?? this.tags,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      urlError: urlError ?? this.urlError,
      isValid: isValid ?? this.isValid,
    );
  }
}

/// YouTube 폼 상태 관리 컨트롤러
class YouTubeFormStateManager extends StateNotifier<YouTubeFormState> {
  YouTubeFormStateManager() : super(const YouTubeFormState());

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// URL 설정 및 검증
  void setUrl(String url) {
    final newState = state.copyWith(url: url);
    final isValidUrl = _validateUrl(url);
    state = newState.copyWith(
      urlError: isValidUrl ? '' : '有効なYouTube URLを入力してください',
      isValid: isValidUrl && _isFormValid(newState),
    );
  }

  /// 제목 설정
  void setTitle(String title) {
    final newState = state.copyWith(title: title);
    state = newState.copyWith(isValid: _isFormValid(newState));
  }

  /// 설명 설정
  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// 태그 추가
  void addTag(String tag) {
    if (tag.isNotEmpty && !state.tags.contains(tag)) {
      final newTags = [...state.tags, tag];
      state = state.copyWith(tags: newTags);
    }
  }

  /// 태그 제거
  void removeTag(String tag) {
    final newTags = state.tags.where((t) => t != tag).toList();
    state = state.copyWith(tags: newTags);
  }

  /// 폼 리셋
  void resetForm() {
    state = const YouTubeFormState();
  }

  /// URL 검증
  bool _validateUrl(String url) {
    if (url.isEmpty) return false;

    final patterns = [
      RegExp(r'^https?://(www\.)?youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'^https?://youtu\.be/([a-zA-Z0-9_-]{11})'),
      RegExp(r'^https?://(www\.)?youtube\.com/embed/([a-zA-Z0-9_-]{11})'),
    ];

    return patterns.any((pattern) => pattern.hasMatch(url));
  }

  /// 폼 유효성 검사
  bool _isFormValid(YouTubeFormState state) {
    return state.url.isNotEmpty &&
        state.title.isNotEmpty &&
        state.urlError.isEmpty;
  }

  /// 폼 데이터 가져오기
  Map<String, dynamic> getFormData() {
    return {
      'url': state.url,
      'title': state.title,
      'description': state.description,
      'tags': state.tags,
    };
  }
}

/// YouTube 폼 상태 프로바이더
final youtubeFormStateProvider =
    StateNotifierProvider<YouTubeFormStateManager, YouTubeFormState>(
      (ref) => YouTubeFormStateManager(),
    );
