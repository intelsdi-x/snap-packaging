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

desc "Show the list of Rake tasks (rake -T)"
task :help do
  sh "rake -T"
end
task :default => :help

# Custom Exceptions:
class UnsupportedOSError < NotImplementedError; end

def operating_system
  output = %x{uname -a}
  case output
  when /^Darwin/
    'MacOS'
  else
    'Unknown'
  end
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
      #netrc_file = File.join(ENV['HOME'], '.netrc')
      #enable_netrc = File.exists? netrc_file
      #require 'netrc' if enable_netrc
      #@client = Octokit::Client.new(:netrc : enable_netrc)
      #@client.login
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
    %w{issues, release}
  end
end


def git_repo(repo_name, repo_url)
  require 'rugged'
  repo_path = File.join('./', repo_name)
  Rugged::Repository.new(repo_path)
rescue Rugged::OSError
  Rugged::Repository.clone_at repo_url, repo_path
  Rugged::Repository.new(repo_path)
end

namespace :package do
  desc "build go binary"
  task :go do
    snap_repo = git_repo "snap", "https://github.com/intelsdi-x/snap.git"
    puts snap_repo.path
    puts snap_repo.head
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
    raise(NotImplementedError, 'Mac packages must be built on MacOS') unless operating_system == 'MacOS'
    require_fpm
    sh 'echo "hello"'
  end
end
