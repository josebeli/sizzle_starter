import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// {@template path_resolver}
/// Resolves platform-specific storage paths.
/// 
/// - Windows: %USERPROFILE%/Documents/WhiteboardPlanner
/// - Mobile (iOS/Android): App private documents directory
/// - macOS/Linux: Application documents directory
/// {@endtemplate}
class PathResolver {
  /// {@macro path_resolver}
  PathResolver({required String basePath}) : _basePath = basePath;

  final String _basePath;

  /// Initializes the resolver by getting the appropriate base directory.
  /// 
  /// Must be called before using the resolver.
  static Future<PathResolver> initialize() async {
    final directory = await _getBaseDirectory();
    return PathResolver(basePath: directory.path);
  }

  static Future<Directory> _getBaseDirectory() async {
    if (Platform.isWindows) {
      // Windows: Documents folder
      final documents = await getApplicationDocumentsDirectory();
      return Directory(path.join(documents.path, 'WhiteboardPlanner'));
    } else {
      // Mobile: App-private documents
      return getApplicationDocumentsDirectory();
    }
  }

  /// Resolves a relative path to absolute.
  String resolve(String relativePath) => path.join(_basePath, relativePath);

  /// Gets the base storage path.
  String get basePath => _basePath;

  /// Gets the rooms directory path.
  String get roomsPath => resolve('rooms');

  /// Gets the global experts directory path.
  String get globalExpertsPath => resolve('global_experts');
}