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
    // _updateRouter(rc, routerType, packageName);

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
}
