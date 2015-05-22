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

  describe '#state' do
    it 'converts props into a hash' do
      expect(subject.state).to eql({test_one: 'one', test_two: 2})
    end
  end

  describe '#to_s' do
    it 'stringifies the class name and state' do
      expect(subject.to_s).to eql("#{subject.class.name} #{subject.state.to_s}")
    end
  end

  describe '.rollback_on_failure!' do
    before(:each) { Transactor::Actor.remove_instance_variable :@rollback_on_failure rescue nil }

    it 'sets the class instance variable to true' do
      Transactor::Actor.rollback_on_failure!
      expect(Transactor::Actor.instance_variable_get(:@rollback_on_failure)).to be_true
    end
  end

  describe '.rollback_on_failure?' do
    before(:each) { Transactor::Actor.remove_instance_variable :@rollback_on_failure rescue nil }

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

    context 'when the actor is not configured' do
      context 'when Transactor is configured to rollback failed actors' do
        it 'returns true' do
          Transactor.configure { |config| config.rollback_failed_actors = true }
          expect(Transactor::Actor.rollback_on_failure?).to be_true
        end
      end

      context 'when Transactor is configured not to rollback failed actors' do
        it 'returns false' do
          Transactor.configure { |config| config.rollback_failed_actors = false }
          expect(Transactor::Actor.rollback_on_failure?).to be_false
        end
      end
    end
  end

  describe '#rollback_on_failure?' do
    before(:each) { Transactor::Actor.remove_instance_variable :@rollback_on_failure rescue nil }

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

    context 'when the actor is not configured' do
      context 'when Transactor is configured to rollback failed actors' do
        it 'returns true' do
          Transactor.configure { |config| config.rollback_failed_actors = true }
          expect(Transactor::Actor.new.rollback_on_failure?).to be_true
        end
      end

      context 'when Transactor is configured not to rollback failed actors' do
        it 'returns false' do
          Transactor.configure { |config| config.rollback_failed_actors = false }
          expect(Transactor::Actor.new.rollback_on_failure?).to be_false
        end
      end
    end
  end
end
