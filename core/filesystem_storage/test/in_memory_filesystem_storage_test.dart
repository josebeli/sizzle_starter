import 'package:filesystem_storage/filesystem_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  late InMemoryFilesystemStorage storage;

  setUp(() {
    storage = InMemoryFilesystemStorage();
  });

  tearDown(() {
    storage.clear();
  });

  group('InMemoryFilesystemStorage', () {
    test('writeFile creates parent directories', () async {
      await storage.writeFile('a/b/c.txt', 'content');
      expect(await storage.fileExists('a/b/c.txt'), isTrue);
    });

    test('readFile returns written content', () async {
      const content = 'Hello, World!';
      await storage.writeFile('test.txt', content);
      final result = await storage.readFile('test.txt');
      expect(result, equals(content));
    });

    test('readFile throws FileNotFoundException for missing file', () async {
      expect(
        () => storage.readFile('missing.txt'),
        throwsA(isA<FileNotFoundException>()),
      );
    });

    test('deleteFile removes file', () async {
      await storage.writeFile('delete_me.txt', 'content');
      expect(await storage.fileExists('delete_me.txt'), isTrue);
      
      await storage.deleteFile('delete_me.txt');
      expect(await storage.fileExists('delete_me.txt'), isFalse);
    });

    test('listFiles returns files in directory', () async {
      await storage.writeFile('dir/file1.txt', 'content1');
      await storage.writeFile('dir/file2.txt', 'content2');
      await storage.writeFile('dir/subdir/file3.txt', 'content3');

      final files = await storage.listFiles('dir');
      expect(files.length, equals(2));
      // Use path.join for cross-platform compatibility
      expect(files, contains(path.join('dir', 'file1.txt')));
      expect(files, contains(path.join('dir', 'file2.txt')));
    });

    test('listFiles recursive returns all files', () async {
      await storage.writeFile('dir/file1.txt', 'content1');
      await storage.writeFile('dir/subdir/file2.txt', 'content2');

      final files = await storage.listFiles('dir', recursive: true);
      expect(files.length, equals(2));
    });

    test('ensureDirectory creates directory', () async {
      final dirPath = await storage.ensureDirectory('my/new/dir');
      expect(dirPath, equals(path.join(storage.rootPath, 'my/new/dir')));
    });

    test('writeFileAsBytes stores bytes correctly', () async {
      final bytes = [0, 1, 2, 3, 255];
      await storage.writeFileAsBytes('binary.dat', bytes);
      
      final result = await storage.readFileAsBytes('binary.dat');
      expect(result, equals(bytes));
    });

    test('clear removes all files and directories', () async {
      await storage.writeFile('file.txt', 'content');
      await storage.ensureDirectory('dir');
      
      storage.clear();
      
      expect(await storage.fileExists('file.txt'), isFalse);
    });

    test('getAbsolutePath returns correct path', () {
      final absolute = storage.getAbsolutePath('relative/path.txt');
      expect(absolute, equals(path.join(storage.rootPath, 'relative/path.txt')));
    });
  });
}