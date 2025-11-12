import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';
import '../../../../shared/shared.dart';
import '../models/board_post_model.dart';

/// Backend Board API Service
///
/// BackendApiClient를 사용하여 게시판 CRUD 및 댓글, 좋아요 기능을 수행합니다.
/// Firebase ID Token이 자동으로 Authorization 헤더에 추가됩니다.
class BackendBoardApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// 게시글 목록 조회
  ///
  /// GET /board/posts
  static Future<Result<List<BoardPost>>> getPosts({
    String? category,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (category != null && category != 'all') {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        '/board/posts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<BoardPost> posts = [];

        if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              posts.add(_mapToBoardPost(item));
            }
          }
        }

        return Result.success('게시글 목록을 가져왔습니다', posts);
      } else {
        return Result.failure('게시글 목록 조회에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('게시글 목록 조회', e);
    } catch (e) {
      return Result.failure('게시글 목록 조회 중 오류 발생: $e');
    }
  }

  /// 게시글 상세 조회
  ///
  /// GET /board/posts/:postId
  static Future<Result<BoardPost>> getPostById(String postId) async {
    try {
      final response = await _apiClient.get('/board/posts/$postId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          final post = _mapToBoardPost(data['data']);
          return Result.success('게시글을 가져왔습니다', post);
        }

        return Result.failure('게시글 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('게시글 조회에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('게시글 조회', e);
    } catch (e) {
      return Result.failure('게시글 조회 중 오류 발생: $e');
    }
  }

  /// 게시글 작성
  ///
  /// POST /board/posts
  static Future<Result<BoardPost>> createPost({
    required String title,
    required String content,
    required String category,
    List<String>? imageUrls,
    List<String>? tags,
  }) async {
    try {
      final response = await _apiClient.post(
        '/board/posts',
        data: {
          'title': title,
          'content': content,
          'category': category,
          if (imageUrls != null) 'imageUrls': imageUrls,
          if (tags != null) 'tags': tags,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          final post = _mapToBoardPost(data['data']);
          return Result.success('게시글을 작성했습니다', post);
        }

        return Result.failure('게시글 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('게시글 작성에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('게시글 작성', e);
    } catch (e) {
      return Result.failure('게시글 작성 중 오류 발생: $e');
    }
  }

  /// 게시글 수정
  ///
  /// PUT /board/posts/:postId
  static Future<Result<BoardPost>> updatePost({
    required String postId,
    required String title,
    required String content,
    required String category,
    List<String>? imageUrls,
    List<String>? tags,
  }) async {
    try {
      final response = await _apiClient.put(
        '/board/posts/$postId',
        data: {
          'title': title,
          'content': content,
          'category': category,
          if (imageUrls != null) 'imageUrls': imageUrls,
          if (tags != null) 'tags': tags,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          final post = _mapToBoardPost(data['data']);
          return Result.success('게시글을 수정했습니다', post);
        }

        return Result.failure('게시글 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('게시글 수정에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('게시글 수정', e);
    } catch (e) {
      return Result.failure('게시글 수정 중 오류 발생: $e');
    }
  }

  /// 게시글 삭제
  ///
  /// DELETE /board/posts/:postId
  static Future<Result<void>> deletePost(String postId) async {
    try {
      final response = await _apiClient.delete('/board/posts/$postId');

      if (response.statusCode == 200) {
        return Result.success('게시글을 삭제했습니다');
      } else {
        return Result.failure('게시글 삭제에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('게시글 삭제', e);
    } catch (e) {
      return Result.failure('게시글 삭제 중 오류 발생: $e');
    }
  }

  /// 게시글 댓글 목록 조회
  ///
  /// GET /board/posts/:postId/comments
  static Future<Result<List<Map<String, dynamic>>>> getComments(
    String postId,
  ) async {
    try {
      final response = await _apiClient.get('/board/posts/$postId/comments');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Map<String, dynamic>> comments = [];

        if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              comments.add(item);
            }
          }
        }

        return Result.success('댓글 목록을 가져왔습니다', comments);
      } else {
        return Result.failure('댓글 목록 조회에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('댓글 목록 조회', e);
    } catch (e) {
      return Result.failure('댓글 목록 조회 중 오류 발생: $e');
    }
  }

  /// 게시글 댓글 작성
  ///
  /// POST /board/posts/:postId/comments
  static Future<Result<Map<String, dynamic>>> createComment({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.post(
        '/board/posts/$postId/comments',
        data: {'content': content},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Result.success('댓글을 작성했습니다', data['data']);
        }

        return Result.failure('댓글 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('댓글 작성에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('댓글 작성', e);
    } catch (e) {
      return Result.failure('댓글 작성 중 오류 발생: $e');
    }
  }

  /// 댓글 삭제
  ///
  /// DELETE /board/posts/:postId/comments/:commentId
  static Future<Result<void>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final response = await _apiClient.delete(
        '/board/posts/$postId/comments/$commentId',
      );

      if (response.statusCode == 200) {
        return Result.success('댓글을 삭제했습니다');
      } else {
        return Result.failure('댓글 삭제에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('댓글 삭제', e);
    } catch (e) {
      return Result.failure('댓글 삭제 중 오류 발생: $e');
    }
  }

  /// 게시글 좋아요/취소
  ///
  /// POST /board/posts/:postId/like
  static Future<Result<Map<String, dynamic>>> toggleLike(String postId) async {
    try {
      final response = await _apiClient.post('/board/posts/$postId/like');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          return Result.success(
            data['message'] ?? '좋아요 처리가 완료되었습니다',
            data['data'],
          );
        }

        return Result.failure('응답 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('좋아요 처리에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('좋아요 처리', e);
    } catch (e) {
      return Result.failure('좋아요 처리 중 오류 발생: $e');
    }
  }

  /// 게시글 좋아요 상태 확인
  ///
  /// GET /board/posts/:postId/like
  static Future<Result<bool>> checkLikeStatus(String postId) async {
    try {
      final response = await _apiClient.get('/board/posts/$postId/like');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
          final liked = data['data']['liked'] as bool? ?? false;
          return Result.success('좋아요 상태를 확인했습니다', liked);
        }

        return Result.failure('응답 데이터 형식이 올바르지 않습니다');
      } else {
        return Result.failure('좋아요 상태 확인에 실패했습니다');
      }
    } on DioException catch (e) {
      return _handleDioError('좋아요 상태 확인', e);
    } catch (e) {
      return Result.failure('좋아요 상태 확인 중 오류 발생: $e');
    }
  }

  /// Backend 응답을 BoardPost로 변환
  static BoardPost _mapToBoardPost(Map<String, dynamic> json) {
    return BoardPost(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '익명',
      authorProfileImage: json['author_profile_image'] as String?,
      category: json['category'] as String? ?? '',
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
      imageUrls: _parseStringList(json['image_urls']),
      tags: _parseStringList(json['tags']),
    );
  }

  /// DateTime 파싱 헬퍼
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        LoggerService.warning('⚠️ DateTime 파싱 실패: $value');
        return null;
      }
    }
    return null;
  }

  /// JSON string list 파싱 헬퍼
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      // JSON string인 경우 파싱 시도
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        // 파싱 실패 시 빈 리스트 반환
      }
    }
    return [];
  }

  /// DioException 에러 처리
  static Result<T> _handleDioError<T>(String operation, DioException e) {
    String errorMessage = 'エラーが発生しました';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'タイムアウトが発生しました';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'ネットワーク接続を確認してください';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          errorMessage = '認証に失敗しました';
        } else if (statusCode == 403) {
          errorMessage = 'アクセスが拒否されました';
        } else if (statusCode == 404) {
          errorMessage = 'リソースが見つかりません';
        } else if (statusCode != null && statusCode >= 500) {
          errorMessage = 'サーバーエラーが発生しました';
        }
        break;
      default:
        errorMessage = '予期しないエラーが発生しました';
    }

    LoggerService.error('❌ BackendBoardApiService: $operation 실패 - $errorMessage');
    return Result.failure(errorMessage);
  }
}
