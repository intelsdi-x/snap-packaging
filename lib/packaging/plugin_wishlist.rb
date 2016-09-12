require 'set'
require 'packaging/github'

module Packaging
  module Plugins
    module Wishlist

    def self.metadata
      data = []

        # load all issues from the Snap core repository
        github = Packing::Github.new
        issues = github.issues 'intelsdi-x/snap'

        # find all issues where
        issues.find_all do |issue|
          # you find the label for plugin-wishlist
          issues.find do |label|
            label.name == 'plugin-wishlist'
          end

          data << {
            name: "the name",
            type: "type",
            description: "repo.description" || "No description.",
            url: "repo.html_url",
          }
        end
      end

      "myfcn(\n" + JSON.pretty_generate(data) + "\n)"
    end
  end
end
