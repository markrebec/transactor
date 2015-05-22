module Transactor
  class DSL
    attr_reader :performances

    def perform(actor, *args, &block)
      performance = Performance.new(actor, *args)
      performances << performance
      performance.perform(&block)
      performance.result
    rescue => e
      raise PerformanceBombed.new(e, performance)
    end

    def improvise(*args, &block)
      performance = Improv.new(*args)
      performances << performance
      performance.perform(&block)
      performance
    rescue => e
      raise PerformanceBombed.new(e, performance)
    end

    def set_context!(*args)
      @context = args.extract_options!.symbolize_keys
    end

    def clear_context!
      @context = {}
    end

    def method_missing(meth, *args, &block)
      if meth.to_s.match(/=\Z/)
        key = meth.to_s.gsub(/=/,'').to_sym
        return (@context[key] = args.first) if @context.key?(key)
      else
        return @context[meth] if @context.key?(meth)
      end

      perform meth, *args, &block
    end

    protected

    def initialize(*args)
      @performances = []
      set_context! *args
    end
  end
end
