require 'ostruct'

module Transactor
  class Props < OpenStruct
    def merge(hash)
      self.class.new to_h.merge(hash)
    end

    def merge!(hash)
      hash.each do |key, val|
        self[key] = value
      end
      self
    end
  end
end
