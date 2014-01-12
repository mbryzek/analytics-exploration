require 'rubygems'
require "cuba"
require 'net/http'

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
    @metric = Core::Metric.new("heartattack")
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
      @callback.call(Core::Value.new(@metric, Time.now.utc, rand(100) / 100.0))
      @counter = 0
    end
  end

end

class Publisher

  def initialize(server_uri)
    @server_uri = Preconditions.assert_class(server_uri, String)
  end

  def publish(value)
    Preconditions.assert_class(value, Core::Value)
    metrics_url = File.join(@server_uri, "metrics", value.metric.name)
    puts metrics_url
    uri = URI(metrics_url)
    begin
      Net::HTTP.post_form(uri, 'timestamp' => value.timestamp_string, 'value' => value.value)
    rescue Exception => e
      puts "ERROR: %s" % e.to_s
    end
  end

end

publisher = Publisher.new("http://localhost:10001")

heartattack_analytics = MockHeartAttackProbability.new(Proc.new { |value|
                                                         puts "HA: %s" % value.inspect
                                                         publisher.publish(value)
                                                       })

Cuba.define do

  on req.post? do

    on "events", param("metric"), param("timestamp"), param("value") do |m, ts, v|
      metric = Core::Metric.new(m)
      value = Core::Value.parse(metric, ts, v)
      heartattack_analytics.add(value)
    end

  end
end

run Cuba
