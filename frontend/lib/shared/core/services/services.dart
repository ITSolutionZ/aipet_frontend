// 공통 서비스들
export 'api_service.dart';
export 'auth_token_repository.dart';
export 'common_error_service.dart';
export 'date_format_service.dart';
export 'datetime_service.dart';
export 'encryption_service.dart';
export 'error_handler_service.dart';
export 'error_handling_service.dart';
export 'error_service.dart';
export 'http_client_service.dart' show ApiResponse;
export 'image_cache_service.dart';
export 'image_management_service.dart';
export 'image_service.dart';
export 'logger_service.dart';
export 'openai_http_client.dart';
export 'openweathermap_http_client.dart';
export 'performance_monitor_service.dart';
export 'performance_optimizer_service.dart';
export 'secure_storage_service.dart';
export 'snackbar_service.dart';
// MockDataService moved to shared/testing.dart
export 'ui_notification_service.dart';
export 'ui_service.dart';
export 'unified_validation_service.dart';
export 'user_experience_service.dart';
export 'validation_service.dart';

// Feature-specific services have been moved:
// - notification_icon_service → notification/data/services/
// - pet_registration_error_handler → pet_profile/domain/services/
// - google_places_service → facility/data/services/
// - youtube_api_service → pet_activities/data/services/
// - ai_http_client_service → deprecated (replaced by openai_http_client.dart)
//
// OpenAI services → moved to respective features:
//   - AiChatOpenAIService → features/ai/data/services/ai_chat_openai_service.dart
//   - WeatherOpenAIService → features/home/data/services/weather_openai_service.dart
//   - WeeklyTaskOpenAIService → features/daily/data/services/weekly_task_openai_service.dart
//   - HealthReportOpenAIService → features/daily/data/services/health_report_openai_service.dart
//   - OpenAIAllergyAnalysisService → features/allergy/data/services/openai_allergy_analysis_service.dart
//
// Weather services → moved to respective features:
//   - WeatherService → features/home/data/services/weather_service.dart (비즈니스 로직)
//   - OpenWeatherMapService → features/home/data/services/openweathermap_service.dart (Legacy)
