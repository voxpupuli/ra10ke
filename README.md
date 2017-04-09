ra10ke
======

[![Gem Version](https://badge.fury.io/rb/ra10ke.svg)](https://badge.fury.io/rb/ra10ke)

Rake tasks related to [R10K](https://github.com/puppetlabs/r10k) and
[Puppetfile](https://github.com/puppetlabs/r10k/blob/master/doc/puppetfile.mkd).

## Usage

Add the following line to your `Gemfile`:
```ruby
gem 'ra10ke'
```

Add the following line in your `Rakefile`:

```ruby
require 'ra10ke'
```

## Rake tasks

### r10k:syntax

Syntax check for the Puppetfile. Similar to the `r10k puppetfile check`
command.

### r10k:dependencies

This rake task goes through the modules that are declared in the Puppetfile,
and prints outdated modules.

Supports:
  - Puppet Forge
  - Git (SHA-ref and Tagging)

Ignoring specific modules:

Under specific conditions you may not wish to report on specific modules being out of date,
to ignore a module create `.r10kignore` file in the same directory as your Puppetfile.

### r10k:solve_dependencies

Reads the Puppetfile in the current directory and uses the ruby 'solve' library to find
missing and outdated dependencies based on their metadata.

The solver does not allow major version bumps according to SemVer by default. To allow
major upgrades, call the rake task with any parameter.

The rake task will download git modules into the modules/ directory to access their metadata.json.
It will also cache forge metadata in ̃$XDG_CACHE_DIR/ra10ke.metadata_cache in order to make subsequent
runs faster.

#### Limitations

  * It works only with modules from the [Forge](https://forge.puppetlabs.com), and Git.
  SVN modules will be ignored.
  * Git support is explicitly SHA Ref and Tag supported. If tag is used it must follow
  `v0.0.0` convention, other wise it will be ignored.
  * The version has to be specified explicitly. If it is omitted, or it is
  `:latest`, the module will be ignored.
