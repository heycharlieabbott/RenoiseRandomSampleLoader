# Random Sample Loader for Renoise

This Renoise tool adds a convenient menu item and keybinding to load a set number of random audio samples from a folder into the currently selected instrument.

## 📦 Features

- Loads random audio samples (`.wav`, `.flac`, `.aiff`, `.mp3`, etc.) from a specified folder.
- Automatically inserts samples into the currently selected instrument in Renoise.
- Offers both a menu entry and a global keybinding for quick access.
- Supports case-insensitive audio file extensions.
- Handles folder path validation and missing files gracefully.

## 🧠 How It Works

- You select a folder containing audio files.
- The tool finds all valid audio files in the folder.
- A specified number of random files are chosen.
- These files are loaded into the current instrument as separate samples.

## 🚀 Installation

1. Download or clone this repository.
2. Copy or symlink the tool folder into your Renoise `Scripts/Tools` directory:
   - **Windows**: `C:\Users\<YourName>\AppData\Roaming\Renoise\<Version>\Scripts\Tools`
   - **macOS**: `~/Library/Preferences/Renoise/<Version>/Scripts/Tools`
3. Restart Renoise or reload tools.

## 📂 Usage

1. In Renoise, select the instrument you want to load samples into.
2. Open the tool via:
   - `Main Menu → Tools → Random Sample Loader...`, or
   - Press the keybinding `Global:Tools:Random Sample Loader` (set it in Renoise’s key preferences if needed).
3. A dialog will prompt you for:
   - A folder path.
   - The number of random samples to load.
4. The tool will populate the selected instrument with the chosen samples.

## 🔧 Dependencies

This script depends on a separate `gui.lua` module for the interface, which should include the `show_random_sample_dialog()` function.

## 🛠️ Developer Notes

- Uses `os.execute` and `io.popen` with the `find` shell command for robust file listing.
- Validates directory existence and handles paths with special characters.
- Uses `pcall` to catch errors when loading audio files into Renoise buffers.

## ⚠️ Known Limitations

- Requires shell access (may not work in sandboxed environments).
- Assumes a Unix-like shell for directory/file operations (may need adjustment for Windows compatibility).

## 📜 License

MIT License — free to use, modify, and distribute.
