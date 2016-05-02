require 'octokit'

module Packaging
  class Github
    def initialize(repo)
      enable_http_cache

      @repo = Octokit.repo repo
    end

    def enable_http_cache
      require 'faraday-http-cache'
      stack = Faraday::RackBuilder.new do |builder|
        builder.use Faraday::HttpCache
        builder.use Octokit::Response::RaiseError
        builder.adapter Faraday.default_adapter
      end

      Octokit.middleware = stack
    rescue LoadError
    end

    def enable_netrc
      netrc_file = File.join(ENV['HOME'], '.netrc')
      if File.exists? netrc_file
        require 'netrc'
        @client = Octokit::Client.new(:netrc => true)
        @client.login
      end
    end
  end
end
