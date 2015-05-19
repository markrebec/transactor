module Transactor
  class Actor
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
      instance_variables.each { |var| [var, instance_variable_get(var)] }.to_h
    end

    def to_s
      "#{self.class.name} #{state.to_s}"
    end

    protected

    def initialize(*args)
      args.extract_options!.each do |key,val|
        instance_variable_set "@#{key}".to_sym, val
      end
    end
  end
end
