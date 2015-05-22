require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/string/output_safety'
require 'canfig'
require 'transactor/version'
require 'transactor/errors'
require 'transactor/props'
require 'transactor/actor'
require 'transactor/performance'
require 'transactor/improv'
require 'transactor/dsl'
require 'transactor/transaction'

module Transactor
  include Canfig::Module

  configure do |config|
    config.rollback_failed_actors = false
  end

  def self.transaction(*args, &block)
    Transactor::Transaction.new *args, &block
  end

  def self.improvise(*args, &block)
    # TODO revisit this after the transaction DSL is all set
    #t = Transactor::Transaction.new
    #improv = t.improvise(*args, &block)
    # OR
    #improv = Improv.new(*args, &block)
    #improv.actor.rollback_on_failure!
    #improv
  end
end
