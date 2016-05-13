module Packaging
  class Config
    GIT_VERSIONS = [:latest_version , :master]

    # attr_accessor  :project_path

    def initialize
    end

    def load_config(file_path)
      settings = Packaging::Util.load_yaml(file_path)
      @project_path ||= settings.project_path
    end

    def project_path
      @project_path ||= ENV['PROJECT_PATH'] ||
        defined?(PROJECT_PATH) ? File.expand_path(PROJECT_PATH) : File.expand_path(File.join(LIBDIR, ".."))
      @project_path
    end

    ##
    # try converting to semver first, otherwise let git checkout sort out if it's branch/ref/tag

    def version=(value)
      @version = Packaging::Util.semver(value)
    rescue
      @version = value
    end

    def config_path
      File.join project_path, 'config'
    end

    def support_path
      File.join project_path, 'support'
    end

    ##
    # these *_path are just convenience path based on project_path

    def artifacts_path
      File.join project_path, 'artifacts'
    end

    sub_dir = %w{ bin pkg src tmp }

    sub_dir.each do |dir|
      define_method("#{dir}_path") do
        File.join artifacts_path, dir
      end
    end

    ##
    # collection of staging directories that needs to be created

    def staging_path
      @directories ||= [ project_path, artifacts_path, bin_path, pkg_path, src_path, tmp_path ].uniq
    end
  end
end
