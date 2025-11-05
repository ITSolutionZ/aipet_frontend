class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final ApiPagination? pagination;
  final List<ApiError>? errors;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.pagination,
    this.errors,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      pagination: json['pagination'] != null
          ? ApiPagination.fromJson(json['pagination'])
          : null,
      errors: json['errors'] != null
          ? (json['errors'] as List).map((e) => ApiError.fromJson(e)).toList()
          : null,
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'pagination': pagination?.toJson(),
      'errors': errors?.map((e) => e.toJson()).toList(),
      'meta': meta,
    };
  }
}

class ApiListResponse<T> {
  final bool success;
  final String message;
  final List<T> items;
  final ApiPagination? pagination;
  final List<ApiError>? errors;
  final Map<String, dynamic>? meta;

  const ApiListResponse({
    required this.success,
    required this.message,
    required this.items,
    this.pagination,
    this.errors,
    this.meta,
  });

  factory ApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = json['data'] ?? json['items'] ?? [];
    final items = (dataList as List).map((item) => fromJsonT(item)).toList();

    return ApiListResponse<T>(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      items: items,
      pagination: json['pagination'] != null
          ? ApiPagination.fromJson(json['pagination'])
          : null,
      errors: json['errors'] != null
          ? (json['errors'] as List).map((e) => ApiError.fromJson(e)).toList()
          : null,
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': items,
      'pagination': pagination?.toJson(),
      'errors': errors?.map((e) => e.toJson()).toList(),
      'meta': meta,
    };
  }
}

class ApiPagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNext;
  final bool hasPrevious;

  const ApiPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory ApiPagination.fromJson(Map<String, dynamic> json) {
    return ApiPagination(
      currentPage: json['current_page'] ?? json['page'] ?? 1,
      totalPages: json['total_pages'] ?? json['last_page'] ?? 1,
      totalItems: json['total_items'] ?? json['total'] ?? 0,
      itemsPerPage:
          json['items_per_page'] ?? json['per_page'] ?? json['limit'] ?? 20,
      hasNext: json['has_next'] ?? (json['next_page_url'] != null),
      hasPrevious: json['has_previous'] ?? (json['prev_page_url'] != null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'items_per_page': itemsPerPage,
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }
}

class ApiError {
  final String code;
  final String message;
  final String? field;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.code,
    required this.message,
    this.field,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? json['error'] ?? '',
      field: json['field'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'field': field,
      'details': details,
    };
  }
}

class ApiMeta {
  final String? requestId;
  final DateTime timestamp;
  final String version;
  final Map<String, dynamic>? additional;

  const ApiMeta({
    this.requestId,
    required this.timestamp,
    required this.version,
    this.additional,
  });

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      requestId: json['request_id'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      version: json['version'] ?? '1.0',
      additional: json['additional'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'timestamp': timestamp.toIso8601String(),
      'version': version,
      'additional': additional,
    };
  }
}
