module Transactor
  class Actor
    attr_reader :props, :state

    STATES = [:cast, :performing, :performed, :bombed, :rolling_back, :rolled_back, :rollback_failed]

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
      @state = :performing
      perform &block
      @state = :performed
    rescue StandardError => e
      @state = :bombed
      raise e
    end

    def rollback!(&block)
      @state = :rolling_back
      rollback &block
      @state = :rolled_back
    rescue StandardError => e
      @state = :rollback_failed
      raise e
    end

    def perform(&block)
      raise PerformNotImplemented, "#{self.class.name}##{__method__} has not been implemented"
    end

    def rollback(&block)
      raise RollbackNotImplemented, "#{self.class.name}##{__method__} has not been implemented"
    end

    def to_s
      "#{self.class.name} #{state} #{props.to_h}"
    end

    STATES.each do |state|
      define_method "#{state}?" do
        @state == state
      end
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
      @state = :cast
    end
  end
end
