require 'spec_helper'

RSpec.describe Transactor::Actor do
  subject { Transactor::Actor.new(test_one: 'one', test_two: 2) }

  describe '#initialize' do
    it 'converts options hash to instance variables' do
      expect(subject.instance_variables).to include(:@test_one)
      expect(subject.instance_variable_get :@test_one).to eql('one')
      expect(subject.instance_variables).to include(:@test_two)
      expect(subject.instance_variable_get :@test_two).to eql(2)
    end

    it 'provides attribute readers for options hash keys' do
      expect(subject).to respond_to(:test_one)
      expect(subject).to respond_to(:test_two)
    end
  end

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

  describe '#state' do
    it 'converts instance variables into a hash' do
      expect(subject.state).to eql({test_one: 'one', test_two: 2})
    end
  end

  describe '#to_s' do
    it 'stringifies the class name and state' do
      expect(subject.to_s).to eql("#{subject.class.name} #{subject.state.to_s}")
    end
  end
end
