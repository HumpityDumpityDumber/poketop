## Poketop

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
```

Options include:

```
    -h, --help — Show usage

    -v, --verbose — Verbose output

    --version — Show version

    --swww-arguments — Extra arguments for swww img

    --template <app name> - Creates themer file for application
```

**If you would like to use the project and want proper documentation on configuring the automatic theming feel free to dm `raurutuchr` on discord.**

### License

This project is licensed under the GNU General Public License v3.0. See the LICENSE file for details.

This project uses wallpapers from [giorgosioak/pokemon-wallpapers](https://github.com/giorgosioak/pokemon-wallpapers), which are licensed under the GNU General Public License v3.0.


**Let me know if you want to dynamically download wallpapers at runtime or clone at installation of my application.**
