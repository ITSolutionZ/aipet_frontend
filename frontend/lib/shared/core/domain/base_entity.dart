/// 기본 Entity 인터페이스
abstract class BaseEntity {
  String get id;
  DateTime get createdAt;
  DateTime? get updatedAt;
}

/// Entity 변환을 위한 믹스인
mixin EntityMixin {
  /// JSON으로 변환
  Map<String, dynamic> toJson();

  /// JSON에서 생성
  static T fromJson<T>(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented');
  }

  /// copyWith 메서드 생성 헬퍼
  Map<String, dynamic> toCopyWithMap() {
    return toJson();
  }
}

/// Model 변환을 위한 믹스인
mixin ModelMixin<T> {
  /// Domain Entity로 변환
  T toDomainEntity();

  /// Domain Entity에서 생성
  static T fromDomainEntity<T>(dynamic entity) {
    throw UnimplementedError('fromDomainEntity must be implemented');
  }
}

/// Entity 빌더 패턴
abstract class EntityBuilder<T> {
  T build();
}

/// Entity 복사 빌더
abstract class EntityCopyBuilder<T> {
  T copyWith();
}

/// 공통 Entity 유틸리티
class EntityUtils {
  EntityUtils._();

  /// ID 생성 (UUID 스타일)
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return '${timestamp}_$random';
  }

  /// ID 검증
  static bool isValidId(String id) {
    return id.isNotEmpty && id.length > 3;
  }

  /// 생성일시 설정
  static DateTime getCurrentTimestamp() {
    return DateTime.now();
  }

  /// 업데이트일시 설정
  static DateTime getUpdateTimestamp() {
    return DateTime.now();
  }

  /// Entity 비교
  static bool isEqual<T extends BaseEntity>(T entity1, T entity2) {
    return entity1.id == entity2.id;
  }

  /// Entity 리스트에서 ID로 찾기
  static T? findById<T extends BaseEntity>(List<T> entities, String id) {
    try {
      return entities.firstWhere((entity) => entity.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Entity 리스트에서 ID로 필터링
  static List<T> filterByIds<T extends BaseEntity>(
    List<T> entities,
    List<String> ids,
  ) {
    return entities.where((entity) => ids.contains(entity.id)).toList();
  }

  /// Entity 리스트 정렬 (생성일시 기준)
  static List<T> sortByCreatedAt<T extends BaseEntity>(
    List<T> entities, {
    bool ascending = true,
  }) {
    final sorted = List<T>.from(entities);
    sorted.sort((a, b) {
      final comparison = a.createdAt.compareTo(b.createdAt);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Entity 리스트 정렬 (업데이트일시 기준)
  static List<T> sortByUpdatedAt<T extends BaseEntity>(
    List<T> entities, {
    bool ascending = true,
  }) {
    final sorted = List<T>.from(entities);
    sorted.sort((a, b) {
      final aUpdated = a.updatedAt ?? a.createdAt;
      final bUpdated = b.updatedAt ?? b.createdAt;
      final comparison = aUpdated.compareTo(bUpdated);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Entity 리스트에서 최신 N개 반환
  static List<T> getLatest<T extends BaseEntity>(List<T> entities, int count) {
    final sorted = sortByCreatedAt(entities, ascending: false);
    return sorted.take(count).toList();
  }

  /// Entity 리스트에서 오래된 N개 반환
  static List<T> getOldest<T extends BaseEntity>(List<T> entities, int count) {
    final sorted = sortByCreatedAt(entities, ascending: true);
    return sorted.take(count).toList();
  }

  /// Entity 리스트에서 날짜 범위 필터링
  static List<T> filterByDateRange<T extends BaseEntity>(
    List<T> entities,
    DateTime startDate,
    DateTime endDate,
  ) {
    return entities.where((entity) {
      return entity.createdAt.isAfter(startDate) &&
          entity.createdAt.isBefore(endDate);
    }).toList();
  }

  /// Entity 리스트에서 최근 N일 필터링
  static List<T> filterByRecentDays<T extends BaseEntity>(
    List<T> entities,
    int days,
  ) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return entities
        .where((entity) => entity.createdAt.isAfter(cutoffDate))
        .toList();
  }
}

/// Entity 검증을 위한 믹스인
mixin EntityValidationMixin {
  /// 기본 검증
  bool isValid() {
    return true; // 기본적으로 유효
  }

  /// ID 검증
  bool isValidId(String id) {
    return EntityUtils.isValidId(id);
  }

  /// 필수 필드 검증
  bool hasRequiredFields() {
    return true; // 구현체에서 오버라이드
  }

  /// 비즈니스 규칙 검증
  bool validateBusinessRules() {
    return true; // 구현체에서 오버라이드
  }

  /// 전체 검증
  bool validate() {
    return isValid() && hasRequiredFields() && validateBusinessRules();
  }

  /// 검증 에러 메시지
  List<String> getValidationErrors() {
    final errors = <String>[];

    if (!isValid()) {
      errors.add('Entity is not valid');
    }

    if (!hasRequiredFields()) {
      errors.add('Required fields are missing');
    }

    if (!validateBusinessRules()) {
      errors.add('Business rules validation failed');
    }

    return errors;
  }
}
