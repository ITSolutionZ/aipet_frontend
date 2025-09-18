
library;

/// Profile Not Found Exception
class ProfileNotFoundException implements Exception {
  final String message;
  ProfileNotFoundException(this.message);

  @override
  String toString() => 'ProfileNotFoundException: $message';
}

/// Pet Profile Access Denied Exception
class PetProfileAccessDeniedException implements Exception {
  final String message;
  PetProfileAccessDeniedException(this.message);

  @override
  String toString() => 'PetProfileAccessDeniedException: $message';
}

/// Pet Profile Validation Exception
class PetProfileValidationException implements Exception {
  final String message;
  PetProfileValidationException(this.message);

  @override
  String toString() => 'PetProfileValidationException: $message';
}