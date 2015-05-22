module Transactor
  module Improv
    class Performance < Transactor::Performance

      def perform(&block)
        if block_given?
          @perform_block = block
        else
          super(&perform_block)
        end
        self
      rescue => e
        raise PerformanceBombed.new(e, self)
      end

      def rollback(&block)
        if block_given?
          @rollback_block = block
        else
          super(&rollback_block)
        end
        self
      end

      def perform_block
        @perform_block ||= Proc.new {}
      end

      def rollback_block
        @rollback_block ||= Proc.new {}
      end
    end
  end
end
