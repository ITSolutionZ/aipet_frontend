import '../domain/common_errors.dart';
import 'base_data_source.dart';
import 'result_types.dart';

abstract class BaseHybridRepository<T> implements HybridRepository<T> {
  final LocalDataSource<T> localDataSource;
  final RemoteDataSource<T> remoteDataSource;

  BaseHybridRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<ResultState<T?>> getData(
    String key,
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final cachedResult = await localDataSource.getCachedData(key);

      if (cachedResult.isSuccess && cachedResult.dataOrNull != null) {
        _refreshDataInBackground(key, endpoint, queryParameters);
        return cachedResult;
      }

      final remoteResult = await remoteDataSource.fetchData(
        endpoint,
        queryParameters: queryParameters,
      );

      if (remoteResult.isSuccess) {
        await localDataSource.saveData(key, remoteResult.dataOrNull as T);
        return Success(remoteResult.dataOrNull);
      }

      if (cachedResult.isSuccess && cachedResult.dataOrNull != null) {
        return cachedResult;
      }

      return Failure(
        remoteResult.errorOrNull ?? NetworkError(details: 'No data available'),
      );
    } catch (e) {
      return Failure(UnknownError(details: e.toString()));
    }
  }

  @override
  Future<ResultState<List<T>>> getList(
    String key,
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final cachedResult = await localDataSource.getCachedList(key);

      if (cachedResult.isSuccess &&
          cachedResult.dataOrNull?.isNotEmpty == true) {
        _refreshListInBackground(key, endpoint, queryParameters);
        return cachedResult;
      }

      final remoteResult = await remoteDataSource.fetchList(
        endpoint,
        queryParameters: queryParameters,
      );

      if (remoteResult.isSuccess) {
        await localDataSource.saveList(key, remoteResult.dataOrNull!);
        return Success(remoteResult.dataOrNull!);
      }

      if (cachedResult.isSuccess &&
          cachedResult.dataOrNull?.isNotEmpty == true) {
        return cachedResult;
      }

      return Failure(
        remoteResult.errorOrNull ?? NetworkError(details: 'No data available'),
      );
    } catch (e) {
      return Failure(UnknownError(details: e.toString()));
    }
  }

  @override
  Future<ResultState<T>> createData(
    String endpoint,
    T data, {
    String? cacheKey,
  }) async {
    try {
      final remoteResult = await remoteDataSource.createData(endpoint, data);

      if (remoteResult.isSuccess) {
        if (cacheKey != null) {
          await localDataSource.saveData(
            cacheKey,
            remoteResult.dataOrNull as T,
          );
        }
        return Success(remoteResult.dataOrNull as T);
      }

      return Failure(
        remoteResult.errorOrNull ??
            UnknownError(details: 'Create operation failed'),
      );
    } catch (e) {
      return Failure(UnknownError(details: e.toString()));
    }
  }

  @override
  Future<ResultState<T>> updateData(
    String endpoint,
    String id,
    T data, {
    String? cacheKey,
  }) async {
    try {
      final remoteResult = await remoteDataSource.updateData(
        endpoint,
        id,
        data,
      );

      if (remoteResult.isSuccess) {
        if (cacheKey != null) {
          await localDataSource.saveData(
            cacheKey,
            remoteResult.dataOrNull as T,
          );
        }
        return Success(remoteResult.dataOrNull as T);
      }

      return Failure(
        remoteResult.errorOrNull ??
            UnknownError(details: 'Update operation failed'),
      );
    } catch (e) {
      return Failure(UnknownError(details: e.toString()));
    }
  }

  @override
  Future<ResultState<void>> deleteData(
    String endpoint,
    String id, {
    String? cacheKey,
  }) async {
    try {
      final remoteResult = await remoteDataSource.deleteData(endpoint, id);

      if (remoteResult.isSuccess) {
        if (cacheKey != null) {
          await localDataSource.clearCache(cacheKey);
        }
        return const Success(null);
      }

      return Failure(
        remoteResult.errorOrNull ??
            UnknownError(details: 'Delete operation failed'),
      );
    } catch (e) {
      return Failure(UnknownError(details: e.toString()));
    }
  }

  @override
  Future<ResultState<void>> sync() async {
    try {
      return const Success(null);
    } catch (e) {
      return Failure(UnknownError(details: e.toString()));
    }
  }

  @override
  Future<ResultState<void>> clearCache() async {
    try {
      final result = await localDataSource.clearAllCache();
      if (result.isSuccess) {
        return const Success(null);
      }
      return Failure(
        result.errorOrNull ?? UnknownError(details: 'Cache clear failed'),
      );
    } catch (e) {
      return Failure(UnknownError(details: e.toString()));
    }
  }

  void _refreshDataInBackground(
    String key,
    String endpoint,
    Map<String, dynamic>? queryParameters,
  ) {
    remoteDataSource
        .fetchData(endpoint, queryParameters: queryParameters)
        .then((result) {
          if (result.isSuccess) {
            localDataSource.saveData(key, result.dataOrNull as T);
          }
        })
        .catchError((error) {});
  }

  void _refreshListInBackground(
    String key,
    String endpoint,
    Map<String, dynamic>? queryParameters,
  ) {
    remoteDataSource
        .fetchList(endpoint, queryParameters: queryParameters)
        .then((result) {
          if (result.isSuccess) {
            localDataSource.saveList(key, result.dataOrNull!);
          }
        })
        .catchError((error) {});
  }

  bool _isCacheValid(ResultState<T?> cachedResult) {
    return cachedResult.isSuccess && cachedResult.dataOrNull != null;
  }

  bool _isListCacheValid(ResultState<List<T>> cachedResult) {
    return cachedResult.isSuccess &&
        cachedResult.dataOrNull?.isNotEmpty == true;
  }
}
