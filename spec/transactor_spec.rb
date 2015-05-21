require 'spec_helper'

RSpec.describe Transactor do
  describe '#transaction' do
    it 'returns a Transactor::Transaction' do
      expect(Transactor.transaction).to be_an_instance_of(Transactor::Transaction)
    end
  end

  context 'configuration' do
    describe 'rollback_failed_actors' do
      it 'defaults to false' do
        expect(Transactor.configuration.rollback_failed_actors).to be_false
      end
    end
  end
end
