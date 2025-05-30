## Poketop

Poketop is a command-line tool that randomly selects a Pokémon, saves the result to a JSON file, and sets your desktop wallpaper to a themed image of the chosen Pokémon using the `swww` wallpaper daemon. It supports both development and production environments, searching for wallpapers in local assets or in your XDG data directory. The tool also supports extra arguments for `swww img` and provides verbose output for debugging.

### Features
- Randomly picks a Pokémon from a color list
- Saves the result (Pokémon and color) to a JSON file
- Finds and sets a wallpaper for the chosen Pokémon using `swww`
- Automatically starts the `swww-daemon` if not running
- Supports extra arguments for `swww img` via `--swww-arguments`
- Works in both dev (assets/) and prod (XDG data) environments

### Usage
Run the app from the command line:

```sh
dart run bin/poketop.dart [options]
```

Options include:
- `-h`, `--help` — Show usage
- `-v`, `--verbose` — Verbose output
- `--version` — Show version
- `--swww-arguments` — Extra arguments for `swww img`

---

## TODO
- [ ] Add `config_templates/` file and add config template parser and executor
