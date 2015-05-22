module Transactor
  class Performance
    attr_reader :actor, :result

    def self.perform(actor, *args, &block)
      new(actor, *args).perform(&block)
    end

    def perform(&block)
      @started = true
      if block_given? || @block.nil?
        @result = actor.perform(&block)
      else
        @result = actor.perform(&@block)
      end
      @performed = true
      self
    end

    def rollback(&block)
      actor.rollback(&block)
      @rolled_back = true
      self
    end

    def started?
      !!@started
    end

    def performed?
      !!@performed
    end

    def rolled_back?
      !!@rolled_back
    end

    def performing?
      started? && !performed?
    end

    def successful?
      performed? && !rolled_back?
    end

    def failed?
      started? && rolled_back?
    end

    def rollback_on_failure?
      actor.rollback_on_failure?
    end

    def state
      if failed?
        :failed
      elsif successful?
        :successful
      elsif performing?
        :performing
      elsif !started?
        :not_started
      else
        :unknown
      end
    end

    def to_s
      "#{actor.to_s} #{state}"
    end

    protected

    def initialize(actor, *args, &block)
      @block = block if block_given?
      actor = begin
        if actor.is_a?(Array)
          actor.map { |a| a.to_s.camelize }.join('::').constantize
        elsif actor.is_a?(Symbol) || actor.is_a?(String)
          actor.to_s.camelize.constantize
        elsif actor.is_a?(Class) && actor <= Transactor::Actor
          actor
        else
          raise ArgumentError, "An actor must be provided as a symbol, string, array or class (inherited from Transactor::Actor)"
        end
      end
      @actor = actor.new(*args)
    end
  end
end
