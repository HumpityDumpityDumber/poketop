import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Returns the themers directory and a bool indicating dev mode.
Future<(Directory, bool)> getThemersDir() async {
  final devDir = Directory('.themers');
  if (await devDir.exists()) {
    return (devDir, true);
  }
  final xdgConfigHome = Platform.environment['XDG_CONFIG_HOME'] ??
      path.join(Platform.environment['HOME'] ?? '', '.config');
  final prodDir = Directory(path.join(xdgConfigHome, 'poketop', 'themers'));
  return (prodDir, false);
}

/// Returns the data directory and a bool indicating dev mode.
Future<(Directory, bool)> getDataDir() async {
  final devDir = Directory('.data');
  if (await devDir.exists()) {
    return (devDir, true);
  }
  final xdgDataHome = Platform.environment['XDG_DATA_HOME'] ??
      path.join(Platform.environment['HOME'] ?? '', '.local', 'share');
  final prodDir = Directory(path.join(xdgDataHome, 'poketop'));
  return (prodDir, false);
}

/// Loads the poketop_result.json (pokemon and color).
Future<Map<String, dynamic>> loadResultJson() async {
  final (dataDir, _) = await getDataDir();
  final file = File(path.join(dataDir.path, 'poketop_result.json'));
  if (!await file.exists()) {
    throw Exception('poketop_result.json not found in ${dataDir.path}');
  }
  return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
}

/// Returns the wallpaper path for the given pokemon name.
Future<String> getWallpaperPath(String pokemonName, bool devMode) async {
  if (devMode) {
    return path.join('assets', 'wallpapers', '$pokemonName.jpg');
  }
  final xdgDataHome = Platform.environment['XDG_DATA_HOME'] ??
      path.join(Platform.environment['HOME'] ?? '', '.local', 'share');
  return path.join(xdgDataHome, 'poketop', 'wallpapers', '$pokemonName.jpg');
}

/// Replaces variables in the template string.
String replaceVars(
  String template,
  Map<String, String> replacements,
) {
  String result = template;
  replacements.forEach((key, value) {
    result = result.replaceAll(key, value);
  });
  return result;
}

/// Converts a hex color string to the requested color mode.
String convertColor(String hex, String mode) {
  // Remove leading #
  String h = hex.startsWith('#') ? hex.substring(1) : hex;
  if (h.length == 3) {
    // Expand shorthand (e.g. #abc -> #aabbcc)
    h = h.split('').map((c) => '$c$c').join();
  }
  if (h.length == 6) h = h + 'FF'; // Add alpha if missing

  int r = int.parse(h.substring(0, 2), radix: 16);
  int g = int.parse(h.substring(2, 4), radix: 16);
  int b = int.parse(h.substring(4, 6), radix: 16);
  int a = int.parse(h.substring(6, 8), radix: 16);

  switch (mode.toLowerCase()) {
    case 'hex':
      return '#${h.substring(0, 6)}';
    case 'rgb':
      return 'rgb($r, $g, $b)';
    case 'rgba':
      String alpha = (a / 255).toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
      return 'rgba($r, $g, $b, $alpha)';
    case 'rrggbbaa':
      return '#$h';
    default:
      return '#${h.substring(0, 6)}';
  }
}

