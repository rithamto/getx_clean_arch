import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class RunFlavorCommand extends Command<int> {
  final Logger logger;

  RunFlavorCommand({required this.logger});

  @override
  String get description =>
      'Run flutter run --flavor <flavor> -t lib/main_<flavor>.dart.';

  @override
  String get name => 'run:flavor';

  @override
  Future<int> run() async {
    if (argResults!.rest.isEmpty) {
      logger.err('Flavor name is required.');
      return ExitCode.usage.code;
    }

    final flavor = argResults!.rest.first;
    final target = 'lib/main_$flavor.dart';

    logger.info('Running flavor: $flavor');

    // We replace the current process with flutter run
    // Simple Process.start to stream output would be better for interactive run

    final process = await Process.start('flutter', [
      'run',
      '--flavor',
      flavor,
      '-t',
      target,
    ], mode: ProcessStartMode.inheritStdio);

    final exitCode = await process.exitCode;
    return exitCode;
  }
}
