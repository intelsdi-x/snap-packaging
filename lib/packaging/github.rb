require 'netrc'
require 'octokit'

module Packaging
  class Github
    @@client = Octokit::Client.new(:netrc => true) if File.exists? File.join(ENV["HOME"], ".netrc")

    def initialize
      enable_http_cache
    end

    def issues name
      # Use the authenticated Octokit client when available
      if @@client
        @@client.issues name
      else
        Octokit.issues name
      end
    end

    def repo name
      # Use the authenticated Octokit client when available
      if @@client
        @@client.repo name
      else
        Octokit.repo name
      end
    end

    def enable_http_cache
      require 'faraday-http-cache'
      stack = Faraday::RackBuilder.new do |builder|
        builder.use Faraday::HttpCache, :serializer => Marshal
        builder.use Octokit::Response::RaiseError
        builder.adapter Faraday.default_adapter
      end

      Octokit.middleware = stack
    rescue LoadError
    end
  end
end
