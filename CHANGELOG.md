# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
-

### Changed

-

### Removed

-

## [0.1.16] - 2025-02-07
### Changed
- Added support for configuring the languages
- Hide the locale switcher of only one language is present

## [0.1.15] - 2025-02-04
### Fixed
- Fixed issue with the page search, triggering the whole focus area on opening
- Various small bugfixes
- Package upgrades

## [0.1.14] - 2025-01-23
### Fixed
- Fixed issue with the draggable in component list

## [0.1.13] - 2025-01-22
### Added
- Lottie Component
- Video Component
### Changed
- Various small bugfixes with state management

## [0.1.12] - 2025-01-20
### Fixed
- Added missing migration for `cms_api_tokens` table into migration template.

## [0.1.11] - 2025-01-20
### Changed
- Implemented API authentication (see README.md for more info)
- Added `settings` page to the CMS to generate and display the API key
- UI improvements

## [0.1.10] - 2025-01-15
### Changed
- Improved the uploader look, cleaned up the code
- Fixed a bug with cancelling the upload

## [0.1.9] - 2025-01-14
### Changed
- Made the custom CSS config slightly more granular, you can now enable JS/CSS separately

## [0.1.8] - 2025-01-14
### Changed
- Added the ability to use custom JS and CSS

## [0.1.7] - 2025-01-14
### Changed
- Added an Image Button Collection component
### Fixed
- Fixed use of `PageSearch` LiveView component in `ButtonCollection`

## [0.1.6] - 2025-01-15
### Fixed
- Image URL for image components is now presigned S3 URL

## [0.1.5] - 2025-01-14
### Changed
- Added a Page Search component, to make searching for internal pages nice and easy
- Edited the Buttons to use the new Page Search component

## [0.1.4] - 2025-01-10
### Changed
- Renamed button components:
  - button > cta_button
  - simple_button > button
- Added a new component: `button_collection`

## [0.1.3] - 2024-12-20
### Fixed
- A bug prevented the custom components from getting listed

## [0.1.2] - 2024-12-20
### Changed
- Added several compoents
- Changed the components serializers so they can be overwritten
- Fixed some docs

## [0.1.1] - 2024-12-17
### Changed
- Moved heroicons around

## [0.1.0] - 2024-12-17
### Added
- This is our initial version
