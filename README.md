# myPanel

Version: 1.5

## Overview

myPanel is a lightweight Electron-based application designed to manage and access frequently used files through a simple panel interface. With an intuitive UI built using Vue.js, users can quickly select and open their last accessed files.

## Features

- Quick file access panel
- Persistent storage of last opened files
- Customizable preferences (theme and language)
- Window state preservation
- Simple and clean user interface

## Changelog

### Version 1.5

#### New Features
- Enhanced UI with improved visual hierarchy
- Better error handling for file operations
- Improved configuration loading mechanism
- Added window state management (position and size)
- Theme customization support

#### Bug Fixes
- Fixed issue with configuration file loading
- Resolved file selection inconsistencies
- Addressed potential crashes during startup

#### Improvements
- Optimized application performance
- Refactored code structure for better maintainability
- Updated dependencies to latest stable versions
- Enhanced logging for easier debugging

### Version 1.0

- Initial release
- Basic file selection functionality
- Simple panel interface
- Configuration file support

## Installation

1. Clone the repository
2. Install dependencies with `npm install`
3. Start the application with `npm start`

## Usage

Launch the application and use the panel buttons to select and open your frequently used files. The application remembers your last opened files and preferences.

## Configuration

The application stores its configuration in `myPanel.json`, including:
- Last opened files
- User preferences (theme, language)
- Window state (dimensions, position)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License