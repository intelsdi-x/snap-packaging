module Packaging

  class Project
    attr_accessor :name
    attr_accessor :license
    attr_accessor :description
    attr_accessor :maintainer
    attr_accessor :url
    attr_accessor :repo_url
    attr_accessor :vendor

    attr_accessor :config

    attr_accessor :s3_repo

    def initialize(name, &block)
      @name = name
      @config = Packaging.config
    end

    def load_config
      config_path = @config.config_path

      working_dir config_path do
        Dir.glob("**/*.rb").each do |file|
          path = File.join config_path file
          require_relative path
        end
      end
    end

    def repo
      @repo ||= Packaging::GitRepo.new @repo_url
    end

    def checkout version=nil
      if version
        @gitversion = version
        repo.checkout version
      else
        @gitversion =  repo.latest_release.name
        repo.checkout @gitversion
      end
    end

    ##
    # if it can not be converted to semver, we assume it's a git sha or branch

    def pkgversion
      Packaging::Util.semver gitversion
    rescue
      gitversion
    end

    def gitversion
      @gitversion ||= repo.latest_release.name
    end
  end
end
