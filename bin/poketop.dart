import 'package:args/args.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'swww_wrapper.dart';
import 'themer_parser.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.')
    ..addOption(
      'swww-arguments',
      help: 'Extra arguments to pass to swww img (e.g. "--transition-type any").',
      valueHelp: 'args',
    )
    ..addOption(
      'template',
      help: 'Save a .themers JSON with the given app name.',
      valueHelp: 'appName',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart poketop.dart <flags> [arguments]');
  print(argParser.usage);
}

Future<Map<String, dynamic>> loadPokemonColors({bool verbose = false}) async {
  final devPath = path.join('assets', 'pokemon_colors.json');
  final devFile = File(devPath);
  if (await devFile.exists()) {
    if (verbose) print('[VERBOSE] Loaded colors from $devPath');
    return jsonDecode(await devFile.readAsString()) as Map<String, dynamic>;
  }

  final xdgDataHome = Platform.environment['XDG_DATA_HOME'] ??
      path.join(Platform.environment['HOME'] ?? '', '.local', 'share');
  final prodPath = path.join(xdgDataHome, 'poketop', 'pokemon_colors.json');
  final prodFile = File(prodPath);
  if (await prodFile.exists()) {
    if (verbose) print('[VERBOSE] Loaded colors from $prodPath');
    return jsonDecode(await prodFile.readAsString()) as Map<String, dynamic>;
  }

  throw Exception('pokemon_colors.json not found in assets or $xdgDataHome/poketop');
}

Future<Map<String, dynamic>> pickRandomPokemon({bool verbose = false}) async {
  final colors = await loadPokemonColors(verbose: verbose);
  final names = colors.keys.toList();
  if (names.isEmpty) {
    throw Exception('No Pokémon found in the colors JSON.');
  }
  final random = Random();
  final chosen = names[random.nextInt(names.length)];
  if (verbose) print('[VERBOSE] Chosen Pokémon: $chosen');
  return {'pokemon': chosen, 'color': colors[chosen]};
}

Future<void> saveResult(String pokemon, dynamic color, {bool verbose = false}) async {
  final devDir = Directory('.data');
  String savePath;
  if (await devDir.exists()) {
    savePath = path.join('.data', 'poketop_result.json');
    if (verbose) print('[VERBOSE] Saving result to $savePath');
  } else {
    final xdgDataHome = Platform.environment['XDG_DATA_HOME'] ??
        path.join(Platform.environment['HOME'] ?? '', '.local', 'share');
    final prodDir = Directory(path.join(xdgDataHome, 'poketop'));
    if (!await prodDir.exists()) {
      await prodDir.create(recursive: true);
      if (verbose) print('[VERBOSE] Created directory ${prodDir.path}');
    }
    savePath = path.join(prodDir.path, 'poketop_result.json');
    if (verbose) print('[VERBOSE] Saving result to $savePath');
  }
  final result = {'pokemon': pokemon, 'color': color};
  await File(savePath).writeAsString(jsonEncode(result));
}

// Add this function to resolve the wallpaper path
Future<String?> findWallpaper(String pokemon, {bool verbose = false}) async {
  final devPath = path.join('assets', 'wallpapers', '$pokemon.jpg');
  if (await File(devPath).exists()) {
    if (verbose) print('[VERBOSE] Found wallpaper at $devPath');
    return devPath;
  }
  final xdgDataHome = Platform.environment['XDG_DATA_HOME'] ??
      path.join(Platform.environment['HOME'] ?? '', '.local', 'share');
  final prodPath = path.join(xdgDataHome, 'poketop', 'wallpapers', '$pokemon.jpg');
  if (await File(prodPath).exists()) {
    if (verbose) print('[VERBOSE] Found wallpaper at $prodPath');
    return prodPath;
  }
  if (verbose) print('[VERBOSE] Wallpaper not found for $pokemon');
  return null;
}



void main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    if (results['help'] as bool) {
      printUsage(argParser);
      return;
    }
    if (results['version'] as bool) {
      print('poketop version: $version');
      return;
    }
    if (results['verbose'] as bool) {
      verbose = true;
    }

    // Handle --template flag
    final templateAppName = results['template'] as String?;
    if (templateAppName != null && templateAppName.isNotEmpty) {
      await handleTemplateFlag(templateAppName, verbose: verbose);
      print('Template .themers created for appName: $templateAppName');
      return;
    }

    final picked = await pickRandomPokemon(verbose: verbose);
    await saveResult(picked['pokemon'], picked['color'], verbose: verbose);

    // Find wallpaper and run swww if found
    final wallpaperPath = await findWallpaper(picked['pokemon'], verbose: verbose);
    if (wallpaperPath != null) {
      final swwwArgs = results['swww-arguments'] as String?;
      await ensureSwwwDaemon(verbose: verbose); // <-- Add this line
      await runSwww(wallpaperPath, extraArgs: swwwArgs, verbose: verbose);
    } else {
      print('Wallpaper not found for ${picked['pokemon']}');
    }

    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }
  } on FormatException catch (e) {
    print(e.message);
    print('');
    printUsage(argParser);
    exit(64); // EX_USAGE - command line usage error
  } on Exception catch (e) {
    print('Error: $e');
    exit(1);
  }
}