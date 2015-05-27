module Transactor
  class Performance
    attr_reader :actor, :result, :state, :error, :rollback_error

    STATES = [:cast, :performing, :performed, :bombed, :rolling_back, :rolled_back, :rollback_bombed]

    def self.perform(actor, *args, &block)
      new(actor, *args).perform(&block)
    end

    def perform(&block)
      @result = actor.perform(&block)
    end

    def rollback(&block)
      actor.rollback(&block)
    end

    def perform!(&block)
      @state = :performing
      perform(&block)
      @state = :performed
      self
    rescue StandardError => e
      @state = :bombed
      @error = e
      raise e
    end

    def rollback!(&block)
      @state = :rolling_back
      rollback(&block)
      @state = :rolled_back
      self
    rescue StandardError => e
      @state = :rollback_bombed
      @rollback_error = e
      raise e
    end

    def to_s
      "#{actor.to_s} #{state}"
    end

    STATES.each do |state|
      define_method "#{state}?" do
        @state == state
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
      @state = :cast
    end
  end
end
