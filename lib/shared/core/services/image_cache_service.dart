import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// 이미지 캐싱 전략 타입
enum ImageCacheStrategy {
  /// 메모리 캐시만 사용 (빠른 로딩, 메모리 사용량 높음)
  memory,

  /// 디스크 캐시만 사용 (느린 로딩, 메모리 사용량 낮음)
  disk,

  /// 메모리 + 디스크 캐시 사용 (균형잡힌 성능)
  hybrid,

  /// 캐시 사용하지 않음 (항상 네트워크에서 로드)
  none,
}

/// 이미지 캐시 설정
class ImageCacheConfig {
  final ImageCacheStrategy strategy;
  final Duration maxAge;
  final int maxSize;
  final bool enableCompression;
  final double compressionQuality;

  const ImageCacheConfig({
    this.strategy = ImageCacheStrategy.hybrid,
    this.maxAge = const Duration(days: 7),
    this.maxSize = 100 * 1024 * 1024, // 100MB
    this.enableCompression = true,
    this.compressionQuality = 0.8,
  });
}

/// 캐시 엔트리 (타임스탬프 포함)
class _CacheEntry {
  final Uint8List data;
  final DateTime timestamp;

  const _CacheEntry(this.data, this.timestamp);

  bool get isExpired =>
      DateTime.now().difference(timestamp) > const Duration(hours: 1);
}

