module Transactor
  class Stage
    attr_reader :transaction, :props

    def perform(actor, *args, &block)
      transaction.perform actor, *args, &block
    end

    def improvise(*args, &block)
      transaction.improvise *args, &block
    end

    def method_missing(meth, *args, &block)
      if @props.respond_to?(meth)
        @props.send meth, *args, &block
      else
        perform meth, *args, &block
      end
    end

    def set_stage!(*args)
      @props = Props.new(args.extract_options!.symbolize_keys)
    end

    def clear_stage!
      @props = Props.new
    end

    protected

    def initialize(transaction, *args)
      @transaction = transaction
      set_stage! *args
    end
  end
end
