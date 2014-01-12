module Core

  class Value

    attr_reader :timestamp, :value

    def initialize(timestamp, value)
      @timestamp = Preconditions.assert_class(timestamp, Time)
      @value = Preconditions.assert_class(value, Integer)
    end

    def to_json(*a)
      { :timestamp => @timestamp.utc.strftime(Core::Constants::DATE_PATTERN), :value => @value.to_s }.to_json(*a)
    end

  end

end
