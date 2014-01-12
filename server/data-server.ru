require 'rubygems'
require "cuba"
require 'net/http'

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

class Subscriber

  attr_reader :uri

  def initialize(metric, url)
    @metric = Preconditions.assert_class(metric, Core::Metric)
    Preconditions.assert_class(url, String)
    @uri = URI(url)
  end

  def listens_to?(metric)
    Preconditions.assert_class(metric, Core::Metric)
    metric.name == @metric.name
  end

end

class Broadcast

  def initialize
    @subscribers = []
  end

  def add_subscriber(subscriber)
    Preconditions.assert_class(subscriber, Subscriber)
    @subscribers << subscriber
  end

  def publish(value)
    Preconditions.assert_class(value, Core::Value)
    parameters = { 'metric' => value.metric.name, 'timestamp' => value.timestamp_string, 'value' => value.value }
    uris = @subscribers.select { |s| s.listens_to?(value.metric) }.map(&:uri)
    uris.each do |uri|
      puts "Publishing to uri %s" % uri
      begin
        Net::HTTP.post_form(uri, parameters)
      rescue Exception => e
        puts "ERROR: POST to URI[%s] failed: %s" % [uri.to_s, e.to_s]
      end
    end
  end

end

broadcast = Broadcast.new
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

    on "metrics/:name/subscribe", param(:url) do |name, url|
      metric = Core::Metric.new(name)
      sub = Subscriber.new(metric, url)
      broadcast.add_subscriber(sub)
      puts sub.inspect
    end

    on "metrics/:name", param(:timestamp), param(:value) do |name, timestamp, v|
      metric = Core::Metric.new(name)
      value = Core::Value.parse(metric, timestamp, v)
      puts value.inspect
      db.write(value)
      broadcast.publish(value)
    end

  end
end

run Cuba
