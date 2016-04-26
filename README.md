#snap-v0.13.0-beta Snap Packaging

## Overview

This repo contains some snap packaging tools. (Experimental)

## Installation

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
