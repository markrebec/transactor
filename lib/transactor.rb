require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/string/output_safety'
require 'canfig'
require 'transactor/version'
require 'transactor/configuration'
require 'transactor/errors'
require 'transactor/props'
require 'transactor/actor'
require 'transactor/performance'
require 'transactor/improv'
require 'transactor/transaction'

module Transactor
  mattr_reader :configuration
  @@configuration = Transactor::Configuration.new

  def self.configure(&block)
    @@configuration.configure &block
  end

  def self.transaction(&block)
    Transactor::Transaction.new &block
  end
end
