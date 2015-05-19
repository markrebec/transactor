module Transactor
  class Transaction
    attr_reader :performances

    def in_transaction(&block)
      begin
        instance_eval &block
      rescue Exception => e # yes, we want to catch everything
        begin
          rollback
        rescue Exception => e # yes, here too
          raise RollbackFailed.new(e, self)
        end

        raise e
      end
    end

    def transaction!(&block)
      if defined?(ActiveRecord::Base) && ActiveRecord::Base.respond_to?(:transaction)
        ActiveRecord::Base.transaction { in_transaction &block }
      else
        in_transaction &block
      end
      self
    end

    def transaction(&block)
      transaction!(&block)
      true
    rescue => e
      false
    end

    def perform(actor, *args, &block)
      performance = Performance.new(actor, *args)
      performance.perform(&block)
      performances << performance
      performance.result
    rescue => e
      raise PerformanceBombed.new(e, performance)
    end

    def improvise(*args, &block)
      performance = Improv.new(*args)
      performance.perform(&block)
      performances << performance
      performance
    rescue => e
      raise PerformanceBombed.new(e, performance)
    end

    def rollback
      performances.reverse.each do |performance|
        begin
          performance.rollback
        rescue RollbackNotImplemented => e
          # noop, rollback was not implemented
        rescue => e
          # there was an error rolling back the performance
          # do we halt the transaction rollback here? return the performances and allow manual rollbacks?
          raise RollbackBombed.new(e, performance)
        end
      end
    end

    def method_missing(meth, *args, &block)
      perform meth, *args, &block
    end

    def respond_to_missing?(meth, include_private=false)
      true # *shrug* we try to perform just about anything
    end

    protected

    def initialize(*args, &block)
      @performances = []
      transaction! &block if block_given?
    end
  end
end
