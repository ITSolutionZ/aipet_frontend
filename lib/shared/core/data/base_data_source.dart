import 'result_types.dart';

abstract class LocalDataSource<T> {
  Future<ResultState<T?>> getCachedData(String key);
  Future<ResultState<List<T>>> getCachedList(String key);
  Future<ResultState<void>> saveData(String key, T data);
  Future<ResultState<void>> saveList(String key, List<T> data);
  Future<ResultState<void>> clearCache(String key);
  Future<ResultState<void>> clearAllCache();
  Future<ResultState<bool>> hasCache(String key);
}

abstract class RemoteDataSource<T> {
  Future<ResultState<T>> fetchData(String endpoint, {Map<String, dynamic>? queryParameters});
  Future<ResultState<List<T>>> fetchList(String endpoint, {Map<String, dynamic>? queryParameters});
  Future<ResultState<T>> createData(String endpoint, T data);
  Future<ResultState<T>> updateData(String endpoint, String id, T data);
  Future<ResultState<void>> deleteData(String endpoint, String id);
}

abstract class HybridRepository<T> {
  Future<ResultState<T?>> getData(String key, String endpoint, {Map<String, dynamic>? queryParameters});
  Future<ResultState<List<T>>> getList(String key, String endpoint, {Map<String, dynamic>? queryParameters});
  Future<ResultState<T>> createData(String endpoint, T data, {String? cacheKey});
  Future<ResultState<T>> updateData(String endpoint, String id, T data, {String? cacheKey});
  Future<ResultState<void>> deleteData(String endpoint, String id, {String? cacheKey});
  Future<ResultState<void>> sync();
  Future<ResultState<void>> clearCache();
}