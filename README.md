# Snap Packaging

## Overview

This repo contains _experimental_ snap packaging tools. The packaging tool fetches binary from S3 built by [Travis CI](https://travis-ci.org/intelsdi-x/snap) and use local VMs to build packages. The OS specific VMs are for package testing/validation. We also preserved some utility commands to allow local compilation.

### Workflow

The default workflow is to fetch the binaries stored on S3.

* generate artifacts skeleton: `rake setup:artifacts`
* generate artifacts skeleton: `rake fetch:s3_binary
* build packages for OS: `rake package:os_version`
* test packages in vagrant: `vagrant up <operating_system>`
* push packages to packagecloud.io: `rake upload:packagecloud`

The alternative workflow compiles binaries on your local system for testing purpose.

**Warning**: the first step will install several packages on your system:

* configure go path and install gox on local mac : `rake setup:go`
* generate artifacts skeleton: `rake setup:artifacts`
* cross compile go binary: `rake package:go`
* build packages for OS: `rake package:os_version`

NOTE: gox currently have a bug with gcflags option, please patch and recompile until [PR #63](https://github.com/mitchellh/gox/pull/63) is merged.

## Installation

### Requirements

* Ruby 2.3+
    * [rbenv](https://github.com/rbenv/rbenv) (optional)
    * [Bundler Gem](https://bundler.io/)
* Parallels Desktop 12+
* Vagrant

The following steps will install Ruby 2.3.1 using rbenv on MacOS:
```
$ brew install ruby-build
$ brew install rbenv
$ rbenv install 2.3.1
```

Make sure your shell startup script contains the following setting (source `~/.{bash|zsh}rc` or restart shell as necessary):
```
# rbenv environment:
eval "$(rbenv init -)"
```

Set ruby 2.3.1 as the local version for snap-packaging folder:
```
$ cd snap-packaging
$ rbenv local 2.3.1
$ gem install bundler --no-ri --no-rdoc
```

Configure bundle path and install all dependencies for the rake task:
```
$ bundle config path .bundle
$ bundle install
$ bundle exec rake -T
rake build:go_binary      # compile snap go binary
rake help                 # Show the list of Rake tasks (rake -T)
rake notify:slack         # send a slack notification
rake notify:tweet         # send a twitter tweet
rake package:all          # build all packages
rake package:mac_pkg      # build MacOS pkg package
rake package:macos        # build all supported MacOS packages
rake package:redhat       # build all RedHat RPM packages
rake package:redhat_6     # build RedHat 6 RPM packages
rake package:redhat_7     # build RedHat 7 RPM packages
rake package:ubuntu       # build all Ubuntu deb packages
rake package:ubuntu_1404  # build Ubuntu Trusty (14.04) packages
rake package:ubuntu_1604  # build Ubuntu Xenial (16.04) packages
rake plugin:metadata      # generate plugin metadata
rake setup:artifacts      # create artifacts folders
rake setup:godep          # install godep/gox
rake test                 # Run tests
rake upload:bintray       # upload packages to Bintray
rake upload:packagecloud  # upload packages to PackageCloud.io
rake upload:s3            # upload packages to AWS s3
```

Install vagrant, vagrant-parallel plugin:
```
$ brew cask install vagrant
$ vagrant plugin install vagrant-parallels
$ vagrant status
```

### Github OAuth

Some tasks will query github for defaults. GitHub rate limits it's APIs, so please configure [.netrc file](https://github.com/octokit/octokit.rb#using-a-netrc-file) with an OAuth token, so queries are counted against 5,000 requests/hour/account instead of the 60 request/hour/IP [rate limit](https://developer.github.com/v3/#rate-limiting).

Example `~/.netrc`:

```
machine api.github.com
  login <username>
  password <40 char OAuth token>
```

### Twitter OAuth

To send a notification tweet, [register this application](https://apps.twitter.com/) with Twitter and either supply the configuration info either as environment variable or store it in `${HOME}/.twitter`:

```
---
consumer_key: ...
consumer_secret: ...
access_token: ...
access_token_secret: ...
```

or
```
$ TWITTER_CONSUMER_KEY=... \
  TWITTER_CONSUMER_SECRET=... \
  TWITTER_ACCESS_TOKEN=... \
  TWITTER_ACCESS_TOKEN_SECRET=... \
  rake notify:tweet
```

### Slack Token

To send a slack notification, supply the snap_build_bot account api token info as environment variable or store it in `${HOME}/.slack`:

```
---
API_TOKEN: '...'
```

or
```
$ SLACK_API_TOKEN=... rake notify:slack
```

### Packagecloud Token

To push packages to packagecloud, create an account on packagecloud.io and join the [intelsdi-x org](https://packagecloud.io/intelsdi-x/). Obtain the API token from your [account settings](https://packagecloud.io/api_token) and store it in JSON format in `~/.packagecloud`:
```json
{
  "url": "https://packagecloud.io",
  "username": "...",
  "token": "...",
}
```

### Bintray API Key

To push packages to bintray, store the appropriate API key in YAML format in `~/.bintray`:
```yaml
---
username: ...
apikey: ...
```

## Operating System

Build matrix

| package format | tool | limitations |
| --- | --- | --- |
| Redhat RPM | fpm | Redhat 6 init.d services requires [daemon workaround](https://github.com/intelsdi-x/snap/issues/878) |
| Debian Deb | fpm | Ubuntu Trusty init.d service requires [daemon workaround](https://github.com/intelsdi-x/snap/issues/878) |
| MacOS pkg | fpm | /usr/local/bin due to El Capitan's [System Integrity Protection (SIP)](https://support.apple.com/en-us/HT204899) |
| MacOS Homebrew | homebrew | pending |

### RedHat

Installation:
```
$ yum install -y /path/to/snap.rpm
```

Uninstall:
```
$ yum remove -y snap
```

### Ubuntu

Installation:
```
$ dpkg -i /path/to/snap.deb
```

Uninstall:
```
$ dpkg --purge snap
```

### MacOS

MacOS pkg:

Installation (pkg can not be network location):
```
$ sudo installer -allowUntrusted -verboseR -pkg "/path/to/snap.pkg" -target /
```

Examine package:
```
$ pkgutil --bom /path/to/snap.pkg
$ lsbom /tmp/snap.boms.Random/Bom
```

List Packages/Files:
```
$ pkgutil --pkgs
$ pkgutil --list com.intel.pkg.snap
```

Uninstall:

1. remove files (pending uninstall script)
    ```
    $ rm /usr/local/bin/snapd
    $ rm /usr/local/bin/snapctl
    $ rm -rf /etc/snap
    $ rm -rf /opt/snap
    ```
2. forget package
    ```
    $ sudo pkgutil --forget com.intel.pkg.snap
    ```

MacOS Homebrew:

Installation:
```
$ brew install snap
```

Uninstall:
```
$ brew uninstall snap
```

## Vagrant

The Vagrant VMs are split between build nodes and test nodes. Build nodes are named after OS family and allows building of snap packages for those platforms. Test nodes are named after specific operating systems and allow testing of snap packages built for that specific OS.

```
❯ vagrant status
Current machine states:

redhat                    running (parallels)
debian                    running (parallels)
centos67                  running (parallels)
centos72                  running (parallels)
ubuntu1604                running (parallels)
ubuntu1404                running (parallels)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

vagrant-serverspec plugin is recommended to verify packages:
```
❯ vagrant plugin install vagrant-serverspec
Installing the 'vagrant-serverspec' plugin. This can take a few minutes...
Installed the plugin 'vagrant-serverspec (1.1.0)'!
```

vagrant provision example:
```
❯ vagrant up ubuntu1604
Bringing machine 'ubuntu1604' up with 'parallels' provider...
==> ubuntu1604: Registering VM image from the base box 'boxcutter/ubuntu1604'...
==> ubuntu1604: Creating new virtual machine as a linked clone...
...
==> ubuntu1604: Running provisioner: ansible...
    ubuntu1604: Running ansible-playbook...

PLAY [Debian] ******************************************************************

TASK [setup] *******************************************************************
ok: [ubuntu1604]
TASK [add apt over https] ******************************************************
ok: [ubuntu1604]
TASK [add snap key] ************************************************************
changed: [ubuntu1604]
TASK [add snap repo] ***********************************************************
changed: [ubuntu1604]
TASK [install snap] ************************************************************
changed: [ubuntu1604]
TASK [enable snap service] *****************************************************
changed: [ubuntu1604]

PLAY RECAP *********************************************************************
ubuntu1604                 : ok=7    changed=4    unreachable=0    failed=0

==> ubuntu1604: Running provisioner: serverspec...
.....

Finished in 0.65776 seconds (files took 1 minute 12.24 seconds to load)
5 examples, 0 failures
```
