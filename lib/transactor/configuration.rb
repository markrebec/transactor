require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/keys'

module Transactor
  class Configuration

    def configure(argh={}, &block)
      @options ||= {}
      save_state! do
        configure_with_args argh
        configure_with_block &block
      end
      self
    end

    def configure_with_args(argh)
      save_state! do
        argh.symbolize_keys.each { |key,val| configure_option(key, val) }
      end
    end

    def configure_with_block(&block)
      save_state! do
        instance_eval &block if block_given?
      end
    end

    def configure_option(key, val)
      raise ArgumentError, "#{key} is not an allowed configuration option" unless @allowed.include?(key)

      save_state! do
        @changed[key] = [@options[key], val]
        @options[key] = val
      end
    end

    def changed
      @changed = {}
      @options.each { |key,val| @changed[key] = [@saved_state[key], val] if @saved_state[key] != val }
      @changed
    end

    def changed?(key)
      changed.key?(key)
    end

    def save_state!(&block)
      if save_state?
        @saved_state = @options.dup
        @changed = {}

        if block_given?
          disable_state_saves!
          begin
            yield
          ensure
            enable_state_saves!
          end
        end
      else
        yield if block_given?
      end
    end

    def enable_state_saves!
      @save_state = true
    end

    def disable_state_saves!
      @save_state = false
    end

    def save_state?
      @save_state
    end

    def method_missing(meth, *args, &block)
      if meth.to_s.match(/=\Z/)
        opt = meth.to_s.gsub(/=/,'').to_sym
        return configure_option(opt, args.first) if @allowed.include?(opt)
      else
        return @options[meth] if @allowed.include?(meth)
      end

      super
    end

    protected

    def initialize(*args, &block)
      options = args.extract_options!
      @allowed = options.symbolize_keys.keys
      enable_state_saves!
      configure options, &block
    end
  end
end
