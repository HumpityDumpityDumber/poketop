import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Handles the --template flag logic.
/// Writes a .themers/app.json file with {"appName": appName} and ensures required directories.
Future<void> handleTemplateFlag(String appName, {bool verbose = false}) async {
  // Prefer .themers/ directory in current working directory
  Directory themersDir = Directory('.themers');
  bool isDev = await themersDir.exists();

  if (!isDev) {
    // Use XDG_CONFIG_HOME or fallback to ~/.config
    final xdgConfigHome = Platform.environment['XDG_CONFIG_HOME'] ??
        path.join(Platform.environment['HOME'] ?? '', '.config');
    themersDir = Directory(path.join(xdgConfigHome, 'poketop', 'themers')); // changed from '.themers' to 'themers'
    if (!await themersDir.exists()) {
      await themersDir.create(recursive: true);
      if (verbose) print('[VERBOSE] Created directory ${themersDir.path}');
    }
    if (verbose) print('[VERBOSE] Using prod mode for themers');
  } else {
    if (verbose) print('[VERBOSE] Using dev mode for .themers');
  }

  // Write the JSON with pretty formatting
  final encoder = JsonEncoder.withIndent('  ');
  final jsonContent = encoder.convert({
    'appName': appName,
    'color_mode': 'hex', // <-- add this line
    'items': {
      'desktopConfig': {
        'location': '$appName.<filetype>.template',
        'destination': '',
        'name': '$appName.<filetype>',
        'type': 'config'
      }
    }
  });

  final themersFile = File(path.join(themersDir.path, '$appName.json'));
  await themersFile.writeAsString(jsonContent);
  if (verbose) print('[VERBOSE] Saved $appName.json to ${themersFile.path}');

  // Ensure directories exist
  final dirsToCreate = [
    path.join(themersDir.path, 'templates'),
    path.join(themersDir.path, 'templates', 'configs'),
    path.join(themersDir.path, 'templates', 'var_assets'),
    path.join(themersDir.path, 'assets'),
  ];
  for (final dirPath in dirsToCreate) {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      if (verbose) print('[VERBOSE] Created directory $dirPath');
    }
  }
}