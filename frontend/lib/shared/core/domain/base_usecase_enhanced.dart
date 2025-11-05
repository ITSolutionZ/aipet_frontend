import '../../../shared/shared.dart';


/// 향상된 UseCase 기본 클래스
///
/// 모든 UseCase에서 공통으로 사용되는 패턴을 제공합니다.
abstract class BaseUseCase<T, P> {
  /// UseCase 실행
  Future<Result<T>> call(P params);
}

/// 파라미터가 없는 UseCase 기본 클래스
abstract class BaseUseCaseNoParams<T> {
  /// UseCase 실행
  Future<Result<T>> call();
}

/// CRUD UseCase 기본 클래스
abstract class CrudUseCase<T> {
  /// 모든 항목 조회
  Future<Result<List<T>>> getAll();

  /// ID로 항목 조회
  Future<Result<T>> getById(String id);

  /// 항목 생성
  Future<Result<T>> create(T item);

  /// 항목 업데이트
  Future<Result<T>> update(T item);

  /// 항목 삭제
  Future<Result<void>> delete(String id);
}

/// 펫 관련 CRUD UseCase 기본 클래스
abstract class PetCrudUseCase<T> extends CrudUseCase<T> {
  /// 펫 ID로 항목 조회
  Future<Result<List<T>>> getByPetId(String petId);

  /// 펫별 항목 생성
  Future<Result<T>> createForPet(String petId, T item);

  /// 펫별 항목 업데이트
  Future<Result<T>> updateForPet(String petId, T item);

  /// 펫별 항목 삭제
  Future<Result<void>> deleteForPet(String petId, String itemId);
}

/// 사용자 관련 CRUD UseCase 기본 클래스
abstract class UserCrudUseCase<T> extends CrudUseCase<T> {
  /// 사용자 ID로 항목 조회
  Future<Result<List<T>>> getByUserId(String userId);

  /// 사용자별 항목 생성
  Future<Result<T>> createForUser(String userId, T item);

  /// 사용자별 항목 업데이트
  Future<Result<T>> updateForUser(String userId, T item);

  /// 사용자별 항목 삭제
  Future<Result<void>> deleteForUser(String userId, String itemId);
}

/// 검색 UseCase 기본 클래스
abstract class SearchUseCase<T> {
  /// 검색 실행
  Future<Result<List<T>>> search(String query);
}

/// 필터링 UseCase 기본 클래스
abstract class FilterUseCase<T> {
  /// 필터링 실행
  Future<Result<List<T>>> filter(Map<String, dynamic> filters);
}

/// 페이지네이션 UseCase 기본 클래스
abstract class PaginationUseCase<T> {
  /// 페이지별 데이터 조회
  Future<Result<List<T>>> getPage(int page, int limit);
}

/// 통계 UseCase 기본 클래스
abstract class StatisticsUseCase<T> {
  /// 통계 데이터 조회
  Future<Result<T>> getStatistics();
}

/// 분석 UseCase 기본 클래스
abstract class AnalysisUseCase<T> {
  /// 분석 실행
  Future<Result<T>> analyze(Map<String, dynamic> data);
}
