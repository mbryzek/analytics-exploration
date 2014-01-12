module Core

  class Value

    attr_reader :metric, :timestamp, :value

    def initialize(metric, timestamp, value)
      @metric = Preconditions.assert_class(metric, Metric)
      @timestamp = Preconditions.assert_class(timestamp, Time)
      @value = value # Float or Integer
    end

    def timestamp_string
      @timestamp.utc.strftime(Core::Constants::DATE_PATTERN)
    end

    def to_json(*a)
      { :timestamp => timestamp_string, :value => @value }.to_json(*a)
    end

    def Value.parse(metric, timestamp_string, value_string)
      Preconditions.assert_class(metric, Metric)
      Preconditions.assert_class(timestamp_string, String)
      Preconditions.assert_class(value_string, String)

      num = (value_string.to_i.to_s == value_string) ? value_string.to_i : value_string.to_f
      Core::Value.new(metric, Time.parse(timestamp_string), num)
    end

  end

end
