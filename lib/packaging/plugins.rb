require 'set'
require 'packaging/github'

module Packaging
  module Plugins

    def self.repos
      config = Packaging.config
      file = File.join config.support_path, "snap_plugins.yaml"
      Packaging::Util.load_yaml file
    end

    def self.plugin_name(repo)
      repo.name.match(/^snap-plugin-(collector|processor|publisher)-(.*)$/)

      name = $2 || raise(ArgumentError, "Unknown snap_plugin: #{repo.name}")

      {
        'ceph': 'CEPH',
        'cpu': 'CPU',
        'dbi': 'DBI',
        'heka': 'HEKA',
        'hana': 'HANA',
        'haproxy': 'HAproxy',
        'iostat': 'IOstat',
        'influxdb': 'InfluxDB',
        'mysql': 'MySQL',
        'nfs-client': 'NFS Client',
        'opentsdb': 'OpenTSDB',
        'osv': 'OSv',
        'postgresql': 'PostgreSQL',
        'pcm': 'PCM',
        'psutil': 'PSUtil',
        'rabbitmq': 'RabbitMQ',
      }[name.to_sym] || name.slice(0,1).capitalize + name.slice(1..-1)
    end

    def self.wishlist
      data = []

      github = Packaging::Github.new
      snap_issues = github.issues 'intelsdi-x/snap'

      wishlist = snap_issues.find_all{ |issue| issue.labels.find{|label| label.name=='plugin-wishlist'} }
      wishlist.each do |issue|
        data << {
          title: issue.title,
          issue: issue.number,
          description: issue.body,
        }
      end

      JSON.pretty_generate data
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
          name: plugin_name(repo),
          #full_name: repo.name,
          type: type.slice(0,1).capitalize + type.slice(1..-1),
          #owner: repo.owner.login,
          description: repo.description || "No description.",
          url: repo.html_url,
          #fork_count: repo.forks_count,
          #star_count: repo.stargazers_count,
          #watch_count: repo.subscribers_count,
          #issues_count: repo.open_issues_count,
        }

      end

      "myfcn(\n" + JSON.pretty_generate(data) + "\n)"
    end
  end
end
