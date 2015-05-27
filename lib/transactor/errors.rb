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

  class RollbacksBombed < StandardError
    attr_reader :performances

    def initialize(performances)
      super("Performance rollback failed!")
      @performances = performances
    end
  end

  class RollbackBombed < PerformanceBombed; end

  class TransactionError < StandardError
    attr_reader :transaction

    def initialize(e, transaction)
      super("#{e.class.name}: #{e.message}")
      set_backtrace e.backtrace
      @transaction = transaction
    end
  end

  class TransactionFailed < TransactionError; end

  class RollbackFailed < TransactionError
    def initialize(transaction)
      super("Transaction rollback failed!")
      @transaction = transaction
    end
  end
end
