module Packaging
  LIBDIR = File.expand_path(File.dirname(__FILE__))
  PROJECT_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "..")

  $:.unshift(LIBDIR) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(LIBDIR)

  require 'packaging/util'
  require 'packaging/config'
  require 'packaging/project'
  require 'packaging/platform'
  require 'packaging/gitrepo'
  require 'packaging/upload'

  @@projects = Set.new
  @@config = Packaging::Config.new

  def self.project name, &block
    project = Packaging::Project.new name
    # This should load all supporting platform
    # project.load_config
    @@projects.add project
    yield project if block
    project
  end

  def self.get name
    @@projects.find { |project| project.name == name }
  end

  def self.configure &block
    yield @@config if block
  end

  def self.config
    @@config
  end
end
