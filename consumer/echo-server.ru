require 'rubygems'
require "cuba"
require 'net/http'

load File.join(File.dirname(__FILE__), "../server/all.rb")

Cuba.define do

  on req.post? do

    on "events", param("metric"), param("timestamp"), param("value") do |m, ts, v|
      metric = Core::Metric.new(m)
      value = Core::Value.parse(metric, ts, v)
      puts value.inspect
    end

  end
end

run Cuba
