module Transactor
  class Transaction
    attr_reader :result

    def dsl
      @dsl ||= DSL.new
    end

    def in_transaction(*args, &block)
      begin
        dsl.set_context! *args
        @result = dsl.instance_eval &block if block_given?
      rescue Exception => e # yes, we want to catch everything
        begin
          rollback
        rescue Exception => e # yes, here too
          raise RollbackFailed.new(e, self)
        end

        raise TransactionFailed.new(e, self)
      end
    end

    def transaction!(*args, &block)
      if defined?(ActiveRecord::Base) && ActiveRecord::Base.respond_to?(:transaction)
        ActiveRecord::Base.transaction { in_transaction &block }
      else
        in_transaction &block
      end
      self
    end

    def transaction(*args, &block)
      transaction!(&block)
    rescue => e
      false
    end

    def performances
      dsl.performances
    end

    def perform(actor, *args, &block)
      dsl.perform(actor, *args, &block)
    end

    def improvise(*args, &block)
      dsl.improvise(*args, &block)
    end

    def rollback
      return true if performances.empty?

      if rollback_last_performance?
        rollback_performances
      else
        bombed = performances.pop
        rollback_performances
        performances << bombed
      end
      
      true
    end

    def rollback_performances
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

    def last_performance
      performances.last
    end

    def rollback_last_performance?
      # only rollback the last performance if it didn't bomb OR if
      # it did and is configured to rollback on failure
      !last_performance.failed? || (last_performance.failed? && last_performance.rollback_on_failure?)
    end

    def method_missing(meth, *args, &block)
      dsl.perform meth, *args, &block
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
