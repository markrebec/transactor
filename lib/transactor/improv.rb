module Transactor
  class Improv < Performance
    def perform(&block)
      if block_given?
        super(&block)
      else
        super { nil }
      end
    end

    def rollback(&block)
      if block_given?
        super(&block)
      else
        super { nil }
      end
    end

    protected

    def initialize(*args, &block)
      super(Actor, *args, &block)
    end
  end
end
