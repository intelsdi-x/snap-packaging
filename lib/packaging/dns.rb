require 'dnsimple'

module Packaging
  module DNS
    DOMAIN='snap-telemetry.io'

    def self.dnsimple_conf
      @dnsimple_conf ||= Packaging::Util.load_yaml File.join ENV["HOME"], ".dnsimple"
    end

    def self.client
      token = dnsimple_conf["token"] || raise(ArgumentError, "missing packagecloud token")

      @client ||= Dnsimple::Client.new(access_token: token)
    end

    def self.account_id
      @account_id ||= client.identity.whoami.data.account.id
    end

    def self.list
      records = client.zones.all(account_id, DOMAIN, :filter => {:name_like => 'dl'})
      puts records.data.collect{|i| {i.name => i.content}}
    end

    def self.records(version)
      {
        "xenial.pkg.dl" => "https://packagecloud.io/intelsdi-x/snap/packages/ubuntu/xenial/snap-telemetry_#{version}-1xenial_amd64.deb/download",
        "trusty.pkg.dl" => "https://packagecloud.io/intelsdi-x/snap/packages/ubuntu/trusty/snap-telemetry_#{version}-1trusty_amd64.deb/download",
        "el7.pkg.dl" => "https://packagecloud.io/intelsdi-x/snap/packages/el/7/snap-telemetry-#{version}-1.el7.x86_64.rpm/download",
        "el6.pkg.dl" => "https://packagecloud.io/intelsdi-x/snap/packages/el/6/snap-telemetry-#{version}-1.el6.x86_64.rpm/download",
        "mac.pkg.dl" => "https://github.com/intelsdi-x/snap/releases/download/#{version}/snap-telemetry-#{version}.pkg",
        "mac.tar.dl" => "https://github.com/intelsdi-x/snap/releases/download/#{version}/snap-#{version}-darwin-amd64.tar.gz",
        "linux.tar.dl" => "https://github.com/intelsdi-x/snap/releases/download/#{version}/snap-#{version}-linux-amd64.tar.gz"
      }
    end

    def self.update(version)
      records(version).each do |name, link|
        record = client.zones.all(account_id, DOMAIN, :filter => { :name => name })
        raise(Exception, "DNS record #{name} not found") if record.data.size != 1

        id = record.data.first.id
        puts "Updating #{name}.#{DOMAIN} to #{link}"
        client.zones.update_record(account_id, DOMAIN, id, content: link)
      end
    end
  end
end
