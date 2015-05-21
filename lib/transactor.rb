require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/string/output_safety'
require 'canfig'
require 'transactor/version'
require 'transactor/errors'
require 'transactor/props'
require 'transactor/actor'
require 'transactor/performance'
require 'transactor/improv'
require 'transactor/transaction'

module Transactor
  include Canfig::Module

  def self.transaction(&block)
    Transactor::Transaction.new &block
  end
end
