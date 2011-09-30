require 'forwardable'
require 'date'

module SteppingStone
  module Model
    class Response
      extend Forwardable

      def_delegators :@request, :event, :arguments, :response_required?
      def_delegators :@result, :passed?, :failed?, :undefined?, :skipped?, :status

      attr_reader :created_at

      def initialize(request, result)
        @request, @result = request, result
        @created_at = DateTime.now
      end

      def halt?
        if response_required?
          failed? or undefined? or skipped?
        else
          failed?
        end
      end

      def important?
        response_required? or !undefined?
      end

      def to_a
        [event, arguments, status]
      end

      def to_s
        # Ugly, but this won't be here for long
        if response_required?
          {
            :passed    => ".",
            :failed    => "F",
            :undefined => "U",
            :skipped   => "S"
          }[status]
        else
          ""
        end
      end
    end
  end
end
