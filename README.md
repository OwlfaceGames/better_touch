# Better Touch (btouch)

A smarter version of the `touch` command that allows you to create multiple files with the same file extension or suffix without having to type it repeatedly.

## Description

`btouch` is an enhanced version of the traditional Unix `touch` command that streamlines file creation when working with multiple files that share the same extension or suffix. Instead of typing the extension for each file, you specify it once and then list all the filenames you want to create.

## Features

- Create multiple files with the same extension in one command
- Works with any file extension (`.txt`, `.js`, `.py`, etc.)
- Works with any suffix pattern
- Self-installing with the `-i` flag
- Simple and intuitive command-line interface

## Installation

### One-Line Install (Recommended)

Run this command to automatically download and install the latest version:

```bash
curl -fsSL https://raw.githubusercontent.com/OwlfaceGames/better_touch/main/install.sh | bash
```

This script will:
- Auto-detect your OS and architecture
- Download the appropriate pre-compiled binary
- Install it to `/usr/local/bin` (with sudo if needed)
- Fall back to compiling from source if no binary is available

### Manual Installation

If you prefer to install manually:

1. Download the latest release from the [GitHub releases page](../../releases)
2. Extract the binary
3. Run the installation command:

```bash
./btouch -i
```

This will automatically install `btouch` to `/usr/local/bin` and make it available system-wide.

### Building from Source

If you prefer to build from source:

```bash
git clone https://github.com/OwlfaceGames/better_touch.git
cd better_touch
gcc -o btouch main.c
./btouch -i
```

## Usage

### Basic Syntax

```bash
btouch <extension> <file1> <file2> <file3> ...
```

### Examples

**Create multiple text files:**
```bash
btouch .txt readme notes todo
```
This creates: `readme.txt`, `notes.txt`, `todo.txt`

**Create multiple C files:**
```bash
btouch .c app utils config
```
This creates: `app.c`, `utils.c`, `config.c`

**Create files with custom suffixes:**
```bash
btouch .backup file1 file2 file3
```
This creates: `file1.backup`, `file2.backup`, `file3.backup`

**Create files with underscore suffixes:**
```bash
btouch _data user product order
```
This creates: `user_data`, `product_data`, `order_data`

**Create C files with specific suffixes:**
```bash
btouch _core.c parser lexer analyzer
```
This creates: `parser_core.c`, `lexer_core.c`, `analyzer_core.c`

**Create files without extensions (using space):**
```bash
btouch " " Makefile Dockerfile README
```
This creates: `Makefile`, `Dockerfile`, `README`

## Why Better Touch?

Traditional `touch` command:
```bash
touch readme.txt notes.txt todo.txt config.txt
```

With `btouch`:
```bash
btouch .txt readme notes todo config
```

**Benefits:**
- Saves typing when creating multiple files with the same extension
- Reduces errors from mistyping extensions
- Cleaner, more readable commands
- Maintains the simplicity of the original `touch` command

## Requirements

- Unix-like operating system (Linux, macOS, etc.)
- Standard C library
