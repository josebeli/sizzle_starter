import 'package:filesystem_storage/src/exceptions/filesystem_exception.dart';

/// {@template filesystem_storage}
/// Abstract interface for filesystem operations.
/// 
/// Provides a platform-agnostic way to read, write, delete and list files.
/// All paths are relative to the application storage directory.
/// {@endtemplate}
abstract interface class FilesystemStorage {
  /// {@macro filesystem_storage}
  const FilesystemStorage();

  /// Reads a file as String.
  /// 
  /// [path] is relative to the storage root.
  /// Returns the file content as String.
  /// Throws [FileNotFoundException] if file doesn't exist.
  /// Throws [FilesystemException] for other errors.
  Future<String> readFile(String path);

  /// Reads a file as bytes.
  /// 
  /// [path] is relative to the storage root.
  /// Returns the file content as bytes.
  /// Throws [FileNotFoundException] if file doesn't exist.
  Future<List<int>> readFileAsBytes(String path);

  /// Writes content to a file.
  /// 
  /// [path] is relative to the storage root.
  /// Creates parent directories if they don't exist.
  /// Overwrites existing file.
  /// Returns the actual path where the file was written.
  Future<String> writeFile(String path, String content);

  /// Writes bytes to a file.
  /// 
  /// [path] is relative to the storage root.
  /// Creates parent directories if they don't exist.
  Future<String> writeFileAsBytes(String path, List<int> bytes);

  /// Deletes a file.
  /// 
  /// [path] is relative to the storage root.
  /// Throws [FileNotFoundException] if file doesn't exist.
  Future<void> deleteFile(String path);

  /// Checks if a file exists.
  Future<bool> fileExists(String path);

  /// Lists files in a directory.
  /// 
  /// [path] is relative to the storage root.
  /// Returns list of relative file paths.
  /// If [recursive] is true, includes files in subdirectories.
  Future<List<String>> listFiles(String path, {bool recursive = false});

  /// Lists directories in a directory.
  /// 
  /// [path] is relative to the storage root.
  /// Returns list of relative directory paths.
  Future<List<String>> listDirectories(String path);

  /// Ensures a directory exists, creating it if necessary.
  /// 
  /// [path] is relative to the storage root.
  /// Creates parent directories recursively.
  /// Returns the actual directory path.
  Future<String> ensureDirectory(String path);

  /// Deletes a directory and all its contents.
  /// 
  /// [path] is relative to the storage root.
  /// If [recursive] is true, deletes all contents.
  Future<void> deleteDirectory(String path, {bool recursive = false});

  /// Gets the absolute path for a relative path.
  String getAbsolutePath(String relativePath);

  /// Gets the storage root directory.
  String get rootPath;
}