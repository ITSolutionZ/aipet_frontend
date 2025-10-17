// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_activities_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 펫 액티비티 리포지토리 프로바이더

@ProviderFor(petActivitiesRepository)
const petActivitiesRepositoryProvider = PetActivitiesRepositoryProvider._();

/// 펫 액티비티 리포지토리 프로바이더

final class PetActivitiesRepositoryProvider
    extends
        $FunctionalProvider<
          PetActivitiesRepository,
          PetActivitiesRepository,
          PetActivitiesRepository
        >
    with $Provider<PetActivitiesRepository> {
  /// 펫 액티비티 리포지토리 프로바이더
  const PetActivitiesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petActivitiesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petActivitiesRepositoryHash();

  @$internal
  @override
  $ProviderElement<PetActivitiesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PetActivitiesRepository create(Ref ref) {
    return petActivitiesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PetActivitiesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PetActivitiesRepository>(value),
    );
  }
}

String _$petActivitiesRepositoryHash() =>
    r'ad82a077ed54f958cbd22f99c1c9fc7c4bc801b0';

/// 모든 트릭을 가져오는 프로바이더

@ProviderFor(allTricks)
const allTricksProvider = AllTricksProvider._();

/// 모든 트릭을 가져오는 프로바이더

final class AllTricksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TrickEntity>>,
          List<TrickEntity>,
          FutureOr<List<TrickEntity>>
        >
    with
        $FutureModifier<List<TrickEntity>>,
        $FutureProvider<List<TrickEntity>> {
  /// 모든 트릭을 가져오는 프로바이더
  const AllTricksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTricksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTricksHash();

  @$internal
  @override
  $FutureProviderElement<List<TrickEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TrickEntity>> create(Ref ref) {
    return allTricks(ref);
  }
}

String _$allTricksHash() => r'fc98c31e77c84c10713e19e433ee7ba59a2838c6';

/// 특정 펫의 트릭을 가져오는 프로바이더

@ProviderFor(tricksByPetId)
const tricksByPetIdProvider = TricksByPetIdFamily._();

/// 특정 펫의 트릭을 가져오는 프로바이더

final class TricksByPetIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TrickEntity>>,
          List<TrickEntity>,
          FutureOr<List<TrickEntity>>
        >
    with
        $FutureModifier<List<TrickEntity>>,
        $FutureProvider<List<TrickEntity>> {
  /// 특정 펫의 트릭을 가져오는 프로바이더
  const TricksByPetIdProvider._({
    required TricksByPetIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tricksByPetIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tricksByPetIdHash();

  @override
  String toString() {
    return r'tricksByPetIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TrickEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TrickEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return tricksByPetId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TricksByPetIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tricksByPetIdHash() => r'f618f35f12642f528ce1862ec54546d8b06d9dc9';

/// 특정 펫의 트릭을 가져오는 프로바이더

final class TricksByPetIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TrickEntity>>, String> {
  const TricksByPetIdFamily._()
    : super(
        retry: null,
        name: r'tricksByPetIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 펫의 트릭을 가져오는 프로바이더

  TricksByPetIdProvider call(String petId) =>
      TricksByPetIdProvider._(argument: petId, from: this);

  @override
  String toString() => r'tricksByPetIdProvider';
}

/// YouTube 비디오 유스케이스 프로바이더들

@ProviderFor(registerYouTubeVideoUseCase)
const registerYouTubeVideoUseCaseProvider =
    RegisterYouTubeVideoUseCaseProvider._();

/// YouTube 비디오 유스케이스 프로바이더들

final class RegisterYouTubeVideoUseCaseProvider
    extends
        $FunctionalProvider<
          RegisterYouTubeVideoUseCase,
          RegisterYouTubeVideoUseCase,
          RegisterYouTubeVideoUseCase
        >
    with $Provider<RegisterYouTubeVideoUseCase> {
  /// YouTube 비디오 유스케이스 프로바이더들
  const RegisterYouTubeVideoUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerYouTubeVideoUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerYouTubeVideoUseCaseHash();

  @$internal
  @override
  $ProviderElement<RegisterYouTubeVideoUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RegisterYouTubeVideoUseCase create(Ref ref) {
    return registerYouTubeVideoUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterYouTubeVideoUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterYouTubeVideoUseCase>(value),
    );
  }
}

String _$registerYouTubeVideoUseCaseHash() =>
    r'd6191bc2f3261bcc956de6db1bd97fadbbc9e927';

@ProviderFor(getYouTubeVideosUseCase)
const getYouTubeVideosUseCaseProvider = GetYouTubeVideosUseCaseProvider._();

final class GetYouTubeVideosUseCaseProvider
    extends
        $FunctionalProvider<
          GetYouTubeVideosUseCase,
          GetYouTubeVideosUseCase,
          GetYouTubeVideosUseCase
        >
    with $Provider<GetYouTubeVideosUseCase> {
  const GetYouTubeVideosUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getYouTubeVideosUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getYouTubeVideosUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetYouTubeVideosUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetYouTubeVideosUseCase create(Ref ref) {
    return getYouTubeVideosUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetYouTubeVideosUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetYouTubeVideosUseCase>(value),
    );
  }
}

String _$getYouTubeVideosUseCaseHash() =>
    r'e2edc584a6ee8bb22cbb93548dd3cf1ba24f69fc';

/// YouTube 비디오 목록 프로바이더

@ProviderFor(youTubeVideos)
const youTubeVideosProvider = YouTubeVideosFamily._();

/// YouTube 비디오 목록 프로바이더

final class YouTubeVideosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<YouTubeVideoEntity>>,
          List<YouTubeVideoEntity>,
          FutureOr<List<YouTubeVideoEntity>>
        >
    with
        $FutureModifier<List<YouTubeVideoEntity>>,
        $FutureProvider<List<YouTubeVideoEntity>> {
  /// YouTube 비디오 목록 프로바이더
  const YouTubeVideosProvider._({
    required YouTubeVideosFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'youTubeVideosProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$youTubeVideosHash();

  @override
  String toString() {
    return r'youTubeVideosProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<YouTubeVideoEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<YouTubeVideoEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return youTubeVideos(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YouTubeVideosProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$youTubeVideosHash() => r'09b2f4d7967c458cf7a98a3542d7f175c77c6dca';

/// YouTube 비디오 목록 프로바이더

final class YouTubeVideosFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<YouTubeVideoEntity>>, String> {
  const YouTubeVideosFamily._()
    : super(
        retry: null,
        name: r'youTubeVideosProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// YouTube 비디오 목록 프로바이더

  YouTubeVideosProvider call(String petId) =>
      YouTubeVideosProvider._(argument: petId, from: this);

  @override
  String toString() => r'youTubeVideosProvider';
}
