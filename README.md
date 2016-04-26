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
$ rake
rake -T
rake help                 # Show the list of Rake tasks (rake -T)
rake package:debian       # build all Debian deb packages
rake package:go           # compile snap go binary
rake package:mac_pkg      # build MacOS pkg package
rake package:macos        # build all supported MacOS packages
rake package:redhat       # build all RedHat RPM packages
rake package:redhat_6     # build RedHat 6 RPM Packages
rake package:redhat_7     # build RedHat 7 RPM packages
rake package:ubuntu_1404  # build Ubuntu Xenial (16.04) packages
rake package:ubuntu_1604  # build Ubuntu Xenial (16.04) packages
rake setup:artifacts      # create artifacts folders
rake setup:go             # setup GOPATH:PATH and install godep/gox
```

### Github OAuth

Some tasks will query github for defaults. GitHub rate limits it's APIs, so please configure [.netrc file](https://github.com/octokit/octokit.rb#using-a-netrc-file) with an OAuth token, so queries are counted against 5,000 requests/hour/account instead of the 60 request/hour/IP [rate limit](https://developer.github.com/v3/#rate-limiting).

Example `~/.netrc`:

```
machine api.github.com
  login nanliu
  password <40 char OAuth token>
```

## Operating System

Build matrix

| package format | tool | limitations |
| --- | --- | --- |
| Redhat RPM | fpm | requires init.d workaround |
| Debian Deb | fpm | requires init.d workaround |
| MacOS pkg | fpm | /usr/local/bin due to El Capitan's Systemm Integrity Protection (SIP) |
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
