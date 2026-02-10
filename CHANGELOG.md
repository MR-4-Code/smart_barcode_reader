# Changelog

All notable changes to the `smart_barcode_reader` package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Support for additional barcode formats (e.g., UPC-A, Code 128).
- Enhanced user feedback customization options.

## [0.0.4+4] - 2026-02-10

### Fixed
- Bug fix
- Update score check for scanner input to 0.4

## [0.0.3+3] - 2026-02-09

### Added
- Wrapped SmartBarCodeReaderWidget with FocusScope for improved focus management.

### Changed
- Added optional parameter focusScopeNode to SmartBarCodeReaderWidget for custom focus scope control.

### Fixed
- Resolved focus node issues to ensure consistent focus requests and prevent loss during navigation or interactions.

## [0.0.2+3] - 2025-12-24

### Fixed
- Fixed an issue where the scanner would lose focus, by exposing the `FocusNode` as an optional parameter. (Fixes [#1](https://github.com/MR-4-Code/smart_barcode_reader/issues/1))

### Changed
- Updated environment SDK to `^3.10.0`.
- Updated `dev_dependencies`.

## [0.0.1+2] - 2025-05-14

### Added
- Performance improvements.
- Fixed some bugs related to the barcode.
- Automation publish to pub.dev see publish.yml

## [0.0.1+1] - 2025-05-12

### Added
- Performance improvements.

## [0.0.1] - 2025-04-25

### Added
- Initial release of `smart_barcode_reader`.
- Intelligent barcode detection with adaptive speed and length validation using `SmartBarCodeReader` and `InputClassifier`.
- Support for EAN-13 barcode format with checksum verification.
- User feedback via `UserFeedbackManager` (e.g., SnackBar for invalid inputs).
- High tolerance for slower scanners by setting inter-key duration tolerance to 2.5x adaptive threshold.
- Lightweight implementation with minimal dependencies, optimized for POS applications.