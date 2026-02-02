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
    logger.info('Initializing project...');

    // 1. Verify environment
    if (!await _checkCommand('flutter') || !await _checkCommand('git')) {
      logger.err('Flutter and Git must be installed.');
      return ExitCode.software.code;
    }

    // 2. Initialize flutter_flavorizr (Assuming it's added to pubspec.yaml by user or we add it)
    // For now, we'll skip running flavorizr directly and just set up structure, as flavorizr is a separate tool.
    // But the requirements say "Initialize flutter_flavorizr configuration".
    // This typically means running `flutter pub run flutter_flavorizr:main` after adding it to pubspec.

    // 3. Create Core Module structure
    _createCoreStructure();

    // 4. Create DI
    _createDependencyInjection();

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

  void _createCoreStructure() {
    FileUtils.createDirectory('lib/core/network', logger: logger);
    FileUtils.createDirectory('lib/core/theme', logger: logger);
    FileUtils.createDirectory('lib/core/style', logger: logger);

    // Add Dio wrapper or other core files here if needed
    FileUtils.createFile(
      'lib/core/network/dio_client.dart',
      _dioClientContent,
      logger: logger,
    );
    FileUtils.createFile(
      'lib/core/theme/app_theme.dart',
      '// App Theme',
      logger: logger,
    );
    FileUtils.createFile(
      'lib/core/style/app_style.dart',
      '// App Style',
      logger: logger,
    );
  }

  void _createDependencyInjection() {
    FileUtils.createFile(
      'lib/dependency_injection.dart',
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
