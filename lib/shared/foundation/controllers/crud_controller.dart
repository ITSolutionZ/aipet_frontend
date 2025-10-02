import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// CRUD 작업을 위한 공통 컨트롤러
///
/// 모든 CRUD 작업에서 공통으로 사용되는 패턴을 제공합니다.
/// BaseController를 상속받아 에러 처리와 리소스 관리를 자동화합니다.
abstract class CrudController<T> extends BaseController {
  CrudController(super.ref);

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

  /// 안전한 CRUD 작업 실행
  ///
  /// [operation] 실행할 CRUD 작업
  /// [operationName] 작업 이름 (에러 메시지용)
  /// [return] Result<T> 작업 결과
  Future<Result<T>> safeCrudOperation<T>(
    Future<Result<T>> Function() operation,
    String operationName,
  ) async {
    try {
      final result = await operation();
      if (result.isSuccess) {
        return result;
      } else {
        return Result.failure('$operationNameに失敗しました: ${result.message}');
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure('$operationName中にエラーが発生しました: ${getUserFriendlyErrorMessage(error)}');
    }
  }

  /// 안전한 CRUD 작업 실행 (재시도 포함)
  ///
  /// [operation] 실행할 CRUD 작업
  /// [operationName] 작업 이름 (에러 메시지용)
  /// [maxRetries] 최대 재시도 횟수
  /// [return] Result<T> 작업 결과
  Future<Result<T>> safeCrudOperationWithRetry<T>(
    Future<Result<T>> Function() operation,
    String operationName, {
    int maxRetries = 3,
  }) async {
    return safeExecuteWithRetry(
      () async {
        final result = await operation();
        if (result.isSuccess) {
          return result.data as T;
        } else {
          throw Exception(result.message);
        }
      },
      maxRetries: maxRetries,
      errorMessage: operationName,
    ).then((data) {
      if (data != null) {
        return Result.success('$operationNameが完了しました', data);
      } else {
        return Result.failure('$operationNameに失敗しました');
      }
    });
  }
}

/// 펫 관련 CRUD 컨트롤러
///
/// 펫 관리에서 공통으로 사용되는 CRUD 패턴을 제공합니다.
abstract class PetCrudController<T> extends CrudController<T> {
  PetCrudController(super.ref);

  /// 펫 ID로 항목 조회
  Future<Result<List<T>>> getByPetId(String petId);

  /// 펫별 항목 생성
  Future<Result<T>> createForPet(String petId, T item);

  /// 펫별 항목 업데이트
  Future<Result<T>> updateForPet(String petId, T item);

  /// 펫별 항목 삭제
  Future<Result<void>> deleteForPet(String petId, String itemId);
}

/// 사용자 관련 CRUD 컨트롤러
///
/// 사용자 관리에서 공통으로 사용되는 CRUD 패턴을 제공합니다.
abstract class UserCrudController<T> extends CrudController<T> {
  UserCrudController(super.ref);

  /// 사용자 ID로 항목 조회
  Future<Result<List<T>>> getByUserId(String userId);

  /// 사용자별 항목 생성
  Future<Result<T>> createForUser(String userId, T item);

  /// 사용자별 항목 업데이트
  Future<Result<T>> updateForUser(String userId, T item);

  /// 사용자별 항목 삭제
  Future<Result<void>> deleteForUser(String userId, String itemId);
}
