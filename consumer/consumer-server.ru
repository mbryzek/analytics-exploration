require 'rubygems'
require "cuba"

load File.join(File.dirname(__FILE__), "../server/all.rb")

# A made up metric that combines heart rate and ekg. Every 100 data
# points, we compute the probability that the user will have a heart
# attack in the next 40 years.
class MockHeartAttackProbability

  # @param callback function call with every new published data point
  def initialize(callback)
    @callback = callback
    @heartrates = []
    @ekgs = []
    @counter = 0
  end

  def add(value)
    Preconditions.assert_class(value, Core::Value)

    if value.metric.name == "heartrate"
      @heartrates << value.value
    elsif value.metric.name == "ekg"
      @ekgs << value.value
    else
      raise "Unknown metric: %s" % value.metric.name
    end
    @counter += 1
    if @counter >= 10
      val = Core::Value.new(value.metric, Time.now.utc, rand(100) / 100.0)
      @callback.call(val)
      @counter = 0
    end
  end

end

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

heartattack_metric = Core::Metric.new("heartattack")
heartattack_analytics = MockHeartAttackProbability.new(Proc.new { |val|
                                                         puts "HA: %s" % val.inspect
                                                         db.write(heartattack_metric, val)
                                                       })

Cuba.define do

  on req.post? do

    on "events", param("metric"), param("timestamp"), param("value") do |m, ts, v|
      metric = Core::Metric.new(m)
      value = Core::Value.parse(metric, ts, v)
      db.write(value)
      heartattack_analytics.add(value)
    end

  end
end

run Cuba