/// Main function to process all themers configs.
Future<void> processThemersConfigs({bool verbose = false}) async {
  final (themersDir, devMode) = await getThemersDir();
  if (!await themersDir.exists()) return;
  final themersFiles = themersDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList();

  if (themersFiles.isEmpty) return;

  final resultJson = await loadResultJson();
  final pokemonName = resultJson['pokemon']?.toString() ?? '';
  final pokemonColor = resultJson['color']?.toString() ?? '';
  final wallpaperPath = await getWallpaperPath(pokemonName, devMode);

  for (final file in themersFiles) {
    final themers = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final colorMode = (themers['color_mode'] as String?)?.toLowerCase() ?? 'hex';
    final vars = (themers['vars'] as Map?)?.cast<String, String>() ?? {};
    final items = themers['items'] as Map<String, dynamic>? ?? {};

    // Convert color to requested mode
    final convertedColor = convertColor(pokemonColor, colorMode);

    for (final item in items.values) {
      if (item['type'] == 'config') {
        // Template is in templates/configs/ subdir for config type
        final templatePath = path.join(
          themersDir.path,
          'templates',
          'configs',
          item['location'] as String,
        );
        if (!await File(templatePath).exists()) {
          if (verbose) print('[VERBOSE] Template not found: $templatePath');
          continue;
        }
        String template = await File(templatePath).readAsString();

        // Prepare replacements
        final replacements = <String, String>{
          r'$POKEMON_COLOR': convertedColor,
          r'$POKEMON_NAME': pokemonName,
          r'$WALLPAPER_PATH': wallpaperPath,
          ...vars,
        };

        final parsed = replaceVars(template, replacements);

        // Write to destination
        final destDir = Directory(item['destination'] as String);
        if (!await destDir.exists()) {
          await destDir.create(recursive: true);
        }
        final destPath = path.join(destDir.path, item['name'] as String);
        await File(destPath).writeAsString(parsed);
        if (verbose) {
          print('[VERBOSE] Wrote config to $destPath');
        }
      } else if (item['type'] == 'asset') {
        // Asset is in assets/ subdir of themers folder
        final assetPath = path.join(
          themersDir.path,
          'assets',
          item['location'] as String,
        );
        if (!await File(assetPath).exists()) {
          if (verbose) print('[VERBOSE] Asset not found: $assetPath');
          continue;
        }
        final destDir = Directory(item['destination'] as String);
        if (!await destDir.exists()) {
          await destDir.create(recursive: true);
        }
        final destPath = path.join(destDir.path, item['name'] as String);
        await File(assetPath).copy(destPath);
        if (verbose) {
          print('[VERBOSE] Copied asset to $destPath');
        }
      } else if (item['type'] == 'var_asset') {
        // Template is in templates/var_assets/ subdir for var_asset type
        final templatePath = path.join(
          themersDir.path,
          'templates',
          'var_assets',
          item['location'] as String,
        );
        if (!await File(templatePath).exists()) {
          if (verbose) print('[VERBOSE] Var asset template not found: $templatePath');
          continue;
        }
        String template = await File(templatePath).readAsString();

        // Prepare replacements (same as config)
        final replacements = <String, String>{
          r'$POKEMON_COLOR': convertedColor,
          r'$POKEMON_NAME': pokemonName,
          r'$WALLPAPER_PATH': wallpaperPath,
          ...vars,
        };

        final parsed = replaceVars(template, replacements);

        final destDir = Directory(item['destination'] as String);
        if (!await destDir.exists()) {
          await destDir.create(recursive: true);
        }
        final destPath = path.join(destDir.path, item['name'] as String);

        final ext = path.extension(destPath).toLowerCase();
        if (ext == '.svg') {
          await File(destPath).writeAsString(parsed);
          if (verbose) print('[VERBOSE] Wrote var_asset SVG to $destPath');
        } else if (ext == '.png' || ext == '.jpg' || ext == '.jpeg') {
          // Write to a temp SVG, then convert using rsvg-convert
          final tmpSvg = '$destPath.tmp.svg';
          await File(tmpSvg).writeAsString(parsed);
          final format = ext == '.png' ? 'png' : 'jpeg';
          final result = await Process.run(
            'rsvg-convert',
            ['-f', format, '-o', destPath, tmpSvg],
          );
          await File(tmpSvg).delete();
          if (result.exitCode != 0) {
            print('Error converting SVG to $ext: ${result.stderr}');
            continue;
          }
          if (verbose) print('[VERBOSE] Converted var_asset SVG to $destPath');
        } else {
          // Default: just write as text
          await File(destPath).writeAsString(parsed);
          if (verbose) print('[VERBOSE] Wrote var_asset as text to $destPath');
        }
      }
      // ...other types can be handled here...
    }
  }
}
