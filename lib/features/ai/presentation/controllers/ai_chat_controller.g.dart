// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiChatNotifierHash() => r'c75684b6c2345f08efe148d5aa15a3e6d29d0636';

/// 🎯 AI 채팅 상태 프로바이더
///
/// Riverpod을 사용한 AI 채팅 상태 관리 클래스입니다.
///
/// ## 주요 기능
/// - 채팅 메시지 관리 (전송, 저장, 로드)
/// - 펫 선택 및 카테고리 선택 처리
/// - 즐겨찾기 메시지 관리
/// - 채팅 히스토리 저장 및 복원
///
/// ## 상태 관리
/// - 불변성 유지를 위한 copyWith 패턴 사용
/// - 에러 처리 및 로딩 상태 관리
/// - Repository 패턴을 통한 데이터 접근
///
/// Copied from [AiChatNotifier].
@ProviderFor(AiChatNotifier)
final aiChatNotifierProvider =
    AutoDisposeNotifierProvider<AiChatNotifier, AiChatState>.internal(
      AiChatNotifier.new,
      name: r'aiChatNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$aiChatNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AiChatNotifier = AutoDisposeNotifier<AiChatState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
