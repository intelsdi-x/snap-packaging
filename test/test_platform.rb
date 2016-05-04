require 'helper'

class TestPlatform < Packaging::Test
  def setup
    snap = Packaging.project 'snap'
    snap.repo_url = "https://github.com/intelsdi-x/snap.git"
    snap.maintainer = "nan.liu@intel.com"
    snap.license = "Apache-2.0"
    snap.vendor = "Intel SDI-X"
    snap.url = "http://intelsdi-x.github.io/snap/"
    snap.description = "snap is a framework for enabling the gathering of telemetry from systems."

    @platform = Packaging::Platform.new("Redhat", "snap")
    @platform.osarch = "linux/amd64"
    @platform.os_name = "redhat"
    @platform.os_codename = "el"
    @platform.os_version = "10"
    @platform.package_format = "rpm"
    @platform.package_iteration = "1.el10"
    @config = Packaging.config
  end


  def test_initialize
    assert_raises RuntimeError do
      Packaging::Platform.new("Redhat", "bad")
    end

    assert_equal @platform.bin, "/usr/bin"
    assert_equal @platform.etc, "/etc"
    assert_equal @platform.log, "/var/log"
    assert_equal @platform.opt, "/opt"
    assert_equal @platform.man, "/usr/share/man"
    assert_equal @platform.service_files, []
  end

  def test_fpm_command
    assert_equal @platform.fpm_command, %(
fpm \
  -t rpm -s dir -f \
  -C #{@config.tmp_path}/redhat/10 \
  -p #{@config.pkg_path}/os/redhat/10 \
  -n "snap" -v "0.13.0" \
  --iteration "1.el10" \
  -m "nan.liu@intel.com" \
  --license "Apache-2.0" \
  --vendor "Intel SDI-X" \
  --url "http://intelsdi-x.github.io/snap/" \
  --description "snap is a framework for enabling the gathering of telemetry from systems." \
   \
  ./ )
  end

  def test_tmp_path
    assert_equal @platform.tmp_path, File.join(@config.tmp_path, "redhat/10")
  end

  def test_fpm_tmp_path
    assert_equal @platform.tmp_path, @platform.fpm_tmp_path
  end

  def test_out_path
    assert_equal @platform.out_path, File.join(@config.pkg_path, "os/redhat/10")
  end

  def test_fpm_output_path
    assert_equal @platform.tmp_path, @platform.fpm_tmp_path
  end
end

