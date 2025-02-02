## [4.0.0] - 15-01-2023
### Changed
- Complete rewrite to support GravitySync 4.0+
- Uses s6-overlay to launch scripts
- Runs isolated in a Docker-In-Docker container
- Requires access to persistence files from pi-hole container

## [3.6.2] - 21-03-2022
### Changed
- Update to GravitySync version 3.6.2

## [3.6.1] - 21-03-2022
### Changed
- Update to GravitySync version 3.6.1

## [3.6.0] - 21-03-2022
### Changed
- Update to GravitySync version 3.6.0

## [3.5.0] - 15-03-2022
### Changed
- Update to GravitySync version 3.5.0
- Updated README.md to reflect removal of backup functionality
- Updated dev_scripts/cibuild and dev_scripts/test to add image squashing and more flexibility

### Removed
- Configration Options BACKUP_RETAIN and BACKUP_TIMEOUT
- Legacy unsupported BACKUP_HOUR option (removed in GravitySync 3.3.0)
- Build Target linux/arm (no longer supported upstream)

## [3.4.8] - 13-01-2021
### Changed
- Update to GravitySync version 3.4.8
- Fix bootstrap script always downloading buildx
- Update all development scripts to pass shellcheck.net

## [3.4.7] - 29-09-2021
### Changed
- Update to GravitySync version 3.4.7

## [3.4.5] - 20-07-2021
### Changed
- Update to GravitySync version 3.4.5
- Updated README.md to reflect current state of arm images
- Script improvements for better reliability

### Added
- Buildx platform linux/arm/v6

### Removed
- Buildx platform linux/arm

## [3.4.4.2] - 2021-05-09
### Changed
- Require push to be specified when running cibuild in order to push to Docker Hub
- Fixed input device errors in CI by removing interactive TTY flags from docker commands
- Changed dnstest in CI tests to dnstest.local to prevent auto-filling the domain name

### Added
- Added GitHub Actions test and Cross Build CI runner

## [3.4.4.1] - 2021-05-08
### Changed
- Massive changes related to building and testing
    - Odrered scripts into appropreate directories
    - Tidy up script code where multiple scripting styles were used
    - Test script will now build an x86_64 image as a test stage
        - No need to run cibuild before running test
    - Run cibuild for a production ready image
        - Requires a --version flag (i.e. --version 1.2.3)
        - Does not require --platform tag unless intending to build single platform

- Install Tini Init system from a script picking build based on current architecture

### Added
- Implement support for building ARM based images
- Bootstrap script for installing build requirements

### Removed
- Previous initial support for building ARM based images

## [3.4.4] - 2021-04-29
### Changed
- Update to GravitySync version 3.4.4

## [3.4.2.1] - 2021-04-25
### Added
- Initial support for building ARM based images

### Changed
- Updated README.md to reflect ARM additions

## [3.4.2] - 2021-04-07
### Changed
- Update to GravitySync version 3.4.2

## [3.4.1] - 2021-04-07
### Changed
- Update to GravitySync version 3.4.1
- Fixed bug where passwordless sudo may not be granted in SSH container during testing
- Tidy up docker compose file
- Add support for new BACKUP_TIMEOUT option

## [3.4.0] - 2021-04-06
### Changed
- Update to GravitySync version 3.4.0

## [3.3.2] - 2021-02-17
### Added
- Added gsbuild, gstest and docker-testenvironment-compose.yml for scripted build and testing
- Added doocumentation and config options for remote SSH port and DNSMASQ directory locations

### Changed
- Update to GravitySync version 3.3.2

## [3.2.6.1] - 2021-02-08
### Added
- Added section to Readme to inform users to persist gravity-sync.md5
- Update Dockerfile to add util-linux for support of the namei command
- Create and backfill CHANGELOG.md
- Added timezone correction (as this does not come with Alpine by default)
- Added Healthcheck (Mission Report)
- Fix syntax error in configuration script

## [3.2.6] - 2021-02-05
### Changed
- Update to GravitySync version 3.2.6

## [3.2.5.1] - 2021-02-04
### Added
- Item in todo in Readme to document gravity-sync.md5 persist requirements
- Add placeholder for Git when running GravitySync Info
- Install Coreutils to allow for timeout --preserve-status

## [3.2.5] - 2021-02-03
### Changed
- Update to GravitySync version 3.2.5

## [3.2.4.1] - 2021-01-25
### Changed
- Correct indenting of Dockerfile

## [3.2.4] - 2021-01-19
### Added
- Initial commit at GravitySync version 3.2.4
