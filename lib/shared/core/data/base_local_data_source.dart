import 'dart:convert';
import '../domain/result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/common_errors.dart';
import 'base_data_source.dart';
import 'result_types.dart';

abstract class BaseLocalDataSource<T> implements LocalDataSource<T> {
  final String keyPrefix;

  BaseLocalDataSource(this.keyPrefix);

  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T data);

  String _getCacheKey(String key) => '${keyPrefix}_$key';

  @override
  Future<ResultState<T?>> getCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(key);
      final jsonString = prefs.getString(cacheKey);

      if (jsonString == null) {
        return const Success(null);
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = fromJson(json);
      return Success(data);
    } catch (e) {
      return Result.failure(CacheError(.toString()'캐시 데이터 조회 실패', details: e.toString()));
    }
  }

  @override
  Future<ResultState<List<T>>> getCachedList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(key);
      final jsonString = prefs.getString(cacheKey);

      if (jsonString == null) {
        return const Success([]);
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final dataList = jsonList
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
      return Success(dataList);
    } catch (e) {
      return Result.failure(CacheError(.toString()'캐시 리스트 조회 실패', details: e.toString()));
    }
  }

  @override
  Future<ResultState<void>> saveData(String key, T data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(key);
      final json = toJson(data);
      final jsonString = jsonEncode(json);

      await prefs.setString(cacheKey, jsonString);
      return const Success(null);
    } catch (e) {
      return Result.failure(CacheError(.toString()'캐시 데이터 저장 실패', details: e.toString()));
    }
  }

  @override
  Future<ResultState<void>> saveList(String key, List<T> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(key);
      final jsonList = data.map((item) => toJson(item)).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(cacheKey, jsonString);
      return const Success(null);
    } catch (e) {
      return Result.failure(CacheError(.toString()'캐시 리스트 저장 실패', details: e.toString()));
    }
  }

  @override
  Future<ResultState<void>> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(key);
      await prefs.remove(cacheKey);
      return const Success(null);
    } catch (e) {
      return Result.failure(CacheError(.toString()'캐시 삭제 실패', details: e.toString()));
    }
  }

  @override
  Future<ResultState<void>> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final prefixKeys = keys.where((key) => key.startsWith('${keyPrefix}_'));

      for (final key in prefixKeys) {
        await prefs.remove(key);
      }

      return const Success(null);
    } catch (e) {
      return Result.failure(CacheError(.toString()'전체 캐시 삭제 실패', details: e.toString()));
    }
  }

  @override
  Future<ResultState<bool>> hasCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(key);
      final hasData = prefs.containsKey(cacheKey);
      return Success(hasData);
    } catch (e) {
      return Result.failure(CacheError(.toString()'캐시 존재 확인 실패', details: e.toString()));
    }
  }

  Future<ResultState<void>> saveCacheWithExpiry(
    String key,
    T data,
    Duration expiry,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(key);
      final expiryKey = '${cacheKey}_expiry';

      final json = toJson(data);
      final jsonString = jsonEncode(json);
      final expiryTime = DateTime.now().add(expiry).millisecondsSinceEpoch;

      await prefs.setString(cacheKey, jsonString);
      await prefs.setInt(expiryKey, expiryTime);

      return const Success(null);
    } catch (e) {
      return Result.failure(
        CacheError('만료 시간이 포함된 캐시 저장 실패', details: e.toString()),
      );
    }
  }

  Future<ResultState<T?>> getCachedDataWithExpiry(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(key);
      final expiryKey = '${cacheKey}_expiry';

      final expiryTime = prefs.getInt(expiryKey);
      if (expiryTime == null) {
        return const Success(null);
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expiryTime) {
        await prefs.remove(cacheKey);
        await prefs.remove(expiryKey);
        return const Success(null);
      }

      final jsonString = prefs.getString(cacheKey);
      if (jsonString == null) {
        return const Success(null);
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = fromJson(json);
      return Success(data);
    } catch (e) {
      return Result.failure(
        CacheError('만료 시간이 포함된 캐시 조회 실패', details: e.toString()),
      );
    }
  }
}
