sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => '$runtimeType: $message';
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ConflictException extends AppException {
  const ConflictException(super.message);
}

class PersistenceException extends AppException {
  const PersistenceException(super.message);
}

class StorageException extends AppException {
  const StorageException(super.message);
}
