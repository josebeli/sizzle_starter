/// {@template filesystem_exception}
/// Base class for all filesystem storage exceptions.
/// {@endtemplate}
sealed class FilesystemException implements Exception {
  /// {@macro filesystem_exception}
  const FilesystemException({
    required this.message,
    this.path,
    this.cause,
  });

  final String message;
  final String? path;
  final Object? cause;

  @override
  String toString() => 
      'FilesystemException: $message (path: $path, cause: $cause)';
}

/// {@template file_not_found_exception}
/// Thrown when attempting to access a file that doesn't exist.
/// {@endtemplate}
final class FileNotFoundException extends FilesystemException {
  /// {@macro file_not_found_exception}
  const FileNotFoundException({required super.path})
      : super(message: 'File not found');
}

/// {@template directory_not_found_exception}
/// Thrown when attempting to access a directory that doesn't exist.
/// {@endtemplate}
final class DirectoryNotFoundException extends FilesystemException {
  /// {@macro directory_not_found_exception}
  const DirectoryNotFoundException({required super.path})
      : super(message: 'Directory not found');
}

/// {@template permission_denied_exception}
/// Thrown when filesystem operation is not permitted.
/// {@endtemplate}
final class PermissionDeniedException extends FilesystemException {
  /// {@macro permission_denied_exception}
  const PermissionDeniedException({super.path, super.cause})
      : super(message: 'Permission denied');
}

/// {@template operation_failed_exception}
/// Thrown when a filesystem operation fails for any reason.
/// {@endtemplate}
final class OperationFailedException extends FilesystemException {
  /// {@macro operation_failed_exception}
  const OperationFailedException({
    required super.message,
    super.path,
    super.cause,
  });
}