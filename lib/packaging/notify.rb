module Packaging
  module Notify
    module Twitter
      require 'twitter'

      def self.client
        @client ||= (
          file = File.join ENV["HOME"], ".twitter"
          conf = YAML.load_file file rescue conf = {}
          consumer_key = ENV["TWITTER_CONSUMER_KEY"] || conf["consumer_key"] || raise(ArgumentError, "Missing consumer key in config: #{file}")
          consumer_secret = ENV["TWITTER_CONSUMER_SECRET"] || conf["consumer_secret"] || raise(ArgumentError, "Missing consumer secret in config: #{file}")
          access_token = ENV["TWITTER_ACCESS_TOKEN"] || conf["access_token"] || raise(ArgumentError, "Missing access token in config: #{file}")
          access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"] || conf["access_token_secret"] || raise(ArgumentError, "Missing token secret in config: #{file}")

          ::Twitter::REST::Client.new do |config|
            config.consumer_key        = consumer_key
            config.consumer_secret     = consumer_secret
            config.access_token        = access_token
            config.access_token_secret = access_token_secret
          end
        )
      end

      def self.tweet(text)
        client.update(text)
      end
    end

    module Slack
      require "slack-ruby-client"

      def self.client
        @client ||= (
          ::Slack.configure do |config|
            file = File.join ENV["HOME"], ".slack"
            conf = YAML.load_file file rescue conf = {}
            config.token = ENV["SLACK_API_TOKEN"] || conf["API_TOKEN"] || raise(ArgumentError, "Missing slack api token in config: #{file}.")
          end

          ::Slack::Web::Client.new
        )
      end

      def self.message(channel, text)
        client.chat_postMessage(
          channel: channel,
          as_user: true,
          text: text,
        )
      end
    end
  end
end
