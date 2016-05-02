require 'helper'

class TestUtil < Packaging::Test
  def test_valid_symlink?
    source = File.join fixtures, 'source'
    assert_equal true, Packaging::Util.valid_symlink?(source, 'target')
  end

  def test_load_yaml
    valid_conf = File.join fixtures, 'valid.yaml'
    assert_instance_of Hash, Packaging::Util.load_yaml(valid_conf)

    invalid_conf = File.join fixtures, 'invalid.yaml'
    assert_raises Psych::SyntaxError do
      Packaging::Util.load_yaml invalid_conf
    end

    invalid_path = File.join fixtures, 'invalid'
    assert_raises ArgumentError do
      Packaging::Util.load_yaml invalid_path
    end
  end

  def test_semver
    assert_equal '0.1.0', Packaging::Util.semver('0.1.0').to_s
    assert_equal '0.1.0', Packaging::Util.semver('v0.1.0').to_s
    assert_equal '0.1.0', Packaging::Util.semver('v0.1.0-beta').to_s

    assert_raises { Packaging::Util.semver('garbage') }
    assert_raises { Packaging::Util.semver('7abe97') }
  end
end
