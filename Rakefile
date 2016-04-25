# NOTE: Using rake instead of writing a shell script because Ruby seems
# unavoidable between FPM and homebrew.

require "fpm"
require "fpm/rake_task"
require "rake"
require "fileutils"
require "pathname"
require "yaml"

begin
  require "pry"
rescue LoadError
end

# Operating System Support Matrix
SUPPORTED_OS = [
  "redhat/7",
  "ubuntu/1604",
  "macos/10.11",
]

SUPPORTED_OSARCH= [
  "darwin/amd64",
  "linux/amd64",
]

GO_VERSION = "1.6.1"

PROJECT_PATH = Pathname.new(__FILE__).parent
SUPPORT_PATH = File.join PROJECT_PATH, "support"
ARTIFACTS_PATH = File.join PROJECT_PATH, "artifacts"

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
    require "git"
    require "semantic"

    attr_reader :repo

    def initialize(repo_name, repo_url)
      rel_repo_path = git_url_to_path repo_url
      src_path = File.join ARTIFACTS_PATH, 'src', rel_repo_path.parent
      repo_path = File.join src_path, repo_name

      FileUtils.mkdir_p(src_path) unless File.directory? src_path

      if File.exists? repo_path
        @repo = ::Git.open repo_path
        @repo.fetch
      else
        @repo = ::Git.clone repo_url, repo_name, :path => src_path
      end
    end

    def git_url_to_path(repo_url)
      raise ArgumentError, "repo_url must be https:// or git@" unless repo_url =~ %r{^https://|git@}
      case repo_url
      when %r{^https://}
        path = repo_url.match(%r{https://(.*)})[1]
        Pathname.new path
      when %r{^git@}
        path = repo_url.match(%r{git@(.*)})[1].gsub(':', '/')
        Pathname.new path
      end
    end

    def tags
      @tags ||= @repo.tags.sort_by do |tag|
        tag_to_semver tag
      end
    end

    # NOTE: v0.13.0-beta is treated as 0.13.0 for semantic version
    def tag_to_semver(tag)
      Semantic::Version.new tag.name
    rescue ArgumentError
      version = tag.name.match(/(\d*\.\d*\.\d*)/)[0]
      Semantic::Version.new version
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

  desc "setup GOPATH:PATH and install godep/gox"
  task :go do
    ENV['GOPATH'] = ARTIFACTS_PATH
    ENV['PATH'] += ":#{File.join ARTIFACTS_PATH, 'bin'}"
    sh "go get github.com/tools/godep"
    sh "go get github.com/mitchellh/gox"
  end
end

def temp_work_path(path)
  current_path = Dir.getwd
  Dir.chdir(path)
  yield
ensure
  Dir.chdir(current_path)
end

def files_exists?(*files)
  files.each do |file|
    raise ArgumentError, "Missing file: #{file}" unless File.exists? file
  end
end

namespace :package do
  desc "build go binary"
  task :go do
    snap_repo = Metadata::Git.new "snap", "https://github.com/intelsdi-x/snap.git"
    begin
      release_name = snap_repo.latest_release.name
      snap_repo.checkout(release_name)
    rescue Git::GitExecuteError
    end

    project_path = File.join ARTIFACTS_PATH, "src", "github.com/intelsdi-x/snap"
    package_path = File.join ARTIFACTS_PATH, "pkg"

    temp_work_path(project_path) do
      SUPPORTED_OSARCH.each do |osarch|
        Bundler.with_clean_env do

          ENV["GOPATH"] = ARTIFACTS_PATH
          ENV["PATH"] += ":#{File.join ARTIFACTS_PATH, 'bin'}"

          # NOTE: hide source file path on panic along with -trimpath
          # https://github.com/golang/go/issues/13809
          ENV["GOROOT_FINAL"] = "/usr/local/go"

          #sh "make deps"
          sh %(
gox \
  -rebuild \
  -osarch "#{osarch}" \
  -ldflags="-w -X main.gitversion=#{release_name}" \
  -gcflags="-trimpath=#{ARTIFACTS_PATH}" \
  -output=#{File.join package_path, osarch, "snapd"} \
  -verbose
          )
          sh %(
gox \
  -rebuild \
  -osarch "#{osarch}" \
  -ldflags="-w -X main.gitversion=#{release_name}" \
  -gcflags="-trimpath=$GOPATH" \
  -output=#{File.join package_path, osarch, "snapctl"} \
  ./cmd/snapctl
          )
        end
      end
    end
  end

  desc "generate all RedHat RPM packages"
  task :redhat => [:redhat_7, :redhat_6]

  # NOTE: systemd service script
  desc "generate RedHat 7 RPM Packages"
  task :redhat_7 do
    source_bin = File.join ARTIFACTS_PATH, "pkg", "linux/amd64"
    staging_path = File.join ARTIFACTS_PATH, "tmp", "redhat/7"
    rel_staging_path = "/artifacts/tmp/redhat/7"
    pkg_path = "/artifacts/pkg/os/redhat/7"

    directories = %w{
      /etc/snap
      /etc/snap/keyrings
      /usr/bin
      /usr/lib/systemd/system/
      /opt/snap/bin
      /opt/snap/plugins
      /opt/snap/share/man/man1
      /opt/snap/share/man/man5
      /opt/snap/share/man/man8
    }

    symlinks = {
      "/usr/bin/snapd" => "/opt/snap/bin/snapd",
      "/usr/bin/snapctl" => "/opt/snap/bin/snapctl",
    }

    directories.each do |dir|
      FileUtils.mkdir_p(File.join staging_path, dir)
    end

    symlinks.each do |symlink, target|
      link = File.join staging_path, symlink
      FileUtils.ln_s target, link unless File.symlink? link
    end

    staging_bin = File.join staging_path, "opt/snap/bin"
    snapd_bin = File.join source_bin, "snapd"
    snapctl_bin = File.join source_bin, "snapctl"

    files_exists? snapd_bin, snapctl_bin
    FileUtils.cp snapd_bin, staging_bin
    FileUtils.cp snapctl_bin, staging_bin

    FileUtils.cp File.join(SUPPORT_PATH, "snapd.conf.yaml"), File.join(staging_path, "/etc/snap")
    FileUtils.cp File.join(SUPPORT_PATH, "snapd.service"), File.join(staging_path, "/usr/lib/systemd/system")

    examples_path = File.join ARTIFACTS_PATH, 'src', 'github.com/intelsdi-x/snap/examples'
    FileUtils.cp_r examples_path, File.join(staging_path, "opt/snap/") if File.directory? examples_path

    FileUtils.cp snapctl_bin, staging_bin

    # NOTE: wrapping because how vagrant is packaged:
    # https://github.com/mitchellh/vagrant/issues/6158#issuecomment-153507010
    Bundler.with_clean_env do
      sh %(
vagrant ssh redhat -c \
  'fpm \
  -t rpm -s dir -f\
  -C #{rel_staging_path} \
  -p #{pkg_path} \
  -n "snap" -v "0.13.0" \
  -m nan.liu@intel.com \
  --license "Apache-2.0" \
  --vendor "Intel SDI-X" \
  --url http://intelsdi-x.github.io/snap/ \
  --description "snap is a framework for enabling the gathering of telemetry from systems." \
  --config-files "/etc/snap" \
  ./ '
      )
    end
  end

  # NOTE: init.d service script
  desc "generate RedHat 6 RPM Packages"
  task :redhat_6 do
    source_bin = File.join ARTIFACTS_PATH, "pkg", "linux/amd64"
    staging_path = File.join ARTIFACTS_PATH, "tmp", "redhat/6"
    rel_staging_path = "/artifacts/tmp/redhat/6"
    pkg_path = "/artifacts/pkg/os/redhat/6"

    directories = %w{
      /etc/snap
      /etc/snap/keyrings
      /etc/rc.d/init.d
      /etc/sysconfig
      /usr/bin
      /opt/snap/bin
      /opt/snap/plugins
      /opt/snap/share/man/man1
      /opt/snap/share/man/man5
      /opt/snap/share/man/man8
    }

    symlinks = {
      "/usr/bin/snapd" => "/opt/snap/bin/snapd",
      "/usr/bin/snapctl" => "/opt/snap/bin/snapctl",
    }

    directories.each do |dir|
      FileUtils.mkdir_p(File.join staging_path, dir)
    end

    symlinks.each do |symlink, target|
      link = File.join staging_path, symlink
      FileUtils.ln_s target, link unless File.symlink? link
    end

    staging_bin = File.join staging_path, "opt/snap/bin"
    snapd_bin = File.join source_bin, "snapd"
    snapctl_bin = File.join source_bin, "snapctl"

    files_exists? snapd_bin, snapctl_bin
    FileUtils.cp snapd_bin, staging_bin
    FileUtils.cp snapctl_bin, staging_bin

    FileUtils.cp File.join(SUPPORT_PATH, "snapd.conf.yaml"), File.join(staging_path, "/etc/snap")
    FileUtils.cp File.join(SUPPORT_PATH, "snapd.initd"), File.join(staging_path, "/etc/rc.d/init.d/snapd")
    FileUtils.cp File.join(SUPPORT_PATH, "snapd.sysconfig"), File.join(staging_path, "/etc/sysconfig/snapd")

    examples_path = File.join ARTIFACTS_PATH, 'src', 'github.com/intelsdi-x/snap/examples'
    FileUtils.cp_r examples_path, File.join(staging_path, "opt/snap/") if File.directory? examples_path

    FileUtils.cp snapctl_bin, staging_bin

    # NOTE: wrapping because how vagrant is packaged:
    # https://github.com/mitchellh/vagrant/issues/6158#issuecomment-153507010
    Bundler.with_clean_env do
      sh %(
vagrant ssh redhat -c \
  'fpm \
  -t rpm -s dir -f\
  -C #{rel_staging_path} \
  -p #{pkg_path} \
  -n "snap" -v "0.13.0" \
  -m nan.liu@intel.com \
  --license "Apache-2.0" \
  --vendor "Intel SDI-X" \
  --url http://intelsdi-x.github.io/snap/ \
  --description "snap is a framework for enabling the gathering of telemetry from systems." \
  --config-files "/etc/snap" \
  ./ '
      )
    end
  end

  # NOTE: no fink/macports
  desc "generate all supported MacOS packages."
  task :macos => [:mac_dmg, :homebrew]

  # NOTE: essentially running
  # fpm -s dir -t osxpkg -n "snap" -v v0.13.0 --prefix /opt --license "Apache-2.0" -m nan.liu@intel.com --url http://intelsdi-x.github.io/snap/ --description "snap is a framework for enabling the gathering of telemetry from systems." --osxpkg-identifier-prefix com.intel.pkg ./snap-v0.13.0-beta
  desc "generate MacOS pkg package."
  task :mac_pkg do
    raise(NotImplementedError, 'Mac packages must be built on MacOS') unless os_family == 'MacOS'
    sh 'echo "hello"'
  end

  task :mac_dmg => [:mac_pkg] do
  end

  task :homebrew do
  end
end
