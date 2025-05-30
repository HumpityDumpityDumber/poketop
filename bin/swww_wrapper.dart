import 'dart:io';

Future<bool> isSwwwDaemonRunning({bool verbose = false}) async {
  final result = await Process.run('pgrep', ['-x', 'swww-daemon']);
  return result.exitCode == 0;
}

Future<void> ensureSwwwDaemon({bool verbose = false}) async {
  if (await isSwwwDaemonRunning(verbose: verbose)) {
    if (verbose) print('[VERBOSE] swww-daemon is already running.');
    return;
  }
  if (verbose) print('[VERBOSE] Starting swww-daemon (detached)...');
  await Process.start(
    'swww-daemon',
    [],
    mode: ProcessStartMode.detached,
  );
  if (verbose) print('[VERBOSE] swww-daemon started (detached)');
}

Future<void> runSwww(String imagePath, {String? extraArgs, bool verbose = false}) async {
  final args = ['img'];
  if (extraArgs != null && extraArgs.trim().isNotEmpty) {
    args.addAll(extraArgs.split(' '));
  }
  args.add(imagePath);
  if (verbose) print('[VERBOSE] Running: swww [1m${args.join(' ')}[0m');
  final result = await Process.run('swww', args);
  if (result.exitCode != 0) {
    print('swww error: ${result.stderr}');
  } else if (verbose) {
    print('[VERBOSE] swww output: ${result.stdout}');
  }
}
