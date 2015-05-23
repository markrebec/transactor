module Transactor
  module Improv
    class Transaction
      attr_reader :performance

      def perform
        @transaction.performances << @performance
        @transaction.transaction! do
          performances.last.perform
        end
      end

      def rollback(&block)
        @performance.rollback(&block)
        self
      end

      def actor
        @performance.actor
      end

      def result
        @performance.result
      end

      protected

      def initialize(*args, &block)
        @transaction = Transactor::Transaction.new
        @performance = Improv::Performance.new(Improv::Actor, *args)
        @performance.actor.rollback_on_failure!
        @performance.perform(&block)
      end
    end
  end
end
