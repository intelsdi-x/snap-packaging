# Snap Packaging

## Overview

This repo contains some snap packaging tools. (Experimental)

Currently the packaging tool use the local system (MacOS) to generate go binary and build the MacOS pkg binary. This will be migrated to a disposable box later. Currently packages are generated in the build VMs, this can be migrated to containers where suitable. The OS specific VMs are for package testing/validation.

### Workflow

**Warning**: the first step affects your system:

* configure go path and install gox on local mac : `rake setup:go`
* generate artifacts skeleton: `rake setup:artifacts`
* cross compile go binary: `rake package:go`
* build packages for OS: `rake package:os_version`

## Installation

### Requirements

* Ruby 2.3 + Bundler Gem
* Parallels (VirtualBox/VMware Fusion might work)
* Vagrant

Recommend bundle path as .bundle and appropriate binstub to avoid `bundle exec rake`:

```
$ bundle install --binstubs
$ rake -T
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

### Slack Tokens

To send a slack notification, supply the snap_build_bot account api token info as environment variable or store it in `${HOME}/.slack`:

```
---
API_TOKEN: '...'
```

or
```
$ SLACK_API_TOKEN=... rake notify:slack
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
