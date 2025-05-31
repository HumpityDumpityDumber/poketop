## Poketop

### Features
- Randomly picks a Pokémon from a color list
- Saves the result (Pokémon and color) to a JSON file
- Finds and sets a wallpaper for the chosen Pokémon using `swww`
- Automatically starts the `swww-daemon` if not running
- Supports extra arguments for `swww img` via `--swww-arguments`
- **All theming, asset, and wallpaper operations are performed locally on your machine. No network or remote operations are performed by this program.**

### Installation

#### Install Dart

If you do not already have Dart installed, follow the instructions at [https://dart.dev/get-dart](https://dart.dev/get-dart) or:

- **On Arch Linux:**
  ```sh
  sudo pacman -S dart
  ```
- **On Debian/Ubuntu:**
  ```sh
  sudo apt install dart
  ```
- **On Fedora:**
  ```sh
  sudo dnf install dart
  ```

#### Dependencies

- [Dart SDK](https://dart.dev/get-dart) (>=3.8.0)
- [swww](https://github.com/LGFae/swww) (for wallpaper setting)
- (Optional, only for SVG-to-PNG/JPG conversion in var_asset): `rsvg-convert` (from `librsvg`/`librsvg2-bin`)

#### Install Steps (Local/User Install, No sudo needed)

1. **Clone the repository:**
   ```sh
   git clone https://github.com/HumpityDumpityDumber/poketop.git
   cd poketop
   ```

2. **Install Dart dependencies:**
   ```sh
   dart pub get
   ```

3. **Compile the binary:**
   ```sh
   dart compile exe bin/poketop.dart -o poketop
   ```

4. **Copy the binary to your user-local bin directory:**
   ```sh
   mkdir -p ~/.local/bin
   cp poketop ~/.local/bin/
   ```

5. **Ensure `~/.local/bin` is in your PATH (add to your shell profile if needed):**
   ```sh
   export PATH="$HOME/.local/bin:$PATH"
   # Add the above line to your ~/.bashrc, ~/.zshrc, or ~/.profile for persistence
   ```

6. **Copy the contents of the assets folder to your XDG data home:**
   ```sh
   export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
   mkdir -p "$XDG_DATA_HOME/poketop"
   cp -r assets/* "$XDG_DATA_HOME/poketop/"
   ```

7. **Ensure `swww` is installed:**
   - On Arch Linux:  
     ```sh
     sudo pacman -S swww
     ```
   - On Debian/Ubuntu:  
     ```sh
     sudo apt install swww
     ```
   - On Fedora:  
     ```sh
     sudo dnf install swww
     ```

8. **(Optional, for SVG-to-PNG/JPG conversion in var_asset):**
   - On Arch Linux:  
     ```sh
     sudo pacman -S librsvg
     ```
   - On Debian/Ubuntu:  
     ```sh
     sudo apt install librsvg2-bin
     ```
   - On Fedora:  
     ```sh
     sudo dnf install librsvg2-tools
     ```

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

    -p, --pokemon - choose pokemon instead of it being randomly selected
```

**If you would like to use the project and want proper documentation on configuring the automatic theming feel free to dm `raurutuchr` on discord.**

### License

This project is licensed under the GNU General Public License v3.0. See the LICENSE file for details.

This project uses wallpapers from [giorgosioak/pokemon-wallpapers](https://github.com/giorgosioak/pokemon-wallpapers), which are licensed under the GNU General Public License v3.0.

**Let me know if you want to dynamically download wallpapers at runtime or clone at installation of my application.**
