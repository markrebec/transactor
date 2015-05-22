require 'spec_helper'

RSpec.describe Transactor::Improv::Actor do
  subject { Transactor::Improv::Actor.new(test_one: 'one', test_two: 2) }

  describe '#perform' do
    context 'when passed a block' do
      it 'executes the block and returns the value' do
        expect(subject.perform { 5+5 }).to eql(10)
      end
    end

    context 'when not passed a block' do
      it 'raises a PerformNotImplemented error' do
        expect { subject.perform }.to raise_exception(Transactor::PerformNotImplemented)
      end
    end
  end

  describe '#rollback' do
    context 'when passed a block' do
      it 'executes the block and returns the value' do
        expect(subject.rollback { 5+5 }).to eql(10)
      end
    end

    context 'when not passed a block' do
      it 'raises a PerformNotImplemented error' do
        expect { subject.rollback }.to raise_exception(Transactor::RollbackNotImplemented)
      end
    end
  end
end
