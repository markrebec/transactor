module Transactor
  class Stage
    attr_reader :performances, :props

    def perform(actor, *args, &block)
      args = performance_props(*args)
      performance = Performance.new(actor, *args)
      performances << performance
      performance.perform(&block)
      performance.result
    rescue => e
      raise PerformanceBombed.new(e, performance)
    end

    def improvise(*args, &block)
      block ||= Proc.new {}
      args = performance_props(*args)
      performance = Improv::Performance.new(Improv::Actor, *args)
      performances << performance
      performance.perform(&block)
      performance
    rescue PerformanceBombed => e
      raise e
    rescue => e
      raise PerformanceBombed.new(e, performance)
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

    def initialize(*args)
      @performances ||= []
      set_stage! *args
    end

    def performance_props(*args)
      props = @props.merge(args.extract_options!.symbolize_keys)
      args << props
      args
    end
  end
end
