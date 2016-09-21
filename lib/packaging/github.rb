require 'netrc'
require 'octokit'

module Packaging
  class Github
    Octokit.auto_paginate = true
    @@client = Octokit::Client.new(:netrc => true) if File.exists? File.join(ENV["HOME"], ".netrc")

    def initialize
      enable_http_cache
    end

    def client
      @@client || Octokit
    end

    def issues name
      client.issues name
    end

    def repo name
      client.repo name
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
