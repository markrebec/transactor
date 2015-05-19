require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'transactor/version'
require 'transactor/errors'
require 'transactor/actor'
require 'transactor/performance'
require 'transactor/improv'
require 'transactor/transaction'

module Transactor
  def self.transaction(&block)
    Transactor::Transaction.new &block
  end
end
