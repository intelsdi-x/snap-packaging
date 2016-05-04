require 'helper'

class TestConfig < Packaging::Test
  def test_default_config
    Packaging.config do |config|
      project_root = Pathname.new(__dir__).parent
      assert_path project_root, config.project_path

      artifacts = File.join project_root, 'artifacts'
      assert_path artifacts, config.artifacts_path

      bin = File.join artifacts, 'bin'
      assert_path bin, config.bin_path

      pkg = File.join artifacts, 'pkg'
      assert_path pkg, config.pkg_path

      src = File.join artifacts, 'src'
      assert_path src, config.src_path

      tmp = File.join artifacts, 'tmp'
      assert_path tmp, config.tmp_path

      config = File.join artifacts, 'config'
      assert_path config, config.config_path

      support = File.join artifacts, 'support'
      assert_path support, config.support_path

      assert_equal config.directories, [project_root.to_s, artifacts, bin, pkg, src, tmp].to_set
    end
  end
end