/// 이미지 캐시 서비스
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  /// 메모리 캐시 (타임스탬프 포함)
  final Map<String, _CacheEntry> _memoryCache = {};

  /// 캐시 설정
  ImageCacheConfig _config = const ImageCacheConfig();

  /// 설정 업데이트
  void updateConfig(ImageCacheConfig config) {
    _config = config;
  }

  /// 현재 설정
  ImageCacheConfig get config => _config;

  /// 이미지 로드 (URL)
  Future<Uint8List?> loadImageFromUrl(
    String url, {
    ImageCacheConfig? config,
  }) async {
    final cacheConfig = config ?? _config;

    try {
      // 메모리 캐시 확인
      if (cacheConfig.strategy == ImageCacheStrategy.memory ||
          cacheConfig.strategy == ImageCacheStrategy.hybrid) {
        final cached = _memoryCache[url];
        if (cached != null && !cached.isExpired) {
          return cached.data;
        }
      }

      // 디스크 캐시 확인
      if (cacheConfig.strategy == ImageCacheStrategy.disk ||
          cacheConfig.strategy == ImageCacheStrategy.hybrid) {
        final cachedBytes = await _loadFromDiskCache(url);
        if (cachedBytes != null) {
          // 메모리 캐시에 저장
          if (cacheConfig.strategy == ImageCacheStrategy.hybrid) {
            _memoryCache[url] = _CacheEntry(cachedBytes, DateTime.now());
          }
          return cachedBytes;
        }
      }

      // 네트워크에서 로드
      if (cacheConfig.strategy != ImageCacheStrategy.none) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;

          // 디스크 캐시에 저장
          if (cacheConfig.strategy == ImageCacheStrategy.disk ||
              cacheConfig.strategy == ImageCacheStrategy.hybrid) {
            await _saveToDiskCache(url, bytes);
          }

          // 메모리 캐시에 저장
          if (cacheConfig.strategy == ImageCacheStrategy.memory ||
              cacheConfig.strategy == ImageCacheStrategy.hybrid) {
            _memoryCache[url] = _CacheEntry(bytes, DateTime.now());
          }

          return bytes;
        }
      }
    } catch (error) {
      debugPrint('이미지 로드 실패: $url - $error');
    }

    return null;
  }

  /// 이미지 로드 (Asset)
  Future<Uint8List?> loadImageFromAsset(
    String assetPath, {
    ImageCacheConfig? config,
  }) async {
    final cacheConfig = config ?? _config;

    try {
      // 메모리 캐시 확인
      if (cacheConfig.strategy == ImageCacheStrategy.memory ||
          cacheConfig.strategy == ImageCacheStrategy.hybrid) {
        final cached = _memoryCache[assetPath];
        if (cached != null && !cached.isExpired) {
          return cached.data;
        }
      }

      // Asset에서 로드
      final bytes = await _loadAssetBytes(assetPath);

      // 메모리 캐시에 저장
      if (cacheConfig.strategy == ImageCacheStrategy.memory ||
          cacheConfig.strategy == ImageCacheStrategy.hybrid) {
        _memoryCache[assetPath] = _CacheEntry(bytes, DateTime.now());
      }

      return bytes;
    } catch (error) {
      debugPrint('Asset 이미지 로드 실패: $assetPath - $error');
    }

    return null;
  }

  /// Asset 바이트 로드
  Future<Uint8List> _loadAssetBytes(String assetPath) async {
    final data = await DefaultAssetBundle.of(
      navigatorKey.currentContext!,
    ).load(assetPath);
    return data.buffer.asUint8List();
  }

  /// 디스크 캐시에서 로드
  Future<Uint8List?> _loadFromDiskCache(String url) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final cacheFile = File(
        '${cacheDir.path}/image_cache/${_getCacheKey(url)}',
      );

      if (await cacheFile.exists()) {
        return await cacheFile.readAsBytes();
      }
    } catch (error) {
      debugPrint('디스크 캐시 로드 실패: $error');
    }
    return null;
  }

  /// 디스크 캐시에 저장
  Future<void> _saveToDiskCache(String url, Uint8List bytes) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final cacheDirFile = Directory('${cacheDir.path}/image_cache');

      if (!await cacheDirFile.exists()) {
        await cacheDirFile.create(recursive: true);
      }

      final cacheFile = File('${cacheDirFile.path}/${_getCacheKey(url)}');
      await cacheFile.writeAsBytes(bytes);
    } catch (error) {
      debugPrint('디스크 캐시 저장 실패: $error');
    }
  }

  /// 캐시 키 생성
  String _getCacheKey(String url) {
    return url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }

  /// 이미지 프리로드
  Future<void> preloadImages(List<String> urls) async {
    for (final url in urls) {
      try {
        await loadImageFromUrl(url);
      } catch (error) {
        debugPrint('이미지 프리로드 실패: $url - $error');
      }
    }
  }

  /// 캐시 정리
  Future<void> clearCache({
    bool clearMemory = true,
    bool clearDisk = true,
  }) async {
    if (clearMemory) {
      _memoryCache.clear();
    }

    if (clearDisk) {
      try {
        final cacheDir = await getTemporaryDirectory();
        final cacheDirFile = Directory('${cacheDir.path}/image_cache');

        if (await cacheDirFile.exists()) {
          await cacheDirFile.delete(recursive: true);
        }
      } catch (error) {
        debugPrint('디스크 캐시 정리 실패: $error');
      }
    }
  }

  /// 캐시 크기 확인
  Future<int> getCacheSize() async {
    int size = 0;

    // 메모리 캐시 크기
    for (final entry in _memoryCache.values) {
      size += entry.data.length;
    }

    // 디스크 캐시 크기
    try {
      final cacheDir = await getTemporaryDirectory();
      final cacheDirFile = Directory('${cacheDir.path}/image_cache');

      if (await cacheDirFile.exists()) {
        await for (final file in cacheDirFile.list(recursive: true)) {
          if (file is File) {
            size += await file.length();
          }
        }
      }
    } catch (error) {
      debugPrint('캐시 크기 확인 실패: $error');
    }

    return size;
  }

  /// 특정 이미지 캐시 제거
  Future<void> removeFromCache(String key) async {
    _memoryCache.remove(key);

    try {
      final cacheDir = await getTemporaryDirectory();
      final cacheFile = File(
        '${cacheDir.path}/image_cache/${_getCacheKey(key)}',
      );

      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
    } catch (error) {
      debugPrint('캐시 제거 실패: $error');
    }
  }

  /// 오래된 캐시 정리
  Future<void> cleanExpiredCache() async {
    final expiredKeys = <String>[];

    // 메모리 캐시에서 오래된 항목 제거
    for (final key in _memoryCache.keys) {
      final entry = _memoryCache[key];
      if (entry != null && entry.isExpired) {
        expiredKeys.add(key);
      }
    }

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }

    // 디스크 캐시 정리 (간단한 구현)
    try {
      final cacheDir = await getTemporaryDirectory();
      final cacheDirFile = Directory('${cacheDir.path}/image_cache');

      if (await cacheDirFile.exists()) {
        await for (final file in cacheDirFile.list()) {
          if (file is File) {
            final stat = await file.stat();
            if (DateTime.now().difference(stat.modified) >
                const Duration(days: 7)) {
              await file.delete();
            }
          }
        }
      }
    } catch (error) {
      debugPrint('오래된 캐시 정리 실패: $error');
    }
  }
}

/// 전역 NavigatorKey (Asset 로드용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 이미지 캐싱 위젯
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final ImageCacheConfig? cacheConfig;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.cacheConfig,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _loadImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? _buildDefaultPlaceholder();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return errorWidget ?? _buildDefaultErrorWidget();
        }

        return Image.memory(
          snapshot.data!,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }

  Future<Uint8List?> _loadImage() {
    if (imageUrl.startsWith('http')) {
      return ImageCacheService().loadImageFromUrl(
        imageUrl,
        config: cacheConfig,
      );
    } else {
      return ImageCacheService().loadImageFromAsset(
        imageUrl,
        config: cacheConfig,
      );
    }
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.error)),
    );
  }
}

/// Asset 이미지 캐싱 위젯
class CachedAssetImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final ImageCacheConfig? cacheConfig;

  const CachedAssetImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.cacheConfig,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: ImageCacheService().loadImageFromAsset(
        assetPath,
        config: cacheConfig,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? _buildDefaultPlaceholder();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return errorWidget ?? _buildDefaultErrorWidget();
        }

        return Image.memory(
          snapshot.data!,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.error)),
    );
  }
}
