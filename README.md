# Snap Packaging

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
| Redhat RPM | fpm | execute on RedHat |
| Debian Deb | fpm | execute on Ubuntu |
| MacOS pkg | fpm | execute on MacOS |
| MacOS Homebrew | homebrew | |

### MacOS

MacOS pkg:

Installation:
```
$ sudo installer -allowUntrusted -verboseR -pkg "/path/to/snap.pkg" -target /
```

List Packages/Files:
```
$ pkgutil --pkgs
$ pkgutil --list com.intel.pkg.snap
```

Remove:

MacOS Homebrew:

Installation:
```
$ brew install snap
```

## Vagrant

The Vagrant VMs are split between build nodes and test nodes. Build nodes are named after OS family and allows building of snap packages for those platforms. Test nodes are named after specific operating systems and allow testing of snap packages built for that specific OS.


