require 'set'
require 'packaging/github'

module Packaging
  module Plugins

    def self.repos
      config = Packaging.config
      file = File.join config.support_path, "snap_plugins.yaml"
      Packaging::Util.load_yaml file
    end

    def self.metadata
      data = []

      repos.each do |name|
        github = Packaging::Github.new
        repo = github.repo name
        type = case repo.name
               when /collector/
                 "collector"
               when /processor/
                 "processor"
               when /publisher/
                 "publisher"
               else
                 "unknown"
               end

        data << {
          name: repo.name.split('-').last,
          full_name: repo.name,
          type: type,
          owner: repo.owner.login,
          desription: repo.description || "No description.",
          url: repo.html_url,
          fork_count: repo.forks_count,
          star_count: repo.stargazers_count,
          watch_count: repo.subscribers_count,
          issues_count: repo.open_issues_count,
        }

      end

      JSON.pretty_generate data
    end
  end
end
