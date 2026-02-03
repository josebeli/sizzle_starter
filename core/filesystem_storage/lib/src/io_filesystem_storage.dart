import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

import 'package:filesystem_storage/src/exceptions/filesystem_exception.dart';
import 'package:filesystem_storage/src/filesystem_storage.dart';
import 'package:filesystem_storage/src/path_resolver.dart';

/// {@template io_filesystem_storage}
/// Filesystem storage implementation using dart:io.
/// {@endtemplate}
final class IOFilesystemStorage implements FilesystemStorage {
  /// {@macro io_filesystem_storage}
  IOFilesystemStorage({
    required PathResolver pathResolver,
    Logger? logger,
  })  : _pathResolver = pathResolver,
        _logger = logger;

  final PathResolver _pathResolver;
  final Logger? _logger;

  @override
  String get rootPath => _pathResolver.basePath;

  @override
  String getAbsolutePath(String relativePath) => 
      _pathResolver.resolve(relativePath);

  @override
  Future<String> readFile(String filePath) async {
    _logger?.debug('Reading file: $filePath');
    final file = File(getAbsolutePath(filePath));
    
    if (!await file.exists()) {
      throw FileNotFoundException(path: filePath);
    }
    
    try {
      return await file.readAsString();
    } on FileSystemException catch (e) {
      throw OperationFailedException(
        message: 'Failed to read file',
        path: filePath,
        cause: e,
      );
    }
  }

  @override
  Future<List<int>> readFileAsBytes(String filePath) async {
    _logger?.debug('Reading file as bytes: $filePath');
    final file = File(getAbsolutePath(filePath));
    
    if (!await file.exists()) {
      throw FileNotFoundException(path: filePath);
    }
    
    try {
      return await file.readAsBytes();
    } on FileSystemException catch (e) {
      throw OperationFailedException(
        message: 'Failed to read file',
        path: filePath,
        cause: e,
      );
    }
  }

  @override
  Future<String> writeFile(String filePath, String content) async {
    _logger?.debug('Writing file: $filePath');
    final absolutePath = getAbsolutePath(filePath);
    final file = File(absolutePath);
    
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
      return absolutePath;
    } on FileSystemException catch (e) {
      throw OperationFailedException(
        message: 'Failed to write file',
        path: filePath,
        cause: e,
      );
    }
  }

  @override
  Future<String> writeFileAsBytes(String filePath, List<int> bytes) async {
    _logger?.debug('Writing file as bytes: $filePath');
    final absolutePath = getAbsolutePath(filePath);
    final file = File(absolutePath);
    
    try {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      return absolutePath;
    } on FileSystemException catch (e) {
      throw OperationFailedException(
        message: 'Failed to write file',
        path: filePath,
        cause: e,
      );
    }
  }

  @override
  Future<void> deleteFile(String filePath) async {
    _logger?.debug('Deleting file: $filePath');
    final file = File(getAbsolutePath(filePath));
    
    if (!await file.exists()) {
      throw FileNotFoundException(path: filePath);
    }
    
    try {
      await file.delete();
    } on FileSystemException catch (e) {
      throw OperationFailedException(
        message: 'Failed to delete file',
        path: filePath,
        cause: e,
      );
    }
  }

  @override
  Future<bool> fileExists(String filePath) async {
    final file = File(getAbsolutePath(filePath));
    return file.exists();
  }

  @override
  Future<List<String>> listFiles(String dirPath, {bool recursive = false}) async {
    final dir = Directory(getAbsolutePath(dirPath));
    
    if (!await dir.exists()) {
      throw DirectoryNotFoundException(path: dirPath);
    }
    
    final files = await dir
        .list(recursive: recursive)
        .where((e) => e is File)
        .map((e) => _toRelativePath(e.path))
        .toList();
    
    return files;
  }

  @override
  Future<List<String>> listDirectories(String dirPath) async {
    final dir = Directory(getAbsolutePath(dirPath));
    
    if (!await dir.exists()) {
      throw DirectoryNotFoundException(path: dirPath);
    }
    
    final dirs = await dir
        .list()
        .where((e) => e is Directory)
        .map((e) => _toRelativePath(e.path))
        .toList();
    
    return dirs;
  }

  @override
  Future<String> ensureDirectory(String dirPath) async {
    _logger?.debug('Ensuring directory: $dirPath');
    final absolutePath = getAbsolutePath(dirPath);
    final dir = Directory(absolutePath);
    
    try {
      await dir.create(recursive: true);
      return absolutePath;
    } on FileSystemException catch (e) {
      throw OperationFailedException(
        message: 'Failed to create directory',
        path: dirPath,
        cause: e,
      );
    }
  }

  @override
  Future<void> deleteDirectory(String dirPath, {bool recursive = false}) async {
    _logger?.debug('Deleting directory: $dirPath (recursive: $recursive)');
    final dir = Directory(getAbsolutePath(dirPath));
    
    if (!await dir.exists()) {
      throw DirectoryNotFoundException(path: dirPath);
    }
    
    try {
      await dir.delete(recursive: recursive);
    } on FileSystemException catch (e) {
      throw OperationFailedException(
        message: 'Failed to delete directory',
        path: dirPath,
        cause: e,
      );
    }
  }

  String _toRelativePath(String absolutePath) {
    return path.relative(absolutePath, from: rootPath);
  }
}