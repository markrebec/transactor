require 'spec_helper'

RSpec.describe Transactor::Actor do
  subject { Transactor::Actor.new(test_one: 'one', test_two: 2) }

  describe '#initialize' do
    it 'converts options hash to a set of props' do
      expect(subject.props).to respond_to(:test_one)
      expect(subject.props.test_one).to eql('one')
      expect(subject.props).to respond_to(:test_two)
      expect(subject.props.test_two).to eql(2)
    end

    it 'provides attribute readers for options hash keys' do
      expect(subject).to respond_to(:test_one)
      expect(subject).to respond_to(:test_two)
    end
  end

  describe '#perform' do
    context 'when passed a block' do
      it 'raises a PerformNotImplemented error' do
        expect { subject.perform }.to raise_exception(Transactor::PerformNotImplemented)
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
      it 'raises a PerformNotImplemented error' do
        expect { subject.rollback }.to raise_exception(Transactor::RollbackNotImplemented)
      end
    end

    context 'when not passed a block' do
      it 'raises a PerformNotImplemented error' do
        expect { subject.rollback }.to raise_exception(Transactor::RollbackNotImplemented)
      end
    end
  end

  describe '#props' do
    it 'converts props into an open struct' do
      expect(subject.props).to eql(OpenStruct.new({test_one: 'one', test_two: 2}))
    end
  end

  describe '#to_s' do
    it 'stringifies the class name, state and props' do
      expect(subject.to_s).to eql("#{subject.class.name} #{subject.state} #{subject.props.to_h}")
    end
  end

  describe '.rollback_on_failure!' do
    before(:each) { Transactor::Actor.configuration.rollback_on_failure = false }

    it 'sets the configuration option to true' do
      Transactor::Actor.rollback_on_failure!
      expect(Transactor::Actor.configuration.rollback_on_failure).to be_true
    end
  end

  describe '.rollback_on_failure?' do
    before(:each) { Transactor::Actor.configuration.rollback_on_failure = false }

    context 'when the actor is configured to rollback on failure' do
      it 'returns true'do
        Transactor::Actor.rollback_on_failure!
        expect(Transactor::Actor.rollback_on_failure?).to be_true
      end
    end

    context 'when the actor is configured not to rollback on failure' do
      it 'returns false' do
        Transactor::Actor.rollback_on_failure!
        expect(Transactor::Actor.rollback_on_failure?).to be_true
      end
    end
  end

  describe '#rollback_on_failure?' do
    before(:each) { Transactor::Actor.configuration.rollback_on_failure = false }

    context 'when the actor is configured to rollback on failure' do
      it 'returns true'do
        Transactor::Actor.rollback_on_failure!
        expect(Transactor::Actor.new.rollback_on_failure?).to be_true
      end
    end

    context 'when the actor is configured not to rollback on failure' do
      it 'returns false' do
        Transactor::Actor.rollback_on_failure!
        expect(Transactor::Actor.new.rollback_on_failure?).to be_true
      end
    end
  end
end
