import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

class FileUtils {
  static void createDirectory(String path, {Logger? logger}) {
    final directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      logger?.detail('Created directory: $path');
    }
  }

  static void createFile(
    String path,
    String content, {
    Logger? logger,
    bool overwrite = false,
  }) {
    final file = File(path);
    if (!file.existsSync() || overwrite) {
      file.createSync(recursive: true);
      file.writeAsStringSync(content);
      logger?.detail('Created file: $path');
    } else {
      logger?.detail('File already exists: $path');
    }
  }

  static Future<void> copyAsset(String sourcePath, String destPath) async {
    // Implementation depends on how we package assets.
    // For now, we might just write string content.
  }
}
