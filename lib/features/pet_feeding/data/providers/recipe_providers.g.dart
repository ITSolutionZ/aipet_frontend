// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recipeRepositoryHash() => r'f887988c8429acfe52c9373085607b08beb71e51';

/// See also [recipeRepository].
@ProviderFor(recipeRepository)
final recipeRepositoryProvider =
    AutoDisposeProvider<RecipeRepositoryImpl>.internal(
      recipeRepository,
      name: r'recipeRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recipeRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecipeRepositoryRef = AutoDisposeProviderRef<RecipeRepositoryImpl>;
String _$getAllRecipesUseCaseHash() =>
    r'08ec9af84d3ff9c81562035809ccaba817c0eeae';

/// See also [getAllRecipesUseCase].
@ProviderFor(getAllRecipesUseCase)
final getAllRecipesUseCaseProvider =
    AutoDisposeProvider<GetAllRecipesUseCase>.internal(
      getAllRecipesUseCase,
      name: r'getAllRecipesUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getAllRecipesUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetAllRecipesUseCaseRef = AutoDisposeProviderRef<GetAllRecipesUseCase>;
String _$createRecipeUseCaseHash() =>
    r'54538457cffb6ae45bc7338c3a2b9e5c61e6d175';

/// See also [createRecipeUseCase].
@ProviderFor(createRecipeUseCase)
final createRecipeUseCaseProvider =
    AutoDisposeProvider<CreateRecipeUseCase>.internal(
      createRecipeUseCase,
      name: r'createRecipeUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createRecipeUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateRecipeUseCaseRef = AutoDisposeProviderRef<CreateRecipeUseCase>;
String _$deleteRecipeUseCaseHash() =>
    r'601bfeb844853918d4108760e00c8b18bda0e2d4';

/// See also [deleteRecipeUseCase].
@ProviderFor(deleteRecipeUseCase)
final deleteRecipeUseCaseProvider =
    AutoDisposeProvider<DeleteRecipeUseCase>.internal(
      deleteRecipeUseCase,
      name: r'deleteRecipeUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteRecipeUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteRecipeUseCaseRef = AutoDisposeProviderRef<DeleteRecipeUseCase>;
String _$recipeByIdHash() => r'6ca6bfaef6cf73ad3595cc5e9d10d53cd39f0a24';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [recipeById].
@ProviderFor(recipeById)
const recipeByIdProvider = RecipeByIdFamily();

/// See also [recipeById].
class RecipeByIdFamily extends Family<AsyncValue<RecipeEntity?>> {
  /// See also [recipeById].
  const RecipeByIdFamily();

  /// See also [recipeById].
  RecipeByIdProvider call(String id) {
    return RecipeByIdProvider(id);
  }

  @override
  RecipeByIdProvider getProviderOverride(
    covariant RecipeByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recipeByIdProvider';
}

/// See also [recipeById].
class RecipeByIdProvider extends AutoDisposeFutureProvider<RecipeEntity?> {
  /// See also [recipeById].
  RecipeByIdProvider(String id)
    : this._internal(
        (ref) => recipeById(ref as RecipeByIdRef, id),
        from: recipeByIdProvider,
        name: r'recipeByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recipeByIdHash,
        dependencies: RecipeByIdFamily._dependencies,
        allTransitiveDependencies: RecipeByIdFamily._allTransitiveDependencies,
        id: id,
      );

  RecipeByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<RecipeEntity?> Function(RecipeByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecipeByIdProvider._internal(
        (ref) => create(ref as RecipeByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<RecipeEntity?> createElement() {
    return _RecipeByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecipeByIdRef on AutoDisposeFutureProviderRef<RecipeEntity?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _RecipeByIdProviderElement
    extends AutoDisposeFutureProviderElement<RecipeEntity?>
    with RecipeByIdRef {
  _RecipeByIdProviderElement(super.provider);

  @override
  String get id => (origin as RecipeByIdProvider).id;
}

String _$userRecipesHash() => r'4f8e715911e1f06e36a7ac8eba70c92d24141474';

/// See also [userRecipes].
@ProviderFor(userRecipes)
const userRecipesProvider = UserRecipesFamily();

/// See also [userRecipes].
class UserRecipesFamily extends Family<AsyncValue<List<RecipeEntity>>> {
  /// See also [userRecipes].
  const UserRecipesFamily();

  /// See also [userRecipes].
  UserRecipesProvider call(String userId) {
    return UserRecipesProvider(userId);
  }

  @override
  UserRecipesProvider getProviderOverride(
    covariant UserRecipesProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userRecipesProvider';
}

/// See also [userRecipes].
class UserRecipesProvider
    extends AutoDisposeFutureProvider<List<RecipeEntity>> {
  /// See also [userRecipes].
  UserRecipesProvider(String userId)
    : this._internal(
        (ref) => userRecipes(ref as UserRecipesRef, userId),
        from: userRecipesProvider,
        name: r'userRecipesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userRecipesHash,
        dependencies: UserRecipesFamily._dependencies,
        allTransitiveDependencies: UserRecipesFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserRecipesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<List<RecipeEntity>> Function(UserRecipesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserRecipesProvider._internal(
        (ref) => create(ref as UserRecipesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecipeEntity>> createElement() {
    return _UserRecipesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserRecipesProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserRecipesRef on AutoDisposeFutureProviderRef<List<RecipeEntity>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserRecipesProviderElement
    extends AutoDisposeFutureProviderElement<List<RecipeEntity>>
    with UserRecipesRef {
  _UserRecipesProviderElement(super.provider);

  @override
  String get userId => (origin as UserRecipesProvider).userId;
}

String _$searchRecipesHash() => r'5ab3362c5847b2f0b4ea1f45a34ccc8944e33d28';

/// See also [searchRecipes].
@ProviderFor(searchRecipes)
const searchRecipesProvider = SearchRecipesFamily();

/// See also [searchRecipes].
class SearchRecipesFamily extends Family<AsyncValue<List<RecipeEntity>>> {
  /// See also [searchRecipes].
  const SearchRecipesFamily();

  /// See also [searchRecipes].
  SearchRecipesProvider call(String query) {
    return SearchRecipesProvider(query);
  }

  @override
  SearchRecipesProvider getProviderOverride(
    covariant SearchRecipesProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchRecipesProvider';
}

/// See also [searchRecipes].
class SearchRecipesProvider
    extends AutoDisposeFutureProvider<List<RecipeEntity>> {
  /// See also [searchRecipes].
  SearchRecipesProvider(String query)
    : this._internal(
        (ref) => searchRecipes(ref as SearchRecipesRef, query),
        from: searchRecipesProvider,
        name: r'searchRecipesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchRecipesHash,
        dependencies: SearchRecipesFamily._dependencies,
        allTransitiveDependencies:
            SearchRecipesFamily._allTransitiveDependencies,
        query: query,
      );

  SearchRecipesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<RecipeEntity>> Function(SearchRecipesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchRecipesProvider._internal(
        (ref) => create(ref as SearchRecipesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecipeEntity>> createElement() {
    return _SearchRecipesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchRecipesProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchRecipesRef on AutoDisposeFutureProviderRef<List<RecipeEntity>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchRecipesProviderElement
    extends AutoDisposeFutureProviderElement<List<RecipeEntity>>
    with SearchRecipesRef {
  _SearchRecipesProviderElement(super.provider);

  @override
  String get query => (origin as SearchRecipesProvider).query;
}

String _$recipesByDifficultyHash() =>
    r'814d138b6f6ad9261c24d77a60ed591b560394a2';

/// See also [recipesByDifficulty].
@ProviderFor(recipesByDifficulty)
const recipesByDifficultyProvider = RecipesByDifficultyFamily();

/// See also [recipesByDifficulty].
class RecipesByDifficultyFamily extends Family<AsyncValue<List<RecipeEntity>>> {
  /// See also [recipesByDifficulty].
  const RecipesByDifficultyFamily();

  /// See also [recipesByDifficulty].
  RecipesByDifficultyProvider call(String difficulty) {
    return RecipesByDifficultyProvider(difficulty);
  }

  @override
  RecipesByDifficultyProvider getProviderOverride(
    covariant RecipesByDifficultyProvider provider,
  ) {
    return call(provider.difficulty);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recipesByDifficultyProvider';
}

/// See also [recipesByDifficulty].
class RecipesByDifficultyProvider
    extends AutoDisposeFutureProvider<List<RecipeEntity>> {
  /// See also [recipesByDifficulty].
  RecipesByDifficultyProvider(String difficulty)
    : this._internal(
        (ref) => recipesByDifficulty(ref as RecipesByDifficultyRef, difficulty),
        from: recipesByDifficultyProvider,
        name: r'recipesByDifficultyProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recipesByDifficultyHash,
        dependencies: RecipesByDifficultyFamily._dependencies,
        allTransitiveDependencies:
            RecipesByDifficultyFamily._allTransitiveDependencies,
        difficulty: difficulty,
      );

  RecipesByDifficultyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.difficulty,
  }) : super.internal();

  final String difficulty;

  @override
  Override overrideWith(
    FutureOr<List<RecipeEntity>> Function(RecipesByDifficultyRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecipesByDifficultyProvider._internal(
        (ref) => create(ref as RecipesByDifficultyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        difficulty: difficulty,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecipeEntity>> createElement() {
    return _RecipesByDifficultyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipesByDifficultyProvider &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, difficulty.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecipesByDifficultyRef
    on AutoDisposeFutureProviderRef<List<RecipeEntity>> {
  /// The parameter `difficulty` of this provider.
  String get difficulty;
}

class _RecipesByDifficultyProviderElement
    extends AutoDisposeFutureProviderElement<List<RecipeEntity>>
    with RecipesByDifficultyRef {
  _RecipesByDifficultyProviderElement(super.provider);

  @override
  String get difficulty => (origin as RecipesByDifficultyProvider).difficulty;
}

String _$favoriteRecipesHash() => r'f9420faff2223b6bc66ac0fd82b53ef09010a558';

/// See also [favoriteRecipes].
@ProviderFor(favoriteRecipes)
const favoriteRecipesProvider = FavoriteRecipesFamily();

/// See also [favoriteRecipes].
class FavoriteRecipesFamily extends Family<AsyncValue<List<RecipeEntity>>> {
  /// See also [favoriteRecipes].
  const FavoriteRecipesFamily();

  /// See also [favoriteRecipes].
  FavoriteRecipesProvider call(String userId) {
    return FavoriteRecipesProvider(userId);
  }

  @override
  FavoriteRecipesProvider getProviderOverride(
    covariant FavoriteRecipesProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'favoriteRecipesProvider';
}

/// See also [favoriteRecipes].
class FavoriteRecipesProvider
    extends AutoDisposeFutureProvider<List<RecipeEntity>> {
  /// See also [favoriteRecipes].
  FavoriteRecipesProvider(String userId)
    : this._internal(
        (ref) => favoriteRecipes(ref as FavoriteRecipesRef, userId),
        from: favoriteRecipesProvider,
        name: r'favoriteRecipesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$favoriteRecipesHash,
        dependencies: FavoriteRecipesFamily._dependencies,
        allTransitiveDependencies:
            FavoriteRecipesFamily._allTransitiveDependencies,
        userId: userId,
      );

  FavoriteRecipesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<List<RecipeEntity>> Function(FavoriteRecipesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FavoriteRecipesProvider._internal(
        (ref) => create(ref as FavoriteRecipesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecipeEntity>> createElement() {
    return _FavoriteRecipesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FavoriteRecipesProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FavoriteRecipesRef on AutoDisposeFutureProviderRef<List<RecipeEntity>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _FavoriteRecipesProviderElement
    extends AutoDisposeFutureProviderElement<List<RecipeEntity>>
    with FavoriteRecipesRef {
  _FavoriteRecipesProviderElement(super.provider);

  @override
  String get userId => (origin as FavoriteRecipesProvider).userId;
}

String _$topRatedRecipesHash() => r'fec697ac354b696217e24415d51c7746103baa92';

/// See also [topRatedRecipes].
@ProviderFor(topRatedRecipes)
const topRatedRecipesProvider = TopRatedRecipesFamily();

/// See also [topRatedRecipes].
class TopRatedRecipesFamily extends Family<AsyncValue<List<RecipeEntity>>> {
  /// See also [topRatedRecipes].
  const TopRatedRecipesFamily();

  /// See also [topRatedRecipes].
  TopRatedRecipesProvider call({int limit = 5}) {
    return TopRatedRecipesProvider(limit: limit);
  }

  @override
  TopRatedRecipesProvider getProviderOverride(
    covariant TopRatedRecipesProvider provider,
  ) {
    return call(limit: provider.limit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'topRatedRecipesProvider';
}

/// See also [topRatedRecipes].
class TopRatedRecipesProvider
    extends AutoDisposeFutureProvider<List<RecipeEntity>> {
  /// See also [topRatedRecipes].
  TopRatedRecipesProvider({int limit = 5})
    : this._internal(
        (ref) => topRatedRecipes(ref as TopRatedRecipesRef, limit: limit),
        from: topRatedRecipesProvider,
        name: r'topRatedRecipesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$topRatedRecipesHash,
        dependencies: TopRatedRecipesFamily._dependencies,
        allTransitiveDependencies:
            TopRatedRecipesFamily._allTransitiveDependencies,
        limit: limit,
      );

  TopRatedRecipesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<RecipeEntity>> Function(TopRatedRecipesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TopRatedRecipesProvider._internal(
        (ref) => create(ref as TopRatedRecipesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecipeEntity>> createElement() {
    return _TopRatedRecipesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TopRatedRecipesProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TopRatedRecipesRef on AutoDisposeFutureProviderRef<List<RecipeEntity>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _TopRatedRecipesProviderElement
    extends AutoDisposeFutureProviderElement<List<RecipeEntity>>
    with TopRatedRecipesRef {
  _TopRatedRecipesProviderElement(super.provider);

  @override
  int get limit => (origin as TopRatedRecipesProvider).limit;
}

String _$quickRecipesHash() => r'170385cec0259faaa732098260acc1ed8977065c';

/// See also [quickRecipes].
@ProviderFor(quickRecipes)
final quickRecipesProvider =
    AutoDisposeFutureProvider<List<RecipeEntity>>.internal(
      quickRecipes,
      name: r'quickRecipesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$quickRecipesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuickRecipesRef = AutoDisposeFutureProviderRef<List<RecipeEntity>>;
String _$recipesNotifierHash() => r'71fe0be8163bdb838cb623c7fa6f463e27ce5f80';

/// See also [RecipesNotifier].
@ProviderFor(RecipesNotifier)
final recipesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      RecipesNotifier,
      List<RecipeEntity>
    >.internal(
      RecipesNotifier.new,
      name: r'recipesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recipesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RecipesNotifier = AutoDisposeAsyncNotifier<List<RecipeEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
