/// 레시피 도메인 엔티티
class RecipeEntity {
  final String id;
  final String name;
  final String image;
  final String description;
  final String cookingTime;
  final String difficulty;
  final List<String> ingredients;
  final List<String> instructions;
  final int servings;
  final double rating;
  final bool isFavorite;
  final String? userId; // 레시피 작성자 ID
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RecipeEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.cookingTime,
    required this.difficulty,
    this.ingredients = const [],
    this.instructions = const [],
    this.servings = 1,
    this.rating = 0.0,
    this.isFavorite = false,
    this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  /// JSON에서 RecipeEntity 생성
  factory RecipeEntity.fromJson(Map<String, dynamic> json) {
    return RecipeEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      description: json['description'] as String,
      cookingTime: json['cookingTime'] as String,
      difficulty: json['difficulty'] as String,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      servings: json['servings'] as int? ?? 1,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      userId: json['userId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'cookingTime': cookingTime,
      'difficulty': difficulty,
      'ingredients': ingredients,
      'instructions': instructions,
      'servings': servings,
      'rating': rating,
      'isFavorite': isFavorite,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 복사본 생성
  RecipeEntity copyWith({
    String? id,
    String? name,
    String? image,
    String? description,
    String? cookingTime,
    String? difficulty,
    List<String>? ingredients,
    List<String>? instructions,
    int? servings,
    double? rating,
    bool? isFavorite,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      description: description ?? this.description,
      cookingTime: cookingTime ?? this.cookingTime,
      difficulty: difficulty ?? this.difficulty,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      servings: servings ?? this.servings,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RecipeEntity(id: $id, name: $name, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
