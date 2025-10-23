import 'package:dio/dio.dart';
import '../domain/result.dart';
import '../api/api_client.dart';
import '../api/api_error_handler.dart';
import 'base_data_source.dart';
import 'result_types.dart';

abstract class BaseRemoteDataSource<T> implements RemoteDataSource<T> {
  final ApiClient apiClient;

  BaseRemoteDataSource(this.apiClient);

  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T data);

  @override
  Future<ResultState<T>> fetchData(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        return Result.failure(
          ApiErrorHandler.handleError(
            DioException(
              requestOptions: response.requestOptions,
              message: 'Empty response data',
            ),
          ),
        );
      }

      final data = fromJson(response.data!);
      return Success(data);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<ResultState<List<T>>> fetchList(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        return Result.failure(
          ApiErrorHandler.handleError(
            DioException(
              requestOptions: response.requestOptions,
              message: 'Empty response data',
            ),
          ),
        );
      }

      final List<dynamic> dataList =
          response.data!['data'] ?? response.data!['items'] ?? [];
      final result = dataList
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(result);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<ResultState<T>> createData(String endpoint, T data) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        endpoint,
        data: toJson(data),
      );

      if (response.data == null) {
        return Result.failure(
          ApiErrorHandler.handleError(
            DioException(
              requestOptions: response.requestOptions,
              message: 'Empty response data',
            ),
          ),
        );
      }

      final responseData = response.data!['data'] ?? response.data!;
      final result = fromJson(responseData as Map<String, dynamic>);
      return Success(result);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<ResultState<T>> updateData(String endpoint, String id, T data) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>(
        '$endpoint/$id',
        data: toJson(data),
      );

      if (response.data == null) {
        return Result.failure(
          ApiErrorHandler.handleError(
            DioException(
              requestOptions: response.requestOptions,
              message: 'Empty response data',
            ),
          ),
        );
      }

      final responseData = response.data!['data'] ?? response.data!;
      final result = fromJson(responseData as Map<String, dynamic>);
      return Success(result);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<ResultState<void>> deleteData(String endpoint, String id) async {
    try {
      await apiClient.delete('$endpoint/$id');
      return const Success(null);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<Map<String, dynamic>>> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final formData = FormData();

      formData.files.add(
        MapEntry(fieldName, await MultipartFile.fromFile(filePath)),
      );

      if (additionalData != null) {
        additionalData.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await apiClient.post<Map<String, dynamic>>(
        endpoint,
        data: formData,
      );

      if (response.data == null) {
        return Result.failure(
          ApiErrorHandler.handleError(
            DioException(
              requestOptions: response.requestOptions,
              message: 'Empty response data',
            ),
          ),
        );
      }

      return Success(response.data!);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<List<T>>> fetchPaginatedList(
    String endpoint, {
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
        ...?queryParameters,
      };

      final response = await apiClient.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: params,
      );

      if (response.data == null) {
        return Result.failure(
          ApiErrorHandler.handleError(
            DioException(
              requestOptions: response.requestOptions,
              message: 'Empty response data',
            ),
          ),
        );
      }

      final List<dynamic> dataList =
          response.data!['data'] ?? response.data!['items'] ?? [];
      final result = dataList
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(result);
    } catch (e) {
      return Result.failure(ApiErrorHandler.handleError(e));
    }
  }
}
