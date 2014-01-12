require 'rubygems'
require "cuba"

load File.join(File.dirname(__FILE__), "all.rb")

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
end

run Cuba
