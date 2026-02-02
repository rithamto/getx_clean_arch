import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class GitBranchCommand extends Command<int> {
  final Logger logger;

  GitBranchCommand({required this.logger});

  @override
  String get description => 'Shortcut for git checkout -b <branch_name>.';

  @override
  String get name => 'git:branch';

  @override
  Future<int> run() async {
    if (argResults!.rest.isEmpty) {
      logger.err('Branch name is required.');
      return ExitCode.usage.code;
    }

    final branchName = argResults!.rest.first;
    logger.info('Checking out new branch: $branchName');

    final result = await Process.run('git', ['checkout', '-b', branchName]);
    if (result.exitCode != 0) {
      logger.err(result.stderr as String);
      return result.exitCode;
    }

    logger.success('Switched to branch $branchName');
    return ExitCode.success.code;
  }
}
