require 'rubygems'
require "cuba"

load File.join(File.dirname(__FILE__), "all.rb")

class MockDatabase

  def initialize(dir)
    @dir = Preconditions.assert_class(dir, String)
    Preconditions.check_state(File.directory?(@dir), "Dir[%s] not found" % dir)
  end

  def write(value)
    Preconditions.assert_class(value, Core::Value)

    path = File.join(@dir, value.metric.name)
    File.open(path, "a") do |out|
      out << "%s,%s\n" % [value.timestamp_string, value.value]
    end
  end

end

db = MockDatabase.new(File.join(File.dirname(__FILE__), "data"))

Cuba.define do
  on req.get? do
    res.headers["Content-Type"] = "application/json"

    on "metrics/:name" do |name|
      limit = 10
      offset = 0
      metric = Core::Metric.new(name)
      data = metric.data(:limit => limit)
      res.write JSON({
                       :name => name,
                       :data => {
                         :limit => limit,
                         :offset => offset,
                         :values => data
                       }
                     })
    end

    on "metrics" do
      res.write JSON(Core::Metric.all)
    end

  end

  on req.post? do

    on "metrics/:name", param(:timestamp), param(:value) do |name, timestamp, v|
      metric = Core::Metric.new(name)
      value = Core::Value.parse(metric, timestamp, v)
      puts value.inspect
      db.write(value)
    end

  end
end

run Cuba
