import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class RefreshCommand extends Command<int> {
  final Logger logger;

  RefreshCommand({required this.logger});

  @override
  String get description => 'Run flutter clean && flutter pub get.';

  @override
  String get name => 'refresh';

  @override
  Future<int> run() async {
    logger.info('Running flutter clean...');
    final clean = await Process.run('flutter', ['clean']);
    if (clean.exitCode != 0) {
      logger.err(clean.stderr as String);
      return clean.exitCode;
    }

    logger.info('Running flutter pub get...');
    final pubGet = await Process.run('flutter', ['pub', 'get']);
    if (pubGet.exitCode != 0) {
      logger.err(pubGet.stderr as String);
      return pubGet.exitCode;
    }

    logger.success('Refresh successful!');
    return ExitCode.success.code;
  }
}
