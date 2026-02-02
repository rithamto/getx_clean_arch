import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:getx_clean_arch/commands/init_command.dart';
import 'package:getx_clean_arch/commands/create_feature_command.dart';
import 'package:getx_clean_arch/commands/refresh_command.dart';
import 'package:getx_clean_arch/commands/git_branch_command.dart';
import 'package:getx_clean_arch/commands/generate_assets_command.dart';
import 'package:getx_clean_arch/commands/run_flavor_command.dart';

Future<void> main(List<String> args) async {
  final logger = Logger();
  final runner =
      CommandRunner<int>(
          'getxcli',
          'A CLI tool for scaffolding and managing Flutter projects with GetX and Clean Architecture.',
        )
        ..argParser.addFlag(
          'version',
          negatable: false,
          help: 'Print the current version.',
        )
        ..addCommand(InitCommand(logger: logger))
        ..addCommand(CreateFeatureCommand(logger: logger))
        ..addCommand(RefreshCommand(logger: logger))
        ..addCommand(GitBranchCommand(logger: logger))
        ..addCommand(GenerateAssetsCommand(logger: logger))
        ..addCommand(RunFlavorCommand(logger: logger));

  try {
    final exitCode = await runner.run(args);
    exit(exitCode ?? 0);
  } catch (e) {
    if (e is UsageException) {
      logger.err(e.message);
      logger.info(e.usage);
    } else {
      logger.err(e.toString());
    }
    exit(1);
  }
}
