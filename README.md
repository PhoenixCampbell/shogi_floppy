# Shogi Game

## Overview

This is a Shogi game developed using Turbo Pascal originally for the Amstrad PPC. It should also work for any other system that can run Pascal but was specifically sized and filed to run on a 3.5" 720kB DD Floppy Disk. The game includes single-player mode against three different levels of AI opponents and two-player local multiplayer mode. Additionally, it supports saving and loading games to disk.

## Table of Contents

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Clone the Repository](#clone-the-repository)
  - [Copy Files to Floppy Disk](#copy-files-to-floppy-disk)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Contributing](#contributing)

## Getting Started

### Prerequisites

Ensure you have the following installed:

- Turbo Pascal / Free Pascal (compatible with Amstrad PPC or similar newer systems)
  - Link to which is in [Usage](#usage)

### Clone the Repository

1. Open terminal or command prompt.
2. Navigate to directory where you want to clone the repository.
3. Run the following command to clone and move to repository directory:

   ```sh
   git clone https://github.com/PhoenixCampbell/shogi_floppy.git
   cd shogi-game
   ```

### Copy Files to Floppy Disk

(This step is only necessary if using systems like the Amstrad PPC. Otherwise once the pascal compiler is installed, you are good to go.)

1. Navigate to the `src` folder in your local copy of the project:

   ```sh
   cd src
   ```

2. Copy all files from this directory to your floppy disk.

Example:

```sh
cp * /path/to/floppy/disk/
```

### Important Files to Use

- `main.pas`: The entry point of the game.
- `shogi_game.pas`: Contains core logic and rules for the Shogi game.
- `ui_main.pas`: Handles user interface, including menus and gameplay options.
- `ai_opponent.pas`: Contains logic for computer generated opponent for single player game.

## Usage

Currently using `Free Pascal Compiler version 3.2.2 [2021/05/16] for x86_64` for testing and writing on modern linux systems.
Link to compiler for download: [Free Pascal Compiler](https://www.freepascal.org/download.html)

Uses `fpc` instead of `tpc` when compiling programs.

When testing on actual Amstrad system, a recommended combination of MS-DOS and Turbo Pascal (3.0/5.5) is needed to keep one floppy drive port free for the application disk. Link to this combo floppy will be available here when completed.

1. Once you have copied the necessary files onto your floppy disk, ensure that Turbo Pascal is installed.
2. Compile the `main.pas` file using Turbo Pascal:

   ```sh
   tpc main.pas
   ```

3. Run the compiled executable to start the game.

   ```sh
   ./main
   ```

   for modern systems

   ```sh
   main.exe
   ```

   for older systems

## Project Structure

- `/src/`
  - `main.pas`: Main entry point for the Shogi game.
  - `shogi_game.pas`: Core logic, rules, and piece movements.
  - `ui_main.pas`: User interface and gameplay options.
  - `ai_opponent.pas`: Logic for computer opponent ranging in difficulty.

## Contributing

Contributions are welcome! If you find any issues or want to add new features, feel free to open a pull request. Make sure to follow the guidelines below:

- Fork the repository and clone your fork locally.
- Create a feature branch for your changes.

If you have any questions or need further assistance, please reach out!

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
