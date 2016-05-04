require "git"

module Packaging
  class GitRepo

    ##
    # git repo name (derived from github url)

    attr_reader :name

    ##
    # git repo user (derived from github url)

    attr_reader :user

    ##
    # git repo url

    attr_reader :url

    def initialize(url)
      @url = url
      @config = Packaging.config
      parse_url
    end

    ##
    # parse the server, user/org, reponame from git url

    def parse_url
      raise ArgumentError, "repo_url must be https:// or git@" unless @url =~ %r{^https://|git@}

      result =  @url.match(%r{^(https://|git@)(.*)[/:](.*)/(.*)(\.git)$})
      _, _, @server, @user, @name = result.to_a
    end

    ##
    # git repo path per go lang convention

    def relative_path
      path = File.join @server, @user, @name
      Pathname.new path
    end

    ##
    # git repo path based on project_path

    def absolute_path
      path = File.join @config.src_path, relative_path
      Pathname.new path
    end

    ##
    # git clone/update repo as appropriate

    def repo
      @repo ||= if ! File.exists? absolute_path
                  Packaging::Util.mkdir_p absolute_path.parent
                  ::Git.clone @url, @name, :path => absolute_path.parent
                elsif File.directory? absolute_path
                  repo = ::Git.open absolute_path
                  repo.fetch
                  repo
                else
                  fail "repo path exists and is not a git directory: #{absolute_path}"
                end
    end

    ##
    # for testing only

    def repo= value
      @repo = value
    end

    ##
    # sort tags based on semver instead of string sort

    def tags
      @tags ||= repo.tags.sort_by do |tag|
        Packaging::Util.semver tag.name
      end
    end

    def tag_names
      tags.collect { |tag| tag.name }
    end

    def latest_release
      tags.last
    end

    def checkout_latest_release
      repo.checkout(latest_release.name)
    end

    def method_missing(method, *argument, &block)
      repo.send(method, *argument, &block)
    end
  end
end
