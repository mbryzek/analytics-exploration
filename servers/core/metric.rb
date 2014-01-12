module Core

  class Metric

    def initialize(name)
      @name = name
    end

    def Metric.all
      Dir.glob("#{Core::Constants::METRIC_DIR}/*").sort.select { |f| !f.match(/~$/) }.map { |f| Metric.new(File.basename(f)) }
    end

    def data(opts={})
      limit = Preconditions.assert_class_or_nil(opts.delete(:limit), Integer)
      Preconditions.assert_empty_opts(opts)

      file = File.join(Core::Constants::METRIC_DIR, @name)
      Preconditions.check_state(File.exists?(file), "Missing data file for metric: %s" % file)

      values = []
      IO.readlines(file).each do |line|
        if value = parse(line)
          values << value
          if limit && values.size >= limit
            break
          end
        end
      end
      values
    end

    def to_json(*a)
      { :name => @name }.to_json(*a)
    end

    private
    def parse(line)
      if line.to_s.strip == ""
        nil
      else
        ts, value = line.split(",", 2)
        Value.new(Time.parse(ts), value.to_i)
      end
    end
  end

end
