# Changelog

All notable changes to this project will be documented in this file.

## [v4.4.0](https://github.com/voxpupuli/ra10ke/tree/v4.4.0) (2025-06-08)

[Full Changelog](https://github.com/voxpupuli/ra10ke/compare/v4.3.0...v4.4.0)

**Merged pull requests:**

- Update voxpupuli-rubocop requirement from ~\> 4.0.0 to ~\> 4.1.0 [\#126](https://github.com/voxpupuli/ra10ke/pull/126) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v4.3.0](https://github.com/voxpupuli/ra10ke/tree/v4.3.0) (2025-05-13)

[Full Changelog](https://github.com/voxpupuli/ra10ke/compare/v4.2.0...v4.3.0)

**Implemented enhancements:**

- Add diff task to compare module differences between two branches [\#123](https://github.com/voxpupuli/ra10ke/pull/123) ([rwaffen](https://github.com/rwaffen))

## [v4.2.0](https://github.com/voxpupuli/ra10ke/tree/v4.2.0) (2025-02-28)

[Full Changelog](https://github.com/voxpupuli/ra10ke/compare/v4.1.0...v4.2.0)

**Merged pull requests:**

- Update git requirement from \>= 1.18, \< 3.0 to \>= 1.18, \< 4.0 [\#120](https://github.com/voxpupuli/ra10ke/pull/120) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v4.1.0](https://github.com/voxpupuli/ra10ke/tree/v4.1.0) (2025-01-08)

[Full Changelog](https://github.com/voxpupuli/ra10ke/compare/v4.0.0...v4.1.0)

**Implemented enhancements:**

- Add Ruby 3.4 support [\#119](https://github.com/voxpupuli/ra10ke/pull/119) ([bastelfreak](https://github.com/bastelfreak))
- Improve dependencies check against :control\_branch [\#116](https://github.com/voxpupuli/ra10ke/pull/116) ([ananace](https://github.com/ananace))

**Fixed bugs:**

- Fix false positive errors when ra10ke tries to validate modules with  `branch: :control_branch` [\#117](https://github.com/voxpupuli/ra10ke/issues/117)

## [v4.0.0](https://github.com/voxpupuli/ra10ke/tree/v4.0.0) (2025-01-02)

[Full Changelog](https://github.com/voxpupuli/ra10ke/compare/v3.1.0...v4.0.0)

**Breaking changes:**

- Require Ruby 3.1 & puppet\_forge 6 & r10k 5 [\#106](https://github.com/voxpupuli/ra10ke/pull/106) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Update pry requirement from ~\> 0.14.2 to ~\> 0.15.2 [\#114](https://github.com/voxpupuli/ra10ke/pull/114) ([dependabot[bot]](https://github.com/apps/dependabot))
- Cleanup Rakefile; remove unused rake tasks [\#109](https://github.com/voxpupuli/ra10ke/pull/109) ([bastelfreak](https://github.com/bastelfreak))
- Update voxpupuli-rubocop requirement from ~\> 2.8.0 to ~\> 3.0.0 [\#108](https://github.com/voxpupuli/ra10ke/pull/108) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v3.1.0](https://github.com/voxpupuli/ra10ke/tree/v3.1.0) (2024-06-28)

[Full Changelog](https://github.com/voxpupuli/ra10ke/compare/v3.0.0...v3.1.0)

**Implemented enhancements:**

- Update git requirement from ~\> 1.18 to \>= 1.18, \< 3.0 [\#103](https://github.com/voxpupuli/ra10ke/pull/103) ([dependabot[bot]](https://github.com/apps/dependabot))
- Add Ruby 3.3 to CI [\#100](https://github.com/voxpupuli/ra10ke/pull/100) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Update voxpupuli-rubocop requirement from ~\> 2.6.0 to ~\> 2.8.0 [\#104](https://github.com/voxpupuli/ra10ke/pull/104) ([dependabot[bot]](https://github.com/apps/dependabot))
- Gemfile: add faraday as GCG dependency [\#101](https://github.com/voxpupuli/ra10ke/pull/101) ([bastelfreak](https://github.com/bastelfreak))
- Update voxpupuli-rubocop requirement from ~\> 2.4.0 to ~\> 2.6.0 [\#99](https://github.com/voxpupuli/ra10ke/pull/99) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update voxpupuli-rubocop requirement from ~\> 2.3.0 to ~\> 2.4.0 [\#97](https://github.com/voxpupuli/ra10ke/pull/97) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update voxpupuli-rubocop requirement from ~\> 2.2.0 to ~\> 2.3.0 [\#96](https://github.com/voxpupuli/ra10ke/pull/96) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update voxpupuli-rubocop requirement from ~\> 2.0.0 to ~\> 2.2.0 [\#95](https://github.com/voxpupuli/ra10ke/pull/95) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v3.0.0](https://github.com/voxpupuli/ra10ke/tree/v3.0.0) (2023-08-23)

[Full Changelog](https://github.com/voxpupuli/ra10ke/compare/v2.0.0...v3.0.0)

**Breaking changes:**

- Add exit codes to dependency check [\#86](https://github.com/voxpupuli/ra10ke/pull/86) ([sebastianrakel](https://github.com/sebastianrakel))
- Drop Ruby 2.6 support & Implement voxpupuli-rubocop [\#85](https://github.com/voxpupuli/ra10ke/pull/85) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add Ruby 3.2 support / apply Vox Pupuli CI best practices [\#89](https://github.com/voxpupuli/ra10ke/pull/89) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- module with https + token is failing [\#84](https://github.com/voxpupuli/ra10ke/issues/84)

**Merged pull requests:**

- dependencies: Add strict version boundaries [\#91](https://github.com/voxpupuli/ra10ke/pull/91) ([bastelfreak](https://github.com/bastelfreak))
- dependabot: check for github actions and gems [\#88](https://github.com/voxpupuli/ra10ke/pull/88) ([bastelfreak](https://github.com/bastelfreak))
- Fix fixture for deprecation test [\#87](https://github.com/voxpupuli/ra10ke/pull/87) ([sebastianrakel](https://github.com/sebastianrakel))

## [v2.0.0](https://github.com/voxpupuli/ra10ke/tree/v2.0.0) (2022-05-18)

[Full Changelog](https://github.com/voxpupuli/ra10ke/compare/v1.2.0...v2.0.0)

**Breaking changes:**

- Bump minimal Ruby Version 2.4.0-\>2.7.0 [\#77](https://github.com/voxpupuli/ra10ke/pull/77) ([bastelfreak](https://github.com/bastelfreak))
- Dependencies Table output  [\#72](https://github.com/voxpupuli/ra10ke/pull/72) ([logicminds](https://github.com/logicminds))

**Implemented enhancements:**

- Add Ruby 3.1 support [\#78](https://github.com/voxpupuli/ra10ke/pull/78) ([bastelfreak](https://github.com/bastelfreak))
- Converts puppet forge module entries into puppetfile git entries [\#76](https://github.com/voxpupuli/ra10ke/pull/76) ([logicminds](https://github.com/logicminds))

**Fixed bugs:**

- incompatible with r10k gem \> 3.8 [\#57](https://github.com/voxpupuli/ra10ke/issues/57)
- CI: Do not run twice [\#79](https://github.com/voxpupuli/ra10ke/pull/79) ([bastelfreak](https://github.com/bastelfreak))
- Fix \#74 - server responded with 400 [\#75](https://github.com/voxpupuli/ra10ke/pull/75) ([logicminds](https://github.com/logicminds))
- Fix \#70 - cache dir does not exist [\#71](https://github.com/voxpupuli/ra10ke/pull/71) ([logicminds](https://github.com/logicminds))

**Closed issues:**

- cache dir does not exist [\#70](https://github.com/voxpupuli/ra10ke/issues/70)

## [v1.2.0](https://github.com/voxpupuli/ra10ke/tree/v1.2.0) (2022-04-21)

[Full Changelog](https://github.com/voxpupuli/ra10ke/compare/v1.1.0...v1.2.0)

**Closed issues:**

- Add support for commit ref [\#67](https://github.com/voxpupuli/ra10ke/issues/67)

**Merged pull requests:**

- Fix \#67 - Add support for commit ref [\#68](https://github.com/voxpupuli/ra10ke/pull/68) ([logicminds](https://github.com/logicminds))

## [v1.1.0](https://github.com/voxpupuli/ra10ke/tree/v1.1.0) (2021-10-26)

[Full Changelog](https://github.com/voxpupuli/ra10ke/compare/v1.0.0...v1.1.0)

**Implemented enhancements:**

- Support r10k:validate with control\_branch [\#58](https://github.com/voxpupuli/ra10ke/issues/58)
- Implement GitHub Actions and fix tests [\#62](https://github.com/voxpupuli/ra10ke/pull/62) ([bastelfreak](https://github.com/bastelfreak))
- Add handling for additional r10k args in validate for control\_branch [\#61](https://github.com/voxpupuli/ra10ke/pull/61) ([ananace](https://github.com/ananace))
- Add r10k:deprecation task [\#60](https://github.com/voxpupuli/ra10ke/pull/60) ([ananace](https://github.com/ananace))
- Support r10k:validate with control\_branch modules [\#59](https://github.com/voxpupuli/ra10ke/pull/59) ([ananace](https://github.com/ananace))
- allow to add other version formats in dependencies [\#56](https://github.com/voxpupuli/ra10ke/pull/56) ([jduepmeier](https://github.com/jduepmeier))
- Fixes \#52 - validate task fails when repo does not exist [\#53](https://github.com/voxpupuli/ra10ke/pull/53) ([logicminds](https://github.com/logicminds))

**Fixed bugs:**

- Fix source of control\_branch data [\#63](https://github.com/voxpupuli/ra10ke/pull/63) ([ananace](https://github.com/ananace))

**Closed issues:**

- validate task fails when repo does not exist [\#52](https://github.com/voxpupuli/ra10ke/issues/52)

**Merged pull requests:**

- Add Dependabot config [\#65](https://github.com/voxpupuli/ra10ke/pull/65) ([bastelfreak](https://github.com/bastelfreak))
- Set minimal Ruby version to 2.4.0 [\#64](https://github.com/voxpupuli/ra10ke/pull/64) ([bastelfreak](https://github.com/bastelfreak))
- Add coverage reports [\#54](https://github.com/voxpupuli/ra10ke/pull/54) ([logicminds](https://github.com/logicminds))

## [v1.0.0](https://github.com/voxpupuli/ra10ke/tree/v1.0.0) (2020-02-08)

2020-02-08

Closed Pull Requests:

* [#44](https://github.com/voxpupuli/ra10ke/pull/44) - Fix the faulty docs for Ra10ke::Validate#all_refs after [#42](https://github.com/voxpupuli/ra10ke/pull/42)
* [#45](https://github.com/voxpupuli/ra10ke/pull/45) - Add a duplicates check
* [#48](https://github.com/voxpupuli/ra10ke/pull/48) - Allow semverse 3.x

0.6.2
-----

2019-08-26

Closed Pull Requests:

* [#42](https://github.com/voxpupuli/ra10ke/pull/42) - Fix lost refs in validation

Again many thanks to the following contributors for submitting PRs:

* [Alexander Olofsson](https://github.com/ananace)

0.6.1
-----

2019-08-17

Closed Pull Requests:

* [#40](https://github.com/voxpupuli/ra10ke/pull/40) - Fix a fault in the mod handling behaviour

Closed Issues:

* [#25](https://github.com/voxpupuli/ra10ke/issues/25) - Consider making r10k:install have a default path of '.'

Many thanks to the following contributors for submitting PRs:

* [Alexander Olofsson](https://github.com/ananace)

0.6.0
-----

2019-07-30

Closed Pull Requests:

* [#35](https://github.com/voxpupuli/ra10ke/pull/35) Adds new validate task for verifying the integrity of all modules      specified in the Puppetfile
* [#33](https://github.com/voxpupuli/ra10ke/pull/33) Refactor tasks, Version tag handling fix, purge option
* [#32](https://github.com/voxpupuli/ra10ke/pull/32) Make it possible to configure the tasks in the rakefile

Many thanks to the following contributors for submitting PRs:

* [Corey Osman](https://github.com/logicminds)
* [Andreas Zuber](https://github.com/ZeroPointEnergy)

0.5.0
-----

2018-12-26

Closed Pull Requests:

* [#22](https://github.com/voxpupuli/ra10ke/pull/22) Add rudimentary r10k:install task
* [#26](https://github.com/voxpupuli/ra10ke/pull/26) make use of the forge command in puppetfile
* [#29](https://github.com/voxpupuli/ra10ke/pull/29) Abort (exit 1) if Puppetfile syntax check fails
* [#30](https://github.com/voxpupuli/ra10ke/pull/30) enable travis deployment

0.4.0
-----

2018-06-17

* [#13](https://github.com/voxpupuli/ra10ke/pull/13) Avoid using `desired_ref` directly for Git
* [#14](https://github.com/voxpupuli/ra10ke/pull/14) Set required Ruby version as `>= 2.1.0`
* [#15](https://github.com/voxpupuli/ra10ke/pull/15) ignore invalid ref
* [#16](https://github.com/voxpupuli/ra10ke/pull/16) Use Semantic Versioning for Git tags
* [#17](https://github.com/voxpupuli/ra10ke/pull/17) Be careful around trimming Git tags
* [#19](https://github.com/voxpupuli/ra10ke/pull/19) Ensure Puppetfile gets parsed with absolute path

Many thanks to the following contributors for submitting the PRs:
* [Valter Jansons](https://github.com/sigv)
* [Martin Alfke](https://github.com/tuxmea)
* [Matthias Baur](https://github.com/baurmatt)

0.3.0
-----

2017-10-08

* [#6](https://github.com/voxpupuli/ra10ke/pull/6) Add a dependency solver based on the Ruby Solve library (thanks to [Jarkko Oranen](https://github.com/oranenj))
* [#8](https://github.com/voxpupuli/ra10ke/pull/8) Add numeric tag convention support (thanks to [Hervé MARTIN](https://github.com/HerveMARTIN))

0.2.0
-----

2017-01-03

* Moved to [Vox Pupuli](https://voxpupuli.org/)
* [#3](https://github.com/voxpupuli/ra10ke/pull/3) Update ra10ke with r10k 2.4.0 support
* [#4](https://github.com/voxpupuli/ra10ke/pull/4) Added git support

Many thanks to [Alexander "Ace" Olofsson](https://github.com/ace13) and [James Powis](https://github.com/james-powis) for their contributions!

0.1.1
-----

2016-08-22

* [#1](https://github.com/tampakrap/ra10ke/issues/1) update docs to mention Gemfile and Rakefile
* properly advertise the user agent

0.1.0
-----

2015-12-07

* Initial release


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
