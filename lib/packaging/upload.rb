module Packaging
  module Upload
    OS_ALIAS = {
      "/redhat/7"     => "el/7",
      "/redhat/6"     => "el/6",
      "/ubuntu/16.04" => "xenial",
      "/ubuntu/14.04" => "trusty",
    }

    def self.s3 project
      config = Packaging.config

      raise ArgumentError, "Project missing S3 url." unless project.s3_url

      pkg_path = File.join config.pkg_path, "os"
      Packaging::Util.working_dir config.project_path do
        puts `aws s3 cp --recursive --exclude '*.DS_Store' #{pkg_path} #{project.s3_url}`
      end
    end

    def self.bintray_conf
      @bintray_conf ||= Packaging::Util.load_yaml File.join ENV["HOME"], ".bintray"
    end

    def self.bintray project
      pkg_name = project.name
      pkg_version = project.pkgversion

      username = bintray_conf["username"] || raise(ArgumentError, "missing bintray username")
      apikey = bintray_conf["apikey"] || raise(ArgumentError, "missing bintray api key")

      base_url = "https://api.bintray.com/content/#{username}"

      auth = "-u#{username}:#{apikey}"

      packages do |file_path, file_name, file_type, os_path|
        dist = OS_ALIAS[os_path]

        case file_type
        when ".rpm"
          Packaging::Util.working_dir do
            puts "Uploading #{file_name} to bintray"
            puts `curl -sS -T #{file_path} #{auth} #{base_url}/rpm/#{pkg_name}/#{pkg_version}/#{dist}/#{file_name}?publish=1`
          end
        when ".deb"
          Packaging::Util.working_dir do
            puts "Uploading #{file_name} to bintray"
            puts `curl -sS -T #{file_path} #{auth} #{base_url}/deb/#{pkg_name}/#{pkg_version}/#{dist}/#{file_name};deb_distribution=#{dist};deb_component=main;deb_architecture=amd64;publish=1`
          end
        else
          puts "Bintray does not support #{file_type} skipping: #{file_path}"
        end
      end
    end

    def self.packagecloud_conf
      @bintray_conf ||= Packaging::Util.load_json File.join ENV["HOME"], ".packagecloud"
    end

    def self.packagecloud project
      require 'packagecloud'

      username = packagecloud_conf["username"] || raise(ArgumentError, "missing packagecloud username")
      token = packagecloud_conf["token"] || raise(ArgumentError, "missing packagecloud token")

      credentials = Packagecloud::Credentials.new username, token
      client = Packagecloud::Client.new credentials

      packages do |file_path, file_name, file_type, os_path|
        dist = OS_ALIAS[os_path]

        case file_type
        when ".rpm"
          puts "Uploading #{file_name} to packagecloud"
          package = Packagecloud::Package.new :file => file_path
          client.put_package project.name, package, dist
        when ".deb"
          puts "Uploading #{file_name} to packagecloud"
          package = Packagecloud::Package.new :file => file_path
          client.put_package project.name, package, dist
        else
          puts "Packagecloud does not support #{file_type} skipping: #{file_path}"
        end
      end
    end

    def self.packages
      config = Packaging.config
      path = File.join config.pkg_path, "os"

      files = Dir["#{path}/**/*"].reject { |file|
        File.directory? file || file =~ /DS_Store/
      }

      files.each do |file|
        file_path = Pathname.new file
        file_name = file_path.basename
        file_type = file_name.extname
        os_path = file_path.parent.to_s.gsub path, ""

        yield file_path.to_s, file_name, file_type, os_path
      end
    end

  end
end
