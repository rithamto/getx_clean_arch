import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:getx_clean_arch/getx_clean_arch.dart';
import 'package:getx_clean_arch/common/templates/templates.dart';

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
    final String importPrefix =
        projectName ?? await _getPackageNameFromPubspec(basePath);

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
    _createCoreStructure(basePath, importPrefix);

    // 4. Create DI
    _createDependencyInjection(basePath);

    // 5. Create Router
    _createRouterStructure(basePath);

    // 6. Create App Entry Point (app.dart and main.dart)
    _createAppEntryPoint(basePath, importPrefix);

    // 7. Create Firebase Config
    await _createFirebaseConfig(basePath, importPrefix);

    // 8. Run Flavorizr
    await _runFlavorizr(basePath);

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

  void _createCoreStructure(String basePath, String importPrefix) {
    FileUtils.createDirectory('$basePath/lib/core/network', logger: logger);

    // Dio wrapper
    FileUtils.createFile(
      '$basePath/lib/core/network/dio_client.dart',
      _dioClientContent,
      logger: logger,
    );

    // Theme structure
    FileUtils.createDirectory('$basePath/lib/common/themes', logger: logger);
    FileUtils.createFile(
      '$basePath/lib/common/themes/m_color.dart',
      Templates.mColors(),
      logger: logger,
    );
    FileUtils.createFile(
      '$basePath/lib/common/themes/m_text_theme.dart',
      Templates.mTextTheme(importPrefix),
      logger: logger,
    );
    FileUtils.createFile(
      '$basePath/lib/common/themes/m_theme.dart',
      Templates.mTheme(importPrefix),
      logger: logger,
    );
    FileUtils.createFile(
      '$basePath/lib/common/themes/themes.dart',
      Templates.themesBarrel,
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

  void _createRouterStructure(String basePath) {
    FileUtils.createDirectory('$basePath/lib/routes', logger: logger);
    FileUtils.createFile(
      '$basePath/lib/routes/app_routes.dart',
      Templates.appRoutes,
      logger: logger,
    );
    FileUtils.createFile(
      '$basePath/lib/routes/app_pages.dart',
      Templates.appPages,
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

  void _createAppEntryPoint(String basePath, String importPrefix) {
    FileUtils.createFile(
      '$basePath/lib/app.dart',
      Templates.app(importPrefix),
      logger: logger,
    );
    FileUtils.createFile(
      '$basePath/lib/main.dart',
      Templates.main(importPrefix),
      logger: logger,
      overwrite: true,
    );
  }

  Future<String> _getPackageNameFromPubspec(String basePath) async {
    final pubspecFile = File('$basePath/pubspec.yaml');
    if (await pubspecFile.exists()) {
      final content = await pubspecFile.readAsString();
      final nameMatch = RegExp(
        r'^name:\s*(.+)$',
        multiLine: true,
      ).firstMatch(content);
      if (nameMatch != null) {
        return nameMatch.group(1)!.trim();
      }
    }
    return 'my_app';
  }

  Future<void> _createFirebaseConfig(
    String basePath,
    String importPrefix,
  ) async {
    logger.info('Creating Firebase configuration...');

    // Create .firebase directory structure
    FileUtils.createDirectory('$basePath/.firebase/dev', logger: logger);
    FileUtils.createDirectory('$basePath/.firebase/prod', logger: logger);

    // Create google-services.json for each flavor
    FileUtils.createFile(
      '$basePath/.firebase/dev/google-services.json',
      Templates.googleServicesJson('dev'),
      logger: logger,
    );
    FileUtils.createFile(
      '$basePath/.firebase/prod/google-services.json',
      Templates.googleServicesJson('prod'),
      logger: logger,
    );

    // Create GoogleService-Info.plist for each flavor
    FileUtils.createFile(
      '$basePath/.firebase/dev/GoogleService-Info.plist',
      Templates.googleServiceInfoPlist('dev'),
      logger: logger,
    );
    FileUtils.createFile(
      '$basePath/.firebase/prod/GoogleService-Info.plist',
      Templates.googleServiceInfoPlist('prod'),
      logger: logger,
    );

    // Create firebase_options.dart
    FileUtils.createFile(
      '$basePath/lib/firebase_options.dart',
      Templates.firebaseOptions(importPrefix),
      logger: logger,
    );

    // Append flavorizr config to pubspec.yaml
    final pubspecFile = File('$basePath/pubspec.yaml');
    if (await pubspecFile.exists()) {
      final content = await pubspecFile.readAsString();
      if (!content.contains('flavorizr:')) {
        await pubspecFile.writeAsString(content + Templates.flavorizrConfig);
        logger.detail('Added flavorizr configuration to pubspec.yaml');
      }
    }

    logger.success('Firebase configuration created.');
  }

  Future<void> _runFlavorizr(String basePath) async {
    logger.info('Running flutter_flavorizr...');

    final result = await Process.run('flutter', [
      'pub',
      'run',
      'flutter_flavorizr',
    ], workingDirectory: basePath);

    if (result.exitCode == 0) {
      logger.success('Flavorizr completed successfully.');
    } else {
      logger.warn('Flavorizr failed. You may need to run it manually:');
      logger.warn('  cd $basePath && flutter pub run flutter_flavorizr');
      logger.detail(result.stderr.toString());
    }
  }
}
