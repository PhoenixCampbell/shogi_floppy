# Shogi Game

## Overview

This is a Shogi game developed using Turbo Pascal for the Amstrad PPC. The game includes single-player mode against three different levels of AI opponents and two-player local multiplayer mode. Additionally, it supports saving and loading games to disk.

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

- Turbo Pascal (compatible with Amstrad PPC)

### Clone the Repository

1. Open your terminal or command prompt.
2. Navigate to the directory where you want to clone the repository.
3. Run the following command:

   ```sh
   git clone https://github.com/yourusername/shogi-game.git
   ```

4. Change into the cloned repository directory:

   ```sh
   cd shogi-game
   ```

### Copy Files to Floppy Disk

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

## Usage

1. Once you have copied the necessary files onto your floppy disk, ensure that Turbo Pascal is installed on your Amstrad PPC.
2. Compile the `main.pas` file using Turbo Pascal:

   ```sh
   tpc main.pas
   ```

3. Run the compiled executable to start the game.

## Project Structure

- `/src/`
  - `main.pas`: Main entry point for the Shogi game.
  - `shogi_game.pas`: Core logic, rules, and piece movements.
  - `ui_main.pas`: User interface and gameplay options.

## Contributing

Contributions are welcome! If you find any issues or want to add new features, feel free to open a pull request. Make sure to follow the guidelines below:

- Fork the repository and clone your fork locally.
- Create a feature branch for your changes.
- Ensure tests pass locally before submitting a pull request.

If you have any questions or need further assistance, please reach out!

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
