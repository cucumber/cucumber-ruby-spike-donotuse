module SteppingStone
  class Reporter
    def initialize
      @results = []
    end

    def add_result(result)
      @results << result
    end

    def to_s
      @results.map do |result|
        case result.result
        when :pending
          "P"
        when :passed
          "."
        when :failed
          "F"
        when :missing
          "M"
        else
          raise "This should never happen"
        end
      end.join
    end
  end
end