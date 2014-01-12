module Core

  class Value

    attr_reader :timestamp, :value

    def initialize(timestamp, value)
      @timestamp = Preconditions.assert_class(timestamp, Time)
      @value = value # Float or Integer
    end

    def timestamp_string
      @timestamp.utc.strftime(Core::Constants::DATE_PATTERN)
    end

    def to_json(*a)
      { :timestamp => timestamp_string, :value => @value }.to_json(*a)
    end

  end

end
