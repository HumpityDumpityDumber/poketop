## Poketop

Poketop is a command-line tool that randomly selects a Pokémon, saves the result to a JSON file, and sets your desktop wallpaper to a themed image of the chosen Pokémon using the `swww` wallpaper daemon. It supports both development and production environments, searching for wallpapers in local assets or in your XDG data directory. The tool also supports extra arguments for `swww img` and provides verbose output for debugging.

### Features
- Randomly picks a Pokémon from a color list
- Saves the result (Pokémon and color) to a JSON file
- Finds and sets a wallpaper for the chosen Pokémon using `swww`
- Automatically starts the `swww-daemon` if not running
- Supports extra arguments for `swww img` via `--swww-arguments`

### Usage
Run the app from the command line:

```sh
poketop

Options include:

    -h, --help — Show usage

    -v, --verbose — Verbose output

    --version — Show version

    --swww-arguments — Extra arguments for swww img
```

### License

This project is licensed under the GNU General Public License v3.0. See the LICENSE file for details.

This project uses wallpapers from giorgosioak/pokemon-wallpapers, which are licensed under the GNU General Public License v3.0.


Let me know if you want to [dynamically download wallpapers at runtime](f) or [structure your repo to separate assets cleanly](f).
