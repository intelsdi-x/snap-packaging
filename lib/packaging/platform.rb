module Packaging
  class Platform

    attr_accessor :os_name
    attr_accessor :os_codename
    attr_accessor :os_version
    attr_accessor :os_family
    attr_accessor :osarch
    attr_accessor :bin
    attr_accessor :etc
    attr_accessor :log
    attr_accessor :opt
    attr_accessor :man
    attr_accessor :service
    attr_accessor :service_files
    attr_accessor :build_vm
    attr_accessor :package_format
    attr_accessor :package_iteration
    attr_accessor :fpm_options

    def initialize name, project_name
      @name = name
      @project = Packaging.get(project_name) ||
        fail("the project #{project_name} does not exist.")
      @config = Packaging.config

      @bin = "/usr/bin"
      @etc = "/etc"
      @log = "/var/log"
      @opt = "/opt"
      @man = "/usr/share/man"
      @service_files = []
    end

    ##
    # generated necessary files/directories in tmp for specific platform

    def prep_package
      create_skeleton
      package_binary
      create_symlink
      package_config
      package_example
      package_service
      generate_man
    end

    ##
    # directories to be created, can omit parent directories because of mkdir_p

    def skel_directories
      name = @project.name
      [
        @bin,
        File.join(@etc, name),
        File.join(@etc, name, 'keyrings'),
        File.join(@log, name),
        File.join(@opt, name, '/bin'),
        File.join(@opt, name, '/plugins'),
      ].flatten.uniq.compact
    end

    def create_skeleton
      dirs = skel_directories.collect { |path| File.join tmp_path, path }
      FileUtils.mkdir_p dirs
    end

    def package_binary
      opt_bin = File.join tmp_path, @opt, @project.name, "bin"
      go_binary_files.each do |file|
        FileUtils.cp file, opt_bin
      end
    end

    def package_config
      config_file = File.join @config.support_path, "snapd.conf"
      staging_file = File.join tmp_path, @etc, @project.name, "snapd.conf"

      FileUtils.cp config_file, staging_file
    end

    def package_example
      example_path = File.join @project.repo.dir.path, 'examples'
      staging_path = File.join tmp_path, @opt, @project.name

      FileUtils.cp_r example_path, staging_path
    end

    def generate_man
      mandocs = Dir["#{@config.support_path}/**/*.mdoc"]
      mandocs.each do |file|
        man_page = File.basename file, '.mdoc'
        section = man_page[-1]
        section_path = File.join tmp_path, @man, "man#{section}"
        man_path = File.join section_path, man_page

        Packaging::Util.mkdir_p section_path
        Packaging::Util.working_dir do
          `mandoc -Tman #{file} > #{man_path}`
        end
      end
    end

    def package_service
      @service_files.each do |file, conf_dir|
        source = File.join @config.support_path, file
        target = File.join tmp_path, conf_dir

        target_dir = Pathname.new(target).parent
        Packaging::Util.mkdir_p target_dir

        FileUtils.cp source, target
      end
    end

    def create_symlink
      go_binary_files.each do |file|
        filename = Pathname.new(file).basename
        link = File.join tmp_path, @bin, filename
        target = File.join @opt, @project.name, 'bin', filename
        Packaging::Util.ln_s link, target
      end
    end

    def fpm_command
      @fpm_command ||= %(
fpm \
  -t #{@package_format} -s dir -f \
  -C #{fpm_tmp_path} \
  -p #{fpm_output_path} \
  -n "#{@project.name}" -v "#{@project.pkgversion}" \
  --iteration "#{@package_iteration}" \
  -m "#{@project.maintainer}" \
  --license "#{@project.license}" \
  --vendor "#{@project.vendor}" \
  --url "#{@project.url}" \
  --description "#{@project.description}" \
  #{@fpm_options} \
  ./ )
    end

    def fpm
      Packaging::Util.mkdir_p out_path
      Packaging::Util.working_dir do
        if @build_vm
          puts `
vagrant ssh #{@build_vm} -c \
  '#{fpm_command}'`
        else
          puts `#{fpm_command}`
        end
      end
    end

    ##
    # internal output path

    def tmp_path
      File.join @config.tmp_path, @os_name, @os_version
    end

    def fpm_tmp_path
      if @build_vm
        tmp_path.sub @config.project_path, ""
      else
        tmp_path
      end
    end

    def out_path
      File.join @config.pkg_path, "os", @os_name, @os_version
    end

    def fpm_output_path
      if @build_vm
        out_path.sub @config.project_path, ""
      else
        out_path
      end
    end

    def go_binary_path
      File.join @config.pkg_path, @osarch
    end

    def go_binary_files
      Dir.glob("#{go_binary_path}/*")
    end
  end
end
