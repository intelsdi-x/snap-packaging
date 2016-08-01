# NOTE: Using rake instead of writing a shell script because Ruby seems
# unavoidable between FPM and homebrew.

require "rake"
require "rake/testtask"
require_relative "lib/packaging"

begin
  require "pry"
rescue LoadError
end

##
# NOTE: currently do not support GVM and dynamic go_version

GO_VERSION = "1.6.2"

@config = Packaging.config
PROJECT_PATH = @config.project_path
SUPPORT_PATH = File.join PROJECT_PATH, "support"
ARTIFACTS_PATH = @config.artifacts_path

@snap = Packaging.project "snap"
@snap.package_name = "snap-telemetry"
@snap.repo_url = "https://github.com/intelsdi-x/snap.git"
@snap.maintainer = "nan.liu@intel.com"
@snap.license = "Apache-2.0"
@snap.vendor = "Intel SDI-X"
@snap.url = "http://intelsdi-x.github.io/snap/"
@snap.description = "Snap is an open telemetry framework designed to simplify the collection, processing and publishing of system data through a single API."
@snap.s3_url = "s3://sdinan/packages"

desc "Show the list of Rake tasks (rake -T)"
task :help do
  sh "rake -T"
end
task :default => :help

Rake::TestTask.new do |task|
  # NOTE: ignore method redefine from bundled gems:
  ENV["RUBYOPT"] += " W0"

  task.libs << "test"
  task.test_files = FileList["test/test*.rb"]
end

namespace :setup do
  desc "create artifacts folders"
  task :artifacts do
    FileUtils.mkdir_p @config.staging_path
  end

  desc "install godep/gox"
  task :godep do
    Packaging::Util.go_build do
      sh %(go get github.com/tools/godep)
      # NOTE: gox curreently have a bug with gcflags option.
      # please apply patch until PR #63 is merged.
      sh %(go get github.com/mitchellh/gox)
    end
  end
end

namespace :build do
  desc "compile snap go binary"
  task :go_binary do
    SUPPORTED_OSARCH= [
      "darwin/amd64",
      "linux/amd64",
    ]

    @snap.checkout

    Packaging::Util.go_build @snap.repo.dir.path do
      SUPPORTED_OSARCH.each do |osarch|
        sh "make deps"
        sh %(
gox \
  -rebuild \
  -osarch "#{osarch}" \
  -ldflags="-w -X main.gitversion=#{@snap.gitversion}" \
  -gcflags="-trimpath=$GOPATH" \
  -output=#{File.join @config.pkg_path, osarch, "snapd"} \
        )
        sh %(
gox \
  -rebuild \
  -osarch "#{osarch}" \
  -ldflags="-w -X main.gitversion=#{@snap.gitversion}" \
  -gcflags="-trimpath=$GOPATH" \
  -output=#{File.join @config.pkg_path, osarch, "snapctl"} \
  ./cmd/snapctl
        )
      end
    end
  end
end

namespace :package do
  desc "build all packages"
  task :all => [:redhat, :ubuntu, :macos]

  desc "build all Ubuntu deb packages."
  task :ubuntu => [:ubuntu_1604, :ubuntu_1404]

  desc "build Ubuntu Xenial (16.04) packages"
  task :ubuntu_1604 do
    plat = Packaging::Platform.new "ubuntu_1404", "snap"
    plat.osarch = "linux/amd64"
    plat.os_name = "ubuntu"
    plat.os_codename = "xenial"
    plat.os_version = "16.04"
    plat.package_format = "deb"
    plat.package_iteration = "1xenial"
    plat.build_vm = "debian"

    plat.service = "systemd"
    plat.service_files = {
      "snap-telemetry.service" => "/lib/systemd/system/snap-telemetry.service",
    }

    plat.prep_package
    plat.fpm
  end

  desc "build Ubuntu Trusty (14.04) packages"
  task :ubuntu_1404 do
    plat = Packaging::Platform.new "ubuntu_1404", "snap"
    plat.osarch = "linux/amd64"
    plat.os_name = "ubuntu"
    plat.os_codename = "trusty"
    plat.os_version = "14.04"
    plat.package_format = "deb"
    plat.package_iteration = "1trusty"
    plat.build_vm = "debian"

    plat.service = "initd"
    plat.service_files = {
      "snapd.deb.initd" => "/etc/init.d/snap-telemetry",
    }

    plat.prep_package
    plat.fpm
  end

  desc "build all RedHat RPM packages"
  task :redhat => [:redhat_7, :redhat_6]

  desc "build RedHat 7 RPM packages"
  task :redhat_7 do
    plat = Packaging::Platform.new "redhat_7", "snap"
    plat.osarch = "linux/amd64"
    plat.os_name = "redhat"
    plat.os_codename = "el7"
    plat.os_version = "7"
    plat.package_format = "rpm"
    plat.package_iteration = "1.el7"
    plat.build_vm = "redhat"

    plat.service = "systemd"
    plat.service_files = {
      "snap-telemetry.service" => "/usr/lib/systemd/system/snap-telemetry.service",
    }

    plat.prep_package
    plat.fpm
  end

  desc "build RedHat 6 RPM packages"
  task :redhat_6 do
    plat = Packaging::Platform.new "redhat_6", "snap"
    plat.osarch = "linux/amd64"
    plat.os_name = "redhat"
    plat.os_codename = "el6"
    plat.os_version = "6"
    plat.package_format = "rpm"
    plat.package_iteration = "1.el6"
    plat.build_vm = "redhat"

    plat.service = "initd"
    plat.service_files = {
      "snapd.rh.initd" => "/etc/rc.d/init.d/snap-telemetry",
      "snapd.sysconfig" => "/etc/sysconfig/snap-telemetry",
    }

    plat.prep_package
    plat.fpm
  end

  # NOTE: no plans for fink/macports support
  desc "build all supported MacOS packages."
  task :macos => [:mac_pkg]

  desc "build MacOS pkg package."
  task :mac_pkg do
    plat = Packaging::Platform.new "mac_pkg", "snap"
    plat.osarch = "darwin/amd64"
    plat.os_name = "macos"
    plat.os_codename = "elcapitan"
    plat.os_version = "10.11"
    plat.package_format = "osxpkg"
    plat.package_iteration = "1"

    plat.service = "launchctl"

    # MacOS El Capitan System Integrity Protection prevents packages from deploying to /usr/bin
    plat.bin = "/usr/local/bin"

    plat.prep_package

    plat.fpm_options = "--osxpkg-identifier-prefix com.intel.pkg"
    plat.fpm
  end
end

namespace :upload do
  desc "upload packages to AWS s3"
  task :s3 do
    Packaging::Upload.s3 @snap
  end

  desc "upload packages to Bintray"
  task :bintray do
    Packaging::Upload.bintray @snap
  end

  desc "upload packages to PackageCloud.io"
  task :packagecloud do
    Packaging::Upload.packagecloud @snap
  end
end

namespace :plugin do
  desc "generate plugin metadata"
  task :metadata do
    puts Packaging::Plugins.metadata
  end
end

namespace :notify do
  desc "send a twitter tweet"
  task :tweet do
    Packaging::Notify::Twitter.tweet "Snap packages version #{@snap.pkgversion} now available: https://packagecloud.io/intelsdi-x/snap"
  end

  desc "send a slack notification"
  task :slack do
    Packaging::Notify::Slack.message "#build-snap", "Snap packages version <https://packagecloud.io/nanliu/snap|#{@snap.pkgversion} now available.>"
  end
end
