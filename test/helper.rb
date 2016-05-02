require 'minitest/autorun'
require 'minitest/pride'
require 'pathname'
require 'pry'
require 'packaging'

module Packaging
  class Test < MiniTest::Spec
    def assert_path *paths
      raise ArgumentError, 'assert_path require >= 2 paths' unless paths.size >= 2
      paths = paths.collect do |path|
        path = ::Pathname.new(path) unless path.is_a? ::Pathname
        path
      end

      p = paths.shift
      paths.each do |path|
        assert_equal p, path
      end
    end

    def fixtures
      File.join __dir__, 'fixtures'
    end
  end
end
