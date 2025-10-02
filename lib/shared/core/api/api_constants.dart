class ApiConstants {
  static const String apiVersion = 'v1';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration longTimeout = Duration(minutes: 2);
  static const Duration shortTimeout = Duration(seconds: 10);

  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  static const String authHeaderKey = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  static const String refreshTokenKey = 'refresh_token';
  static const String accessTokenKey = 'access_token';

  static String get baseApiPath => '/api/$apiVersion';
}

class ApiEndpoints {
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String refreshToken = '$auth/refresh';
  static const String logout = '$auth/logout';

  static const String pets = '/pets';
  static String petById(String id) => '$pets/$id';
  static const String petProfiles = '/pet-profiles';
  static String petProfileById(String id) => '$petProfiles/$id';

  static const String walks = '/walks';
  static String walkById(String id) => '$walks/$id';
  static const String walkHistory = '$walks/history';

  static const String schedules = '/schedules';
  static String scheduleById(String id) => '$schedules/$id';
  static const String feedingSchedules = '$schedules/feeding';
  static const String medicationSchedules = '$schedules/medication';

  static const String health = '/health';
  static const String vaccinations = '$health/vaccinations';
  static const String medicalRecords = '$health/medical-records';

  static const String facilities = '/facilities';
  static const String facilitiesSearch = '$facilities/search';

  static const String notifications = '/notifications';
  static const String notificationSettings = '$notifications/settings';

  static const String uploads = '/uploads';
  static const String imageUpload = '$uploads/images';
  static const String fileUpload = '$uploads/files';

  static const String ai = '/ai';
  static const String aiChat = '$ai/chat';
  static const String aiRecommendations = '$ai/recommendations';

  static const String sync = '/sync';
  static const String syncStatus = '$sync/status';
  static const String syncConflicts = '$sync/conflicts';
}

class ApiStatusCodes {
  static const int success = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;

  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int tooManyRequests = 429;

  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;
}

class ApiCacheKeys {
  static const String petProfiles = 'cache_pet_profiles';
  static const String walks = 'cache_walks';
  static const String schedules = 'cache_schedules';
  static const String health = 'cache_health';
  static const String notifications = 'cache_notifications';
  static const String userSettings = 'cache_user_settings';
}

class ApiErrorCodes {
  static const String networkError = 'NETWORK_ERROR';
  static const String timeoutError = 'TIMEOUT_ERROR';
  static const String authenticationError = 'AUTH_ERROR';
  static const String authorizationError = 'AUTHORIZATION_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  static const String notFoundError = 'NOT_FOUND_ERROR';
  static const String conflictError = 'CONFLICT_ERROR';
  static const String serverError = 'SERVER_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';
  static const String cacheError = 'CACHE_ERROR';
  static const String syncError = 'SYNC_ERROR';
}
