# ra10ke

[![License](https://img.shields.io/github/license/voxpupuli/ra10ke.svg)](https://github.com/voxpupuli/ra10ke/blob/master/LICENSE.txt)
[![Test](https://github.com/voxpupuli/ra10ke/actions/workflows/test.yml/badge.svg)](https://github.com/voxpupuli/ra10ke/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/voxpupuli/ra10ke/branch/master/graph/badge.svg?token=Mypkl78hvK)](https://codecov.io/gh/voxpupuli/ra10ke)
[![Release](https://github.com/voxpupuli/ra10ke/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/ra10ke/actions/workflows/release.yml)
[![RubyGem Version](https://img.shields.io/gem/v/ra10ke.svg)](https://rubygems.org/gems/ra10ke)
[![RubyGem Downloads](https://img.shields.io/gem/dt/ra10ke.svg)](https://rubygems.org/gems/ra10ke)

Rake tasks related to [R10K](https://github.com/puppetlabs/r10k) and
[Puppetfile](https://github.com/puppetlabs/r10k/blob/master/doc/puppetfile.mkd).

## Usage

Add the following line to your `Gemfile`:

```ruby
gem 'ra10ke'
```

Add the following lines in your `Rakefile`:

```ruby
require 'ra10ke'
Ra10ke::RakeTask.new
```

## Configuration

You can configure the tasks in a block:

```ruby
Ra10ke::RakeTask.new do |t|
  t.basedir = File.join(Dir.pwd, 'some_dir')
  t.moduledir = File.join(Dir.pwd, 'some_dir/strange_module_dir')
end
```

Available settings are:

| Setting         | Documentation                                                                                 |
|-----------------|-----------------------------------------------------------------------------------------------|
| basedir         | Base directory with the Puppetfile and modules directory (Default: Same directory as Rakefile)|
| moduledir       | Directory to install the modules in (Default: 'modules' in basedir)                           |
| puppetfile_path | Directroy where the Puppetfile is (Default: basedir)                                          |
| puppetfile_name | The Puppetfile name (Default: basedir/Puppetfile)                                             |
| force           | Overwrite locally changed files on install (Default: false)                                   |
| purge           | Purge unmanaged modules from the modulesdir (Default: false)                                  |

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

### r10k::print_git_conversion

This rake task will go through the puppetfile and convert forge based modules into git based modules using
the modules't source repository and version tag.

This feature is useful when you want to bring all the forge modules into git source control.  This assumes every module
tags the release or provides a valid repo url.  We recommend to manually review
the output provided by this task before replacing the forge based content in your puppetfile as not every module author
tagged a release or provided a working url.

### r10k:solve_dependencies

Reads the Puppetfile in the current directory and uses the ruby 'solve' library to find
missing and outdated dependencies based on their metadata.

The solver does not allow major version bumps according to SemVer by default. To allow
major upgrades, call the rake task with any parameter.

The rake task will download git modules into the modules/ directory to access their metadata.json.
It will also cache forge metadata in ̃$XDG_CACHE_DIR/ra10ke.metadata_cache in order to make subsequent
runs faster.

### r10k:install[path]

Reads the Puppetfile in the current directory and installs them under the `path` provided as an argument.

#### Limitations

- It works only with modules from the [Forge](https://forge.puppetlabs.com), and Git.
SVN modules will be ignored.
- Git support is explicitly SHA Ref and Tag supported. If tag is used it must follow
`v0.0.0` convention, other wise it will be ignored.
- The version has to be specified explicitly. If it is omitted, or it is
`:latest`, the module will be ignored.

### r10k:validate[path]

The validate rake task will determine if the url is a valid url by connecting
to the repository and verififying it actually exists and can be accessed.
Additional if a branch, tag, or ref is specified in the Puppetfile the validate
task will also verify that that branch/tag/ref exists in the remote repository.

If you have ever deployed r10k to production only to find out a tag or branch is
missing this validate task will catch that issue.

A exit status of 0 is returned if there are no faults, while a 1 is returned if
any module has a bad status.

Status emojis can be customized by setting the following environment variables.

Example

- `GOOD_EMOJI='👍'`
- `BAD_EMOJI='😨'`

```text
NAME     | URL                                           | REF                            | STATUS
---------|-----------------------------------------------|--------------------------------|-------
splunk   | https://github.com/cudgel/splunk.git          | dev                            | 👍
r10k     | https://github.com/acidprime/r10k             | v3.1.1                         | 👍
gms      | https://github.com/npwalker/abrader-gms       | gitlab_disable_ssl_verify_s... | 👍
rbac     | https://github.com/puppetlabs/pltraining-rbac | 2f60e1789a721ce83f8df061e13... | 👍
acl      | https://github.com/dobbymoodge/puppet-acl.git | master                         | 👍
deploy   | https://github.com/cudgel/deploy.git          | master                         | 👍
dotfiles | https://github.com/cudgel/puppet-dotfiles.git | master                         | 👍
gitlab   | https://github.com/vshn/puppet-gitlab         | 00397b86dfb3487d9df768cbd36... | 👍

👍👍 Puppetfile looks good.👍👍
```

### r10k:duplicates

This rake task parses the Puppetfile and looks for modules with duplicate
declarations.

All found duplicates are reported along with their source and their version
(if taken from the Forge) or their ref/tag/branch. (if taken from git)

Example

```text
puppet:
- abstractit/puppet from the forge at version 2.4.1
- theforeman/puppet from the forge at version 12.0.1
- puppet from git on the branch master at https://github.com/voxpupuli/puppet-module.git

gitlab:
- puppet/gitlab from the forge at version 4.0.1
- gitlab from git on the ref 00397b86dfb3487d9df768cbd3698d362132b5bf at https://github.com/vshn/puppet-gitlab

Error: Duplicates exist in the Puppetfile
```

### r10k:deprecation

This rake task checks all the Forge modules listed in the Puppetfile, looking
for modules that are marked as deprecated on the Forge.

Example

```text
NAME                    | DEPRECATED_AT
------------------------|--------------------------
kemra102-auditd         | 2021-07-22 12:11:46
puppet-staging          | 2018-12-18 11:11:29
puppetlabs-resource_api | 2021-03-31 12:53:24
puppetlabs-ruby         | 2021-04-22 10:29:42
puppetlabs-translate    | 2021-03-19 10:11:51

Error: Puppetfile contains deprecated modules.
```

### r10k:diff[production,development]

This rake task will compare the modules in two branches and show the differences between them.
This is useful to see what modules have been changed, added or removed between two branches.
To pass the branches you may have to quote the arguments to prevent the shell from interpreting the `[]`.
For example `rake "r10k:diff[production,development]"`

Example

```text
NAME    | VERSION_A                      | VERSION_B                      | TYPE_A | TYPE_B | STATUS
--------|--------------------------------|--------------------------------|--------|--------|--------
inifile | 5.0.1                          | 6.2.0                          | forge  | forge  | changed
stdlib  | 7.0.1                          | 1b6f89afdde0df7f9433a163d5c... | forge  | vcs    | changed
systemd | 1.2.3                          |                                | forge  |        | removed
apache  | 1b6f89afdde0df7f9433a163d5c... |                                | vcs    |        | removed
rwaffen | v1.0.0                         | v1.0.3                         | vcs    | vcs    | changed
haproxy |                                | 1.0.0                          |        | forge  | added
```
