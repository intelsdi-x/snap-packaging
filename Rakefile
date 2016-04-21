# NOTE: Using rake instead of writing a shell script because Ruby seems
# unavoidable between FPM and homebrew.

require 'rake'
require 'fileutils'
require 'pathname'
require 'yaml'

begin
  require 'pry'
rescue LoadError
end

# Operating System Support Matrix
SUPPORTED_OS = [
  "redhat/7",
  "ubuntu/1604",
  "macos/10.11",
]

GO_VERSION = "1.6.1"

desc "Show the list of Rake tasks (rake -T)"
task :help do
  sh "rake -T"
end
task :default => :help

# Custom Exceptions:
class UnsupportedOSError < NotImplementedError; end

def os_family
  output = %x{uname -a}
  case output
  when /^Darwin/
    family = "MacOS"
  when /^Linux/
    if File.exists? "/etc/redhat-release"
      family = "RedHat"
    elsif File.exists? "/etc/lsb-release"
      family = File.read("/etc/lsb-release").match(/^DISTRIB_ID=(.*)/)[1]
    end
  end

  family ||= "Unknown"
end

def temp_dir
end

def require_fpm
  require 'fpm'
  require 'fpm/rake_task'
end

def build_rpm
end

def build_deb
end

module Metadata
  class Github
    require 'octokit'

    def initialize(repo)
      enable_http_cache

      @repo = Octokit.repo repo
    end

    def enable_http_cache
      require 'faraday-http-cache'
      stack = Faraday::RackBuilder.new do |builder|
        builder.use Faraday::HttpCache
        builder.use Octokit::Response::RaiseError
        builder.adapter Faraday.default_adapter
      end

      Octokit.middleware = stack
    rescue LoadError
    end

    def enable_netrc
      netrc_file = File.join(ENV['HOME'], '.netrc')
      if File.exists? netrc_file
        require 'netrc'
        @client = Octokit::Client.new(:netrc => true)
        @client.login
      end
    end

    %w{issues, release}
  end

  class Git
    attr_reader :repo

    def initialize(repo_name, repo_url)
      require 'git'

      src_path = File.join(Pathname.new(__FILE__).parent,'artifacts/src')

      repo = repo_url.match(%r{^http://(.*)})
      binding.pry
      #repo_path = File.join(src_path, repo_name)
      #if File.exists? repo_path
      #  @repo = ::Git.open(repo_path)
      #  @repo.fetch
      #else
      #  @repo = ::Git.clone(repo_url, repo_name, :path => src_path)
      #end
    end

    def tags
      require 'semantic'
      @tags ||= @repo.tags.sort_by do |tag|
        # NOTE: v0.13.0-beta is not semantic versioning we treat it as 0.13.0
        begin
          Semantic::Version.new tag.name
        rescue ArgumentError
          version = tag.name.match(/(\d*\.\d*\.\d*)/)[0]
          Semantic::Version.new version
        end
      end
    end

    def tag_names
      tags.collect { |tag| tag.name }
    end

    def latest_release
      tags.last
    end

    def checkout_latest_release
      @repo.checkout(latest_release.name)
    end

    def method_missing(method, *argument, &block)
      @repo.send(method, *argument, &block)
    end
  end
end

namespace :setup do
  desc "create artifacts folders"
  task :artifacts do
    root_dir = Pathname.new(__FILE__).dirname
    folders = [ "artifacts/src" ]
    folders += SUPPORTED_OS.collect { |os| [ File.join('artifacts/pkg/os', os) ] }.flatten
    folders.each do |dir|
      FileUtils.mkdir_p(File.join root_dir, dir)
    end
  end

  desc "gvm environment for local compilation"
  task :gvm do
    # NOTE: does not work with gvm environment wrapping yet.
    #sh "gvm use go1.6.1"
    #sh "gvm pkgset use snap || gvm pkgset create snap"
    #sh "go get github.com/mitchellh/gox"
    #sh "go get github.com/tools/godep"
  end
end

namespace :package do
  desc "build go binary"
  task :go do
    snap_repo = Metadata::Git.new "snap", "https://github.com/intelsdi-x/snap.git"
    snap_repo.checkout_latest_release

    binding.pry
  end

  desc "generate all RedHat RPM packages"
  task :redhat => [:redhat_7]

  # NOTE: systemd service script
  desc "generate RedHat 7 RPM Packages"
  task :redhat_7 do
  end

  # NOTE: init.d service script
  desc "generate RedHat 6 RPM Packages"
  task :redhat_6 do
  end

  # NOTE: no fink/macports
  desc "generate all supported MacOS packages."
  task :macos => [:mac_pkg, :mac_dmg, :homebrew]

  # NOTE: essentially running
  # fpm -s dir -t osxpkg -n "snap" -v v0.13.0 --prefix /opt --license "Apache-2.0" -m nan.liu@intel.com --url http://intelsdi-x.github.io/snap/ --description "snap is a framework for enabling the gathering of telemetry from systems." --osxpkg-identifier-prefix com.intel.pkg ./snap-v0.13.0-beta
  desc "generate MacOS pkg package."
  task :mac_pkg do
    raise(NotImplementedError, 'Mac packages must be built on MacOS') unless os_family == 'MacOS'
    require_fpm
    sh 'echo "hello"'
  end
end
