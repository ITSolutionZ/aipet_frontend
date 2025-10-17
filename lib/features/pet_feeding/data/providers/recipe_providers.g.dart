// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recipeRepository)
const recipeRepositoryProvider = RecipeRepositoryProvider._();

final class RecipeRepositoryProvider
    extends
        $FunctionalProvider<
          RecipeRepositoryImpl,
          RecipeRepositoryImpl,
          RecipeRepositoryImpl
        >
    with $Provider<RecipeRepositoryImpl> {
  const RecipeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipeRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecipeRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecipeRepositoryImpl create(Ref ref) {
    return recipeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecipeRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecipeRepositoryImpl>(value),
    );
  }
}

String _$recipeRepositoryHash() => r'f887988c8429acfe52c9373085607b08beb71e51';

@ProviderFor(getAllRecipesUseCase)
const getAllRecipesUseCaseProvider = GetAllRecipesUseCaseProvider._();

final class GetAllRecipesUseCaseProvider
    extends
        $FunctionalProvider<
          GetAllRecipesUseCase,
          GetAllRecipesUseCase,
          GetAllRecipesUseCase
        >
    with $Provider<GetAllRecipesUseCase> {
  const GetAllRecipesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllRecipesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllRecipesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetAllRecipesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetAllRecipesUseCase create(Ref ref) {
    return getAllRecipesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllRecipesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllRecipesUseCase>(value),
    );
  }
}

String _$getAllRecipesUseCaseHash() =>
    r'08ec9af84d3ff9c81562035809ccaba817c0eeae';

@ProviderFor(createRecipeUseCase)
const createRecipeUseCaseProvider = CreateRecipeUseCaseProvider._();

final class CreateRecipeUseCaseProvider
    extends
        $FunctionalProvider<
          CreateRecipeUseCase,
          CreateRecipeUseCase,
          CreateRecipeUseCase
        >
    with $Provider<CreateRecipeUseCase> {
  const CreateRecipeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createRecipeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createRecipeUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateRecipeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateRecipeUseCase create(Ref ref) {
    return createRecipeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateRecipeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateRecipeUseCase>(value),
    );
  }
}

String _$createRecipeUseCaseHash() =>
    r'54538457cffb6ae45bc7338c3a2b9e5c61e6d175';

@ProviderFor(deleteRecipeUseCase)
const deleteRecipeUseCaseProvider = DeleteRecipeUseCaseProvider._();

final class DeleteRecipeUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteRecipeUseCase,
          DeleteRecipeUseCase,
          DeleteRecipeUseCase
        >
    with $Provider<DeleteRecipeUseCase> {
  const DeleteRecipeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteRecipeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteRecipeUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteRecipeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteRecipeUseCase create(Ref ref) {
    return deleteRecipeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteRecipeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteRecipeUseCase>(value),
    );
  }
}

String _$deleteRecipeUseCaseHash() =>
    r'601bfeb844853918d4108760e00c8b18bda0e2d4';

@ProviderFor(RecipesNotifier)
const recipesProvider = RecipesNotifierProvider._();

final class RecipesNotifierProvider
    extends $AsyncNotifierProvider<RecipesNotifier, List<RecipeEntity>> {
  const RecipesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipesNotifierHash();

  @$internal
  @override
  RecipesNotifier create() => RecipesNotifier();
}

String _$recipesNotifierHash() => r'6ed41f4fc6a72280c689995fafa91d8ad4780099';

