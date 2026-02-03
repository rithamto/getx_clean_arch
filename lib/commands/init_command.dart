import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:getx_clean_arch/getx_clean_arch.dart';

class InitCommand extends Command<int> {
  final Logger logger;

  InitCommand({required this.logger}) {
    argParser.addOption(
      'router',
      abbr: 'r',
      allowed: ['getx', 'go'],
      defaultsTo: 'getx',
      help: 'Router type to use (getx or go).',
    );
  }

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
    final String routerType = argResults!['router'] as String;

    logger.info('Using router: $routerType');

    // Determine base path - convert to absolute path for new projects
    String basePath;
    String importPrefix;

    if (projectName != null) {
      logger.info('Creating new Flutter project: $projectName...');
      final createResult = await Process.run('flutter', [
        'create',
        projectName,
      ]);
      if (createResult.exitCode != 0) {
        logger.err(createResult.stderr.toString());
        return createResult.exitCode;
      }
      logger.success('Flutter project created.');

      // Use absolute path for the new project
      basePath = Directory(projectName).absolute.path;
      importPrefix = projectName;
    } else {
      logger.info('Initializing in current directory...');
      basePath = Directory.current.path;
      importPrefix = await _getPackageNameFromPubspec(basePath);
    }

    logger.detail('Working directory: $basePath');

    // Add dependencies
    await _addDependencies(basePath, routerType);

    // 3. Create Core Module structure
    _createCoreStructure(basePath, importPrefix);

    // 4. Create DI
    _createDependencyInjection(basePath, routerType);

    // 5. Create Router
    _createRouterStructure(basePath, routerType, importPrefix);

    // 6. Create App Entry Point (app.dart and main.dart)
    _createAppEntryPoint(basePath, importPrefix, routerType);

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

  void _createDependencyInjection(String basePath, String routerType) {
    final diContent = routerType == 'getx'
        ? _diContentGetX
        : _diContentGoRouter;
    FileUtils.createFile(
      '$basePath/lib/dependency_injection.dart',
      diContent,
      logger: logger,
    );
  }

  void _createRouterStructure(
    String basePath,
    String routerType,
    String importPrefix,
  ) {
    FileUtils.createDirectory('$basePath/lib/routes', logger: logger);

    if (routerType == 'getx') {
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
    } else {
      // GoRouter
      FileUtils.createFile(
        '$basePath/lib/routes/app_routes.dart',
        Templates.appRoutesGoRouter,
        logger: logger,
      );
      FileUtils.createFile(
        '$basePath/lib/routes/app_pages.dart',
        Templates.appPagesGoRouter(importPrefix),
        logger: logger,
      );
    }
  }

  final String _dioClientContent = '''
import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  // Add methods here
}
''';

  final String _diContentGetX = '''
import 'package:get/get.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Initialize core services here
  }
}
''';

  final String _diContentGoRouter = '''
class DependencyInjection {
  static Future<void> init() async {
    // Initialize core services here
  }
}
''';

  void _createAppEntryPoint(
    String basePath,
    String importPrefix,
    String routerType,
  ) {
    final appTemplate = routerType == 'getx'
        ? Templates.app(importPrefix)
        : Templates.appGoRouter(importPrefix);

    FileUtils.createFile('$basePath/lib/app.dart', appTemplate, logger: logger);
    FileUtils.createFile(
      '$basePath/lib/main.dart',
      Templates.main(importPrefix),
      logger: logger,
      overwrite: true,
    );
  }

  /// Add dependencies to the project
  Future<void> _addDependencies(String basePath, String routerType) async {
    logger.info('Adding dependencies...');

    // Core dependencies
    final dependencies = ['dio', 'firebase_core', 'google_fonts', 'get'];

    // Add router-specific dependencies
    if (routerType == 'go') {
      dependencies.add('go_router');
    }

    // Run flutter pub add for pub packages
    await Process.run('flutter', [
      'pub',
      'add',
      ...dependencies,
    ], workingDirectory: basePath);

    // Add dev dependencies
    await Process.run('flutter', [
      'pub',
      'add',
      '--dev',
      'flutter_flavorizr',
    ], workingDirectory: basePath);

    logger.detail('Added pub dependencies: ${dependencies.join(', ')}');
    logger.detail('Added dev dependencies: flutter_flavorizr');

    // Add flutter_localizations as SDK dependency
    await _addFlutterLocalizationsDependency(basePath);
  }

  /// Add flutter_localizations SDK dependency to pubspec.yaml
  Future<void> _addFlutterLocalizationsDependency(String basePath) async {
    final pubspecFile = File('$basePath/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      logger.warn('pubspec.yaml not found, skipping flutter_localizations.');
      return;
    }

    var content = await pubspecFile.readAsString();

    // Check if flutter_localizations already exists
    if (content.contains('flutter_localizations:')) {
      logger.detail('flutter_localizations already present.');
      return;
    }

    // Find the flutter SDK dependency and add flutter_localizations after it
    final flutterSdkPattern = RegExp(
      r'(flutter:\s*\n\s*sdk:\s*flutter)',
      multiLine: true,
    );

    if (flutterSdkPattern.hasMatch(content)) {
      content = content.replaceFirstMapped(flutterSdkPattern, (match) {
        return '''${match.group(0)}
  flutter_localizations:
    sdk: flutter''';
      });
      await pubspecFile.writeAsString(content);
      logger.detail('Added flutter_localizations SDK dependency.');
    } else {
      logger.warn('Could not find flutter SDK dependency in pubspec.yaml.');
    }
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

    // Create google_services.json for each flavor
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
      if (!content.contains('\nflavorizr:')) {
        await pubspecFile.writeAsString(content + Templates.flavorizrConfig);
        logger.detail('Added flavorizr configuration to pubspec.yaml');

        // Run pub get to ensure flavorizr config is recognized
        await Process.run('flutter', [
          'pub',
          'get',
        ], workingDirectory: basePath);
      }
    }

    logger.success('Firebase configuration created.');
  }

  Future<void> _runFlavorizr(String basePath) async {
    logger.info('Running flutter_flavorizr...');

    try {
      final process = await Process.start(
        'dart',
        ['run', 'flutter_flavorizr', '-f'],
        workingDirectory: basePath,
        runInShell: true,
      );

      // Stream output to the logger
      process.stdout.transform(utf8.decoder).listen((data) {
        logger.detail(data.trim());
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        logger.err(data.trim());
      });

      final exitCode = await process.exitCode;

      if (exitCode == 0) {
        logger.success('Flavorizr completed successfully.');
      } else {
        logger.warn('Flavorizr failed with exit code $exitCode.');
        logger.warn('You may need to run it manually:');
        logger.warn('  cd $basePath && flutter pub run flutter_flavorizr');
      }
    } catch (e) {
      logger.err('Failed to start Flavorizr: $e');
      logger.warn('You may need to run it manually:');
      logger.warn('  cd $basePath && flutter pub run flutter_flavorizr');
    }
  }
}
