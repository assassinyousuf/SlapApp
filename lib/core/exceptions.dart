abstract class Result<T, E extends Exception> {
  const Result();
}

class Success<T, E extends Exception> extends Result<T, E> {
  final T value;
  const Success(this.value);
}

class Failure<T, E extends Exception> extends Result<T, E> {
  final E exception;
  const Failure(this.exception);
}

class SlapSenseException implements Exception {
  final String message;
  SlapSenseException(this.message);

  @override
  String toString() => 'SlapSenseException: $message';
}

class SensorInitException extends SlapSenseException {
  SensorInitException() : super('Failed to initialize sensors.');
}

class StoragePermissionException extends SlapSenseException {
  StoragePermissionException() : super('Storage permission denied.');
}
