require 'helper'

class TestGitRepo < Packaging::Test
  class Tags
    attr_reader :name

    def initialize name
      @name = name
    end
  end

  def setup
    @git = Packaging::GitRepo.new('https://github.com/intelsdi-x/snap.git')
    @repo = MiniTest::Mock.new
    @git.repo = @repo
    @config = Packaging.config
  end

  def test_url
    assert_equal @git.url, 'https://github.com/intelsdi-x/snap.git'
  end

  def test_relative_path
    assert_path @git.relative_path, 'github.com/intelsdi-x/snap'
  end

  def test_absolute_path
    path = File.join @config.project_path, 'artifacts/src/github.com/intelsdi-x/snap'

    assert_path @git.absolute_path, path
  end

  def test_tags
    tags = %w[ v0.13.0-beta v0.12.0-beta 0.2.0 0.1.0 ].collect { |t| Tags.new t }
    @repo.expect :tags, tags

    assert_equal @git.tag_names, %w[ 0.1.0 0.2.0 v0.12.0-beta v0.13.0-beta ]
    assert @repo.verify
  end

  def test_parse_url
    @git.parse_url

    assert_equal @git.name, 'snap'
    assert_equal @git.user, 'intelsdi-x'
  end
end
