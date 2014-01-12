require 'rubygems'
require "cuba"

load File.join(File.dirname(__FILE__), "../server/all.rb")

class MockDatabase

  def initialize(dir)
    @dir = Preconditions.assert_class(dir, String)
    Preconditions.check_state(File.directory?(@dir), "Dir[%s] not found" % dir)
  end

  def write(metric, value)
    Preconditions.assert_class(metric, Core::Metric)
    Preconditions.assert_class(value, Core::Value)

    path = File.join(@dir, metric.name)
    File.open(path, "a") do |out|
      out << "%s,%s\n" % [value.timestamp_string, value.value]
    end
  end

end

Cuba.define do

  db = MockDatabase.new(File.join(File.dirname(__FILE__), "data"))

  on req.post? do

    on "events", param("metric"), param("timestamp"), param("value") do |m, ts, v|
      metric = Core::Metric.new(m)
      num = (v.to_i.to_s == v) ? v.to_i : v.to_f
      value = Core::Value.new(Time.parse(ts), num)
      db.write(metric, value)
      #res.write "ok"
    end

  end
end

run Cuba
