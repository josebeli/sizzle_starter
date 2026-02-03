import 'dart:convert';

import 'package:path/path.dart' as path;

import 'package:filesystem_storage/src/exceptions/filesystem_exception.dart';
import 'package:filesystem_storage/src/filesystem_storage.dart';

/// {@template in_memory_filesystem_storage}
/// In-memory implementation of [FilesystemStorage] for testing.
/// 
/// All operations are performed in memory without touching the real filesystem.
/// {@endtemplate}
final class InMemoryFilesystemStorage implements FilesystemStorage {
  /// {@macro in_memory_filesystem_storage}
  InMemoryFilesystemStorage({this.rootPath = '/mock/storage'});

  @override
  final String rootPath;
  
  final _files = <String, List<int>>{};
  final _directories = <String>{};

  @override
  String getAbsolutePath(String relativePath) => 
      path.join(rootPath, relativePath);

  @override
  Future<String> readFile(String filePath) async {
    final absolutePath = getAbsolutePath(filePath);
    final bytes = _files[absolutePath];
    
    if (bytes == null) {
      throw FileNotFoundException(path: filePath);
    }
    
    return utf8.decode(bytes);
  }

  @override
  Future<List<int>> readFileAsBytes(String filePath) async {
    final absolutePath = getAbsolutePath(filePath);
    final bytes = _files[absolutePath];
    
    if (bytes == null) {
      throw FileNotFoundException(path: filePath);
    }
    
    return List.unmodifiable(bytes);
  }

  @override
  Future<String> writeFile(String filePath, String content) async {
    final bytes = utf8.encode(content);
    return writeFileAsBytes(filePath, bytes);
  }

  @override
  Future<String> writeFileAsBytes(String filePath, List<int> bytes) async {
    final absolutePath = getAbsolutePath(filePath);
    final dirPath = path.dirname(absolutePath);
    
    // Ensure parent directory exists
    _directories.add(dirPath);
    _files[absolutePath] = List.from(bytes);
    
    return absolutePath;
  }

  @override
  Future<void> deleteFile(String filePath) async {
    final absolutePath = getAbsolutePath(filePath);
    
    if (!_files.containsKey(absolutePath)) {
      throw FileNotFoundException(path: filePath);
    }
    
    _files.remove(absolutePath);
  }

  @override
  Future<bool> fileExists(String filePath) async {
    final absolutePath = getAbsolutePath(filePath);
    return _files.containsKey(absolutePath);
  }

  /// Checks if a directory exists.
  Future<bool> directoryExists(String dirPath) async {
    final absolutePath = getAbsolutePath(dirPath);
    return _directories.contains(absolutePath);
  }

  @override
  Future<List<String>> listFiles(String dirPath, {bool recursive = false}) async {
    final absoluteDir = getAbsolutePath(dirPath);
    final files = <String>[];
    
    for (final filePath in _files.keys) {
      if (recursive) {
        if (filePath.startsWith(absoluteDir)) {
          files.add(_toRelativePath(filePath));
        }
      } else {
        final fileDir = path.dirname(filePath);
        if (fileDir == absoluteDir) {
          files.add(_toRelativePath(filePath));
        }
      }
    }
    
    return files;
  }

  @override
  Future<List<String>> listDirectories(String dirPath) async {
    final absoluteDir = getAbsolutePath(dirPath);
    final dirs = <String>[];
    
    for (final dir in _directories) {
      if (path.dirname(dir) == absoluteDir) {
        dirs.add(_toRelativePath(dir));
      }
    }
    
    return dirs;
  }

  @override
  Future<String> ensureDirectory(String dirPath) async {
    final absolutePath = getAbsolutePath(dirPath);
    _directories.add(absolutePath);
    return absolutePath;
  }

  @override
  Future<void> deleteDirectory(String dirPath, {bool recursive = false}) async {
    final absoluteDir = getAbsolutePath(dirPath);
    
    if (!_directories.contains(absoluteDir)) {
      throw DirectoryNotFoundException(path: dirPath);
    }
    
    if (recursive) {
      // Delete all files in directory
      _files.removeWhere((filePath, _) => 
          filePath.startsWith(absoluteDir));
      // Delete all subdirectories
      _directories.removeWhere((dir) => 
          dir.startsWith(absoluteDir));
    } else {
      _directories.remove(absoluteDir);
    }
  }

  String _toRelativePath(String absolutePath) {
    return path.relative(absolutePath, from: rootPath);
  }

  /// Clears all stored files and directories.
  void clear() {
    _files.clear();
    _directories.clear();
  }
}