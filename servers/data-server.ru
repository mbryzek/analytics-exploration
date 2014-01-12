require 'rubygems'
require "cuba"
require "json"

load File.join(File.dirname(__FILE__), "lib/preconditions.rb")
load File.join(File.dirname(__FILE__), "core/constants.rb")
load File.join(File.dirname(__FILE__), "core/metric.rb")
load File.join(File.dirname(__FILE__), "core/value.rb")

Cuba.define do
  on req.head? do
    res.headers["X-Analytics-Platform-Version"] = "0.0.1"
  end

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
end

run Cuba