abstract class _$RecipesNotifier extends $AsyncNotifier<List<RecipeEntity>> {
  FutureOr<List<RecipeEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<RecipeEntity>>, List<RecipeEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<RecipeEntity>>, List<RecipeEntity>>,
              AsyncValue<List<RecipeEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(recipeById)
const recipeByIdProvider = RecipeByIdFamily._();

final class RecipeByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<RecipeEntity?>,
          RecipeEntity?,
          FutureOr<RecipeEntity?>
        >
    with $FutureModifier<RecipeEntity?>, $FutureProvider<RecipeEntity?> {
  const RecipeByIdProvider._({
    required RecipeByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recipeByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipeByIdHash();

  @override
  String toString() {
    return r'recipeByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RecipeEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RecipeEntity?> create(Ref ref) {
    final argument = this.argument as String;
    return recipeById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipeByIdHash() => r'6ca6bfaef6cf73ad3595cc5e9d10d53cd39f0a24';

final class RecipeByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RecipeEntity?>, String> {
  const RecipeByIdFamily._()
    : super(
        retry: null,
        name: r'recipeByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecipeByIdProvider call(String id) =>
      RecipeByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'recipeByIdProvider';
}

@ProviderFor(userRecipes)
const userRecipesProvider = UserRecipesFamily._();

final class UserRecipesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeEntity>>,
          List<RecipeEntity>,
          FutureOr<List<RecipeEntity>>
        >
    with
        $FutureModifier<List<RecipeEntity>>,
        $FutureProvider<List<RecipeEntity>> {
  const UserRecipesProvider._({
    required UserRecipesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userRecipesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userRecipesHash();

  @override
  String toString() {
    return r'userRecipesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RecipeEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RecipeEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return userRecipes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserRecipesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userRecipesHash() => r'4f8e715911e1f06e36a7ac8eba70c92d24141474';

final class UserRecipesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RecipeEntity>>, String> {
  const UserRecipesFamily._()
    : super(
        retry: null,
        name: r'userRecipesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserRecipesProvider call(String userId) =>
      UserRecipesProvider._(argument: userId, from: this);

  @override
  String toString() => r'userRecipesProvider';
}

@ProviderFor(searchRecipes)
const searchRecipesProvider = SearchRecipesFamily._();

final class SearchRecipesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeEntity>>,
          List<RecipeEntity>,
          FutureOr<List<RecipeEntity>>
        >
    with
        $FutureModifier<List<RecipeEntity>>,
        $FutureProvider<List<RecipeEntity>> {
  const SearchRecipesProvider._({
    required SearchRecipesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchRecipesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchRecipesHash();

  @override
  String toString() {
    return r'searchRecipesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RecipeEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RecipeEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return searchRecipes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchRecipesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchRecipesHash() => r'5ab3362c5847b2f0b4ea1f45a34ccc8944e33d28';

final class SearchRecipesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RecipeEntity>>, String> {
  const SearchRecipesFamily._()
    : super(
        retry: null,
        name: r'searchRecipesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchRecipesProvider call(String query) =>
      SearchRecipesProvider._(argument: query, from: this);

  @override
  String toString() => r'searchRecipesProvider';
}

@ProviderFor(recipesByDifficulty)
const recipesByDifficultyProvider = RecipesByDifficultyFamily._();

final class RecipesByDifficultyProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeEntity>>,
          List<RecipeEntity>,
          FutureOr<List<RecipeEntity>>
        >
    with
        $FutureModifier<List<RecipeEntity>>,
        $FutureProvider<List<RecipeEntity>> {
  const RecipesByDifficultyProvider._({
    required RecipesByDifficultyFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recipesByDifficultyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipesByDifficultyHash();

  @override
  String toString() {
    return r'recipesByDifficultyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RecipeEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RecipeEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return recipesByDifficulty(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipesByDifficultyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipesByDifficultyHash() =>
    r'814d138b6f6ad9261c24d77a60ed591b560394a2';

final class RecipesByDifficultyFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RecipeEntity>>, String> {
  const RecipesByDifficultyFamily._()
    : super(
        retry: null,
        name: r'recipesByDifficultyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecipesByDifficultyProvider call(String difficulty) =>
      RecipesByDifficultyProvider._(argument: difficulty, from: this);

  @override
  String toString() => r'recipesByDifficultyProvider';
}

@ProviderFor(favoriteRecipes)
const favoriteRecipesProvider = FavoriteRecipesFamily._();

final class FavoriteRecipesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeEntity>>,
          List<RecipeEntity>,
          FutureOr<List<RecipeEntity>>
        >
    with
        $FutureModifier<List<RecipeEntity>>,
        $FutureProvider<List<RecipeEntity>> {
  const FavoriteRecipesProvider._({
    required FavoriteRecipesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'favoriteRecipesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$favoriteRecipesHash();

  @override
  String toString() {
    return r'favoriteRecipesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RecipeEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RecipeEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return favoriteRecipes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FavoriteRecipesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$favoriteRecipesHash() => r'f9420faff2223b6bc66ac0fd82b53ef09010a558';

final class FavoriteRecipesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RecipeEntity>>, String> {
  const FavoriteRecipesFamily._()
    : super(
        retry: null,
        name: r'favoriteRecipesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FavoriteRecipesProvider call(String userId) =>
      FavoriteRecipesProvider._(argument: userId, from: this);

  @override
  String toString() => r'favoriteRecipesProvider';
}

@ProviderFor(topRatedRecipes)
const topRatedRecipesProvider = TopRatedRecipesFamily._();

final class TopRatedRecipesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeEntity>>,
          List<RecipeEntity>,
          FutureOr<List<RecipeEntity>>
        >
    with
        $FutureModifier<List<RecipeEntity>>,
        $FutureProvider<List<RecipeEntity>> {
  const TopRatedRecipesProvider._({
    required TopRatedRecipesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'topRatedRecipesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$topRatedRecipesHash();

  @override
  String toString() {
    return r'topRatedRecipesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RecipeEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RecipeEntity>> create(Ref ref) {
    final argument = this.argument as int;
    return topRatedRecipes(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TopRatedRecipesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$topRatedRecipesHash() => r'fec697ac354b696217e24415d51c7746103baa92';

final class TopRatedRecipesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RecipeEntity>>, int> {
  const TopRatedRecipesFamily._()
    : super(
        retry: null,
        name: r'topRatedRecipesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TopRatedRecipesProvider call({int limit = 5}) =>
      TopRatedRecipesProvider._(argument: limit, from: this);

  @override
  String toString() => r'topRatedRecipesProvider';
}

@ProviderFor(quickRecipes)
const quickRecipesProvider = QuickRecipesProvider._();

final class QuickRecipesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeEntity>>,
          List<RecipeEntity>,
          FutureOr<List<RecipeEntity>>
        >
    with
        $FutureModifier<List<RecipeEntity>>,
        $FutureProvider<List<RecipeEntity>> {
  const QuickRecipesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickRecipesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickRecipesHash();

  @$internal
  @override
  $FutureProviderElement<List<RecipeEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RecipeEntity>> create(Ref ref) {
    return quickRecipes(ref);
  }
}

String _$quickRecipesHash() => r'170385cec0259faaa732098260acc1ed8977065c';
