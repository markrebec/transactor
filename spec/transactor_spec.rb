require 'spec_helper'

RSpec.describe Transactor do
  describe '#transaction' do
    it 'returns a Transactor::Transaction' do
      expect(Transactor.transaction).to be_an_instance_of(Transactor::Transaction)
    end
  end

  describe '#improvise' do
    it 'returns a Transactor::Improv::Transaction' do
      expect(Transactor.improvise).to be_an_instance_of(Transactor::Improv::Transaction)
    end
  end
end
