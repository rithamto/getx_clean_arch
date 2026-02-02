import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:getx_clean_arch/getx_clean_arch.dart';

class InitCommand extends Command<int> {
  final Logger logger;

  InitCommand({required this.logger});

  @override
  String get description =>
      'Initialize a new project with GetX Clean Architecture.';

  @override
  String get name => 'init';

  @override
  Future<int> run() async {
    // 1. Verify environment
    if (!await _checkCommand('flutter') || !await _checkCommand('git')) {
      logger.err('Flutter and Git must be installed.');
      return ExitCode.software.code;
    }

    final String? projectName = argResults!.rest.isNotEmpty
        ? argResults!.rest.first
        : null;
    final String basePath = projectName == null ? '.' : projectName;

    if (projectName != null) {
      logger.info('Creating new Flutter project: \$projectName...');
      final createResult = await Process.run('flutter', [
        'create',
        projectName,
      ]);
      if (createResult.exitCode != 0) {
        logger.err(createResult.stderr.toString());
        return createResult.exitCode;
      }
      logger.success('Flutter project created.');

      // Add dependencies
      logger.info('Adding dependencies...');
      await Process.run('flutter', [
        'pub',
        'add',
        'get',
        'dio',
        'flutter_flavorizr',
      ], workingDirectory: basePath);
    } else {
      logger.info('Initializing in current directory...');
    }

    // 3. Create Core Module structure
    _createCoreStructure(basePath);

    // 4. Create DI
    _createDependencyInjection(basePath);

    logger.success('Project initialized successfully!');
    return ExitCode.success.code;
  }

  Future<bool> _checkCommand(String command) async {
    try {
      final result = await Process.run('which', [command]);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  void _createCoreStructure(String basePath) {
    FileUtils.createDirectory('$basePath/lib/core/network', logger: logger);
    FileUtils.createDirectory('$basePath/lib/core/theme', logger: logger);
    FileUtils.createDirectory('$basePath/lib/core/style', logger: logger);

    // Add Dio wrapper or other core files here if needed
    FileUtils.createFile(
      '$basePath/lib/core/network/dio_client.dart',
      _dioClientContent,
      logger: logger,
    );
    FileUtils.createFile(
      '$basePath/lib/core/theme/app_theme.dart',
      '// App Theme',
      logger: logger,
    );
    FileUtils.createFile(
      '$basePath/lib/core/style/app_style.dart',
      '// App Style',
      logger: logger,
    );
  }

  void _createDependencyInjection(String basePath) {
    FileUtils.createFile(
      '$basePath/lib/dependency_injection.dart',
      _diContent,
      logger: logger,
    );
  }

  final String _dioClientContent = '''
import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  // Add methods here
}
''';

  final String _diContent = '''
import 'package:get/get.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Initialize core services here
  }
}
''';
}
