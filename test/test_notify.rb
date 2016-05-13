require 'helper'

class TestNotify < Packaging::Test
  def test_twitter_client
    ENV["HOME"] = File.join fixtures, "invalid"
    assert_raises ArgumentError do
      Packaging::Notify::Twitter.client
    end

    ENV["TWITTER_CONSUMER_KEY"] = "key"
    ENV["TWITTER_CONSUMER_SECRET"] = "secret"
    ENV["TWITTER_ACCESS_TOKEN"] = "token"
    ENV["TWITTER_ACCESS_TOKEN_SECRET"] = "secret"
    client = Packaging::Notify::Twitter.client
    assert_instance_of ::Twitter::REST::Client, client
  end

  def test_slack_client
    ENV["HOME"] = File.join fixtures, "invalid"
    assert_raises ArgumentError do
      Packaging::Notify::Slack.client
    end

    ENV["SLACK_API_TOKEN"] = "invalid"
    client = Packaging::Notify::Slack.client
    assert_instance_of ::Slack::Web::Client, client
  end
end
