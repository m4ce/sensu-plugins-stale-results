#!/usr/bin/env ruby
#
# check-stale-results.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'net/http'
require 'json'
require 'sensu-plugin/utils'
require 'sensu-plugin/check/cli'

class CheckStaleResults < Sensu::Plugin::Check::CLI
  include Sensu::Plugin::Utils

  option :stale,
         :description => "Number of seconds to consider a check result stale (default: 86400)",
         :short => "-s <SECONDS>",
         :long => "--stale <SECONDS>",
         :proc => proc(&:to_i),
         :default => 86400

  option :verbose,
         :description => "Be verbose",
         :short => "-v",
         :long => "--verbose",
         :boolean => true,
         :default => false

  option :warn,
         :description => "Warn if number of stale check results exceeds COUNT (default: 1)",
         :short => "-w <COUNT>",
         :long => "--warn <COUNT>",
         :proc => proc(&:to_i),
         :default => 1

  option :crit,
         :description => "Critical if number of stale check results exceeds COUNT",
         :short => "-c <COUNT>",
         :long => "--crit <COUNT>",
         :proc => proc(&:to_i),
         :default => nil

  def initialize()
    super

    raise "Critical threshold must be higher than the warning threshold" if (config[:crit] and config[:warn] >= config[:crit])

    # get list of sensu results
    @results = get_results()
  end

  def humanize(secs)
    [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map { |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    }.compact.reverse.join(' ')
  end

  def api_request(method, path, &blk)
    if not settings.has_key?('api')
      raise "api.json settings not found."
    end
    http = Net::HTTP.new(settings['api']['host'], settings['api']['port'])
    req = net_http_req_class(method).new(path)
    if settings['api']['user'] && settings['api']['password']
      req.basic_auth(settings['api']['user'], settings['api']['password'])
    end
    yield(req) if block_given?
    http.request(req)
  end

  def get_results()
    results = []

    if req = api_request(:GET, "/results")
      results = JSON.parse(req.body) if req.code == '200'
    end

    results
  end

  def run()
    stale = 0
    footer = "\n\n"
    @results.each do |result|
      if (diff = Time.now.to_i - result['check']['issued']) > config[:stale]
        stale += 1
        footer += "  - check result #{result['client']}/#{result['check']['name']} is stale (#{humanize(diff)})\n"
      end
    end
    footer += "\n"

    if (config[:crit] and stale >= config[:crit])
      msg = "Found #{stale} stale check results (>= #{config[:crit]})"
      msg += footer if config[:verbose]
      critical(msg) 
    end

    if stale >= config[:warn]
      msg = "Found #{stale} stale check results (>= #{config[:warn]})"
      msg += footer if config[:verbose]
      warning(msg) 
    end

    ok("No stale check results found (>= #{config[:warn]})")
  end
end
