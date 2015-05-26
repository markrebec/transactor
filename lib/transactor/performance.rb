module Transactor
  class Performance
    attr_reader :actor, :result

    def self.perform(actor, *args, &block)
      new(actor, *args).perform(&block)
    end

    def perform(&block)
      @result = actor.perform(&block)
      self
    end

    def rollback(&block)
      actor.rollback(&block)
      self
    end

    def state
      actor.state
    end

    def to_s
      actor.to_s
    end

    def error
      actor.error
    end

    def rollback_error
      actor.rollback_error
    end

    Actor::STATES.each do |state|
      define_method "#{state}?" do
        actor.send "#{state}?"
      end
    end

    protected

    def initialize(actor, *args)
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
