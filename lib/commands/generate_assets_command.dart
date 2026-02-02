import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import 'package:getx_clean_arch/getx_clean_arch.dart';

class GenerateAssetsCommand extends Command<int> {
  final Logger logger;

  GenerateAssetsCommand({required this.logger});

  @override
  String get description =>
      'Generate lib/common/utils/assets.dart from assets folder.';

  @override
  String get name => 'generate:assets';

  @override
  Future<int> run() async {
    logger.info('Generating assets...');

    final assetsDir = Directory('assets');
    if (!assetsDir.existsSync()) {
      logger.warn('assets directory not found.');
      return ExitCode.usage.code;
    }

    final buffer = StringBuffer();
    buffer.writeln('class Assets {');
    buffer.writeln('  Assets._();');
    buffer.writeln();

    await _scanDirectory(assetsDir, buffer);

    buffer.writeln('}');

    final outputFile = 'lib/common/utils/assets.dart';

    // Ensure utils directory exists
    FileUtils.createDirectory('lib/common/utils', logger: logger);

    FileUtils.createFile(
      outputFile,
      buffer.toString(),
      logger: logger,
      overwrite: true,
    );

    logger.success('Assets generated successfully at $outputFile');
    return ExitCode.success.code;
  }

  Future<void> _scanDirectory(Directory dir, StringBuffer buffer) async {
    final List<FileSystemEntity> entities = dir.listSync(recursive: true);

    for (var entity in entities) {
      if (entity is File) {
        final path = entity.path;
        // Skip hidden files
        if (p.basename(path).startsWith('.')) continue;

        final relativePath = p.relative(path);
        final varName = _generateVarName(relativePath);

        buffer.writeln("  static const String $varName = '$relativePath';");
      }
    }
  }

  String _generateVarName(String path) {
    // assets/images/logo.png -> logoPng
    final name = p.basenameWithoutExtension(path);
    final ext = p.extension(path).replaceAll('.', '');
    return ReCase('$name $ext').camelCase;
  }
}
