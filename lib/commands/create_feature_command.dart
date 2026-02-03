import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:recase/recase.dart';
import 'package:getx_clean_arch/getx_clean_arch.dart';
import 'package:yaml/yaml.dart';

class CreateFeatureCommand extends Command<int> {
  final Logger logger;

  CreateFeatureCommand({required this.logger}) {
    argParser.addOption(
      'router',
      abbr: 'r',
      allowed: ['getx', 'go'],
      defaultsTo: 'getx',
      help: 'Router type to use (getx or go).',
    );
  }

  @override
  String get description => 'Create a new feature with GetX structure.';

  @override
  String get name => 'create:feature';

  @override
  Future<int> run() async {
    if (argResults!.rest.isEmpty) {
      logger.err('Feature name is required.');
      return ExitCode.usage.code;
    }

    final featureName = argResults!.rest.first;
    final routerType = argResults!['router'] as String;
    final rc = ReCase(featureName);

    logger.info('Creating feature: ${rc.snakeCase} with router: $routerType');

    final featurePath = 'lib/features/${rc.snakeCase}';

    // 1. Create directories
    FileUtils.createDirectory('$featurePath/bindings', logger: logger);
    FileUtils.createDirectory('$featurePath/controllers', logger: logger);
    FileUtils.createDirectory('$featurePath/dialog', logger: logger);
    FileUtils.createDirectory('$featurePath/models', logger: logger);
    FileUtils.createDirectory('$featurePath/pages', logger: logger);
    FileUtils.createDirectory('$featurePath/widgets', logger: logger);

    // 2. Get Package Name (prefix)
    final packageName = _getPackageName();

    // 3. Create Files
    FileUtils.createFile(
      '$featurePath/bindings/${rc.snakeCase}_binding.dart',
      Templates.binding(featureName, packageName),
      logger: logger,
    );

    FileUtils.createFile(
      '$featurePath/controllers/${rc.snakeCase}_controller.dart',
      Templates.controller(featureName),
      logger: logger,
    );

    FileUtils.createFile(
      '$featurePath/pages/${rc.snakeCase}_page.dart',
      Templates.page(featureName, packageName),
      logger: logger,
    );

    FileUtils.createFile(
      '$featurePath/${rc.snakeCase}.dart',
      Templates.barrel(featureName),
      logger: logger,
    );

    // 4. Auto-register in DI (This is simplified, parsing Dart files is complex without `analyzer`)
    // _updateDI(rc, packageName);

    // 5. Auto-register in Router
    // 5. Auto-register in Router
    _updateRouter(rc, routerType, packageName);

    logger.success('Feature $featureName created successfully!');
    return ExitCode.success.code;
  }

  String _getPackageName() {
    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) {
      return 'getx_clean_arch'; // fallback
    }
    final content = pubspec.readAsStringSync();
    final doc = loadYaml(content);
    return doc['name'] as String;
  }

  void _updateRouter(ReCase rc, String routerType, String packageName) {
    if (routerType == 'getx') {
      _updateGetXRouter(rc, packageName);
    } else if (routerType == 'go') {
      _updateGoRouter(rc, packageName);
    }
  }

  void _updateGetXRouter(ReCase rc, String packageName) {
    final routesFile = File('lib/routes/app_routes.dart');
    final pagesFile = File('lib/routes/app_pages.dart');

    if (!routesFile.existsSync() || !pagesFile.existsSync()) {
      logger.warn('Router files not found. Skipping auto-registration.');
      return;
    }

    // 1. Update Routes
    var routesContent = routesFile.readAsStringSync();
    if (!routesContent.contains('static const ${rc.constantCase}')) {
      // Insert into Routes
      final routesClassEnd = routesContent.indexOf(
        '}\n\nabstract class _Paths',
      );
      if (routesClassEnd != -1) {
        routesContent =
            routesContent.substring(0, routesClassEnd) +
            '  static const ${rc.constantCase} = _Paths.${rc.constantCase};\n' +
            routesContent.substring(routesClassEnd);
      }

      // Insert into _Paths
      final pathsClassEnd = routesContent.lastIndexOf('}');
      if (pathsClassEnd != -1) {
        routesContent =
            routesContent.substring(0, pathsClassEnd) +
            '  static const ${rc.constantCase} = \'/${rc.paramCase}\';\n' +
            routesContent.substring(pathsClassEnd);
      }

      routesFile.writeAsStringSync(routesContent);
      logger.detail('Updated app_routes.dart for GetX');
    }

    // 2. Update Pages
    var pagesContent = pagesFile.readAsStringSync();
    if (!pagesContent.contains('Routes.${rc.constantCase}')) {
      // Add Import
      final featureImport =
          "import 'package:$packageName/features/${rc.snakeCase}/${rc.snakeCase}.dart';";
      if (!pagesContent.contains(featureImport)) {
        pagesContent = "$featureImport\n$pagesContent";
      }

      // Add Page Page
      final pageEntry =
          '''
    GetPage(
      name: _Paths.${rc.constantCase},
      page: () => const ${rc.pascalCase}Page(),
      binding: ${rc.pascalCase}Binding(),
    ),''';

      if (pagesContent.contains('static final routes = [')) {
        pagesContent = pagesContent.replaceFirst(
          'static final routes = [',
          'static final routes = [\n$pageEntry',
        );
      }

      pagesFile.writeAsStringSync(pagesContent);
      logger.detail('Updated app_pages.dart for GetX');
    }
  }

  void _updateGoRouter(ReCase rc, String packageName) {
    final routesFile = File('lib/routes/app_routes.dart');
    final pagesFile = File('lib/routes/app_pages.dart');

    if (!routesFile.existsSync() || !pagesFile.existsSync()) {
      logger.warn('Router files not found. Skipping auto-registration.');
      return;
    }

    // 1. Update Routes
    var routesContent = routesFile.readAsStringSync();
    if (!routesContent.contains('static const String ${rc.camelCase}')) {
      final lastBrace = routesContent.lastIndexOf('}');
      if (lastBrace != -1) {
        routesContent =
            routesContent.substring(0, lastBrace) +
            '  static const String ${rc.camelCase} = \'/${rc.paramCase}\';\n' +
            routesContent.substring(lastBrace);
        routesFile.writeAsStringSync(routesContent);
        logger.detail('Updated app_routes.dart for GoRouter');
      }
    }

    // 2. Update Pages
    var pagesContent = pagesFile.readAsStringSync();
    if (!pagesContent.contains('Routes.${rc.camelCase}')) {
      // Add Import
      final featureImport =
          "import 'package:$packageName/features/${rc.snakeCase}/${rc.snakeCase}.dart';";
      if (!pagesContent.contains(featureImport)) {
        pagesContent = "$featureImport\n$pagesContent";
      }

      // Add GoRoute
      final routeEntry =
          '''
      GoRoute(
        path: Routes.${rc.camelCase},
        name: '${rc.paramCase}',
        builder: (context, state) => const ${rc.pascalCase}Page(),
      ),''';

      if (pagesContent.contains('routes: <RouteBase>[')) {
        pagesContent = pagesContent.replaceFirst(
          'routes: <RouteBase>[',
          'routes: <RouteBase>[\n$routeEntry',
        );
      }

      pagesFile.writeAsStringSync(pagesContent);
      logger.detail('Updated app_pages.dart for GoRouter');
    }
  }
}
