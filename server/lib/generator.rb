class Generator

  @last_value = nil

  def initialize(metric)
    @metric = Preconditions.assert_class(metric, Core::Metric)
  end

  def generate(opts={})
    timestamp = Preconditions.assert_class_or_nil(opts.delete(:timestamp), Time) || Time.now.utc
    @last_value = generate_value
    Core::Value.new(timestamp, @last_value)
  end

  private
  def generate_value
    if @metric.name ==  "heartrate"
      current = @last_value || 65
      num = rand(20)
      if num < 5
        current - 1
      elsif num >= 15
        current + 1
      else
        current
      end

    elsif @metric.name ==  "ekg"
      current = @last_value || 0
      num = rand(10)
      if num < 5
        current - rand(1000) / 1000.0
      else
        current + rand(1000) / 1000.0
      end

    else
      raise "Don't know how to generate a value for metric[%s]" % @metric
    end
  end
end
