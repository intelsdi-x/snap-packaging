require 'set'
require 'packaging/github'

module Packaging
  module Plugins

    def self.repos
      config = Packaging.config
      file = File.join config.project_path, 'support', 'snap_plugins.yaml'
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
          fork_count: repo.fork_count,
          star_count: repo.subscribers_count,
          issues_count: repo.open_issues_count,
        }

      end
      puts JSON.pretty_generate data.to_json
    end
  end
end
