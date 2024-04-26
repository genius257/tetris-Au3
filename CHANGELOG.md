# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2024-04-26

### Added

- Explanation of the recommended reverse chronological release ordering.
- Gameplay image to the README file
- Game controls table to the README file
- Main, settings, pause menu's
- Support for changing the ghost design via settings menu
- This CHANGELOG file

### Changed

- Moved code into src folder
- Escape key no longer exits the game, but is used to enter the pause menu from gameplay

### Removed

- Deleted the screenshots folder
- The script no longer requires running as administrator (12f28254860b11a3e54b66d35b339fec21fdc7ed)

### Fixed

- Game crashing when drawing text, when the font fails to load
- Held tetromino preview image was flipped on the y axis (#7)
- Next tetromino preview image was flipped on the y axis (#8)

## [1.0.0] - 2023-01-30

### Added

- Initial working game code

[unreleased]: https://github.com/genius257/tetris-Au3/compare/1.1.0...HEAD
[1.1.0]: https://github.com/genius257/tetris-Au3/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/genius257/tetris-Au3/releases/tag/1.0.0
