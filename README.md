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

#### Limitations

  * It works only with modules from the [Forge](https://forge.puppetlabs.com).
  Git and SVN modules will be ignored.
  * The version has to be specified explicitly. If it is omitted, or it is
  `:latest`, the module will be ignored.
