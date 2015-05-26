module Transactor
  class Transaction
    attr_reader :performances, :result

    def in_transaction(*args, &block)
      begin
        @result = instance_eval &block if block_given?
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
        ActiveRecord::Base.transaction { in_transaction *args, &block }
      else
        in_transaction *args, &block
      end
      self
    end

    def transaction(*args, &block)
      transaction!(*args, &block)
    rescue => e
      false
    end

    def perform(actor, *args, &block)
      args = performance_args(*args)
      performance = Performance.new(actor, *args)
      performances << performance
      performance.perform(&block)
      performance.result
    rescue => e
      raise PerformanceBombed.new(e, performance)
    end

    def improvise(*args, &block)
      block ||= Proc.new {}
      args = performance_args(*args)
      performance = Improv::Performance.new(Improv::Actor, *args)
      performances << performance
      performance.perform(&block)
      performance
    rescue PerformanceBombed => e
      raise e
    rescue => e
      raise PerformanceBombed.new(e, performance)
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
          raise RollbackBombed.new(e, performance) if Transactor.configuration.stop_rollback_on_failure
        end
      end
    end

    def bombed_performances
      performances.select { |performance| performance.bombed? || performance.rolled_back? }
    end

    def bombed_rollbacks
      performances.select { |performance| performance.rollback_bombed? }
    end

    def set_stage!(*args)
      @props = Props.new(args.extract_options!.symbolize_keys)
    end

    def clear_stage!
      @props = Props.new
    end

    def method_missing(meth, *args, &block)
      if @props.respond_to?(meth)
        @props.send meth, *args, &block
      else
        perform meth, *args, &block
      end
    end

    protected

    def initialize(*args, &block)
      @performances = []
      set_stage! *args
      transaction! &block if block_given?
    end

    def performance_args(*args)
      props = @props.merge(args.extract_options!.symbolize_keys)
      args << props
      args
    end

    def last_performance
      performances.last
    end

    def rollback_last_performance?
      # only rollback the last performance if it didn't bomb OR if
      # it did and is configured to rollback on failure
      !last_performance.bombed? || (last_performance.bombed? && last_performance.rollback_on_failure?)
    end
  end
end
