module Transactor
  class Actor
    attr_reader :props

    class << self
      def configuration
        @configuration ||= Canfig::OpenConfig.new(rollback_on_failure: Transactor.configuration.rollback_failed_actors)
      end

      def perform(*args, &block)
        new(*args).perform(&block)
      end

      def rollback_on_failure!
        configuration.rollback_on_failure = true
      end

      def rollback_on_failure?
        configuration.rollback_on_failure
      end
    end

    def configuration
      @configuration ||= self.class.configuration.dup
    end

    def rollback_on_failure!
      configuration.rollback_on_failure = true
    end

    def rollback_on_failure?
      configuration.rollback_on_failure
    end

    def perform!(&block)
      perform &block
    end

    def rollback!(&block)
      rollback &block
    end

    def perform(&block)
      raise PerformNotImplemented, "#{self.class.name}##{__method__} has not been implemented"
    end

    def rollback(&block)
      raise RollbackNotImplemented, "#{self.class.name}##{__method__} has not been implemented"
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
