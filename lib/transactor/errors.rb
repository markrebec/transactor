module Transactor
  class ActorInvalid < ArgumentError; end
  class PerformNotImplemented < NotImplementedError; end
  class RollbackNotImplemented < NotImplementedError; end

  class PerformanceBombed < StandardError
    attr_reader :performance

    def initialize(e, performance=nil)
      super("#{e.class.name}: #{e.message} #{performance.to_s}")
      set_backtrace e.backtrace
      @performance = performance
    end
  end

  class RollbackBombed < StandardError
    attr_reader :performance

    def initialize(e, performance=nil)
      super("#{e.class.name}: #{e.message} #{performance.to_s}")
      set_backtrace e.backtrace
      @performance = performance
    end
  end

  class TransactionFailed < StandardError
    attr_reader :transaction

    def initialize(e, transaction)
      super("#{e.class.name}: #{e.message}")
      set_backtrace e.backtrace
      @transaction = transaction
    end
  end

  class RollbackFailed < StandardError
    attr_reader :transaction

    def initialize(e, transaction)
      super("Transactor rollback failed! #{e.class.name}: #{e.message}")
      set_backtrace e.backtrace
      @transaction = transaction
    end
  end
end
