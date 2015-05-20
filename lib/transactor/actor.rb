module Transactor
  class Actor
    attr_reader :props

    def self.perform(*args, &block)
      new(*args).perform(&block)
    end

    def perform(&block)
      if block_given?
        instance_eval &block
      else
        raise PerformNotImplemented, "#{self.class.name}##{__method__} has not been implemented"
      end
    end

    def rollback(&block)
      if block_given?
        instance_eval &block
      else
        raise RollbackNotImplemented, "#{self.class.name}##{__method__} has not been implemented"
      end
    end

    def state
      props.to_h
    end

    def to_s
      "#{self.class.name} #{state.to_s}"
    end

    def method_missing(meth, *args, &block)
      if props.respond_to?(meth)
        props.send meth, *args, &block
      else
        super
      end
    end

    def respond_to_missing?(meth, include_private=false)
      props.respond_to?(meth, include_private)
    end

    protected

    def initialize(*args)
      @props = Props.new(args.extract_options!)
    end
  end
end
