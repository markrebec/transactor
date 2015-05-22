module Transactor
  module Improv
    class Actor < Transactor::Actor
      def perform(&block)
        block_given? ? instance_eval(&block) : super
      end

      def rollback(&block)
        block_given? ? instance_eval(&block) : super
      end
    end
  end
end
