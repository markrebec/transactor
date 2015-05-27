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
require 'transactor/stage'
require 'transactor/transaction'

module Transactor
  include Canfig::Module

  configure do |config|
    config.rollback_failed_actors = false
    config.stop_rollback_on_failure = true
  end

  def self.transaction(*args, &block)
    Transactor::Transaction.new *args, &block
  end

  def self.improvise(*args, &block)
    Transactor::Improv::Transaction.new *args, &block
  end
end
