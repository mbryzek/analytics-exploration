require 'rubygems'
require "cuba"

load File.join(File.dirname(__FILE__), "../server/all.rb")

Cuba.define do
  on req.post? do

    on "events", param("metric"), param("timestamp"), param("value") do |m, ts, v|
      metric = Core::Metric.new(m)
      num = (v.to_i.to_s == v) ? v.to_i : v.to_f
      value = Core::Value.new(Time.parse(ts), num)
      puts value.inspect
      res.write "ok"
    end

  end
end

run Cuba
