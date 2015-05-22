require 'spec_helper'

RSpec.describe Transactor::Transaction do
  describe '#transaction!' do
    it 'returns self' do
      expect(subject.transaction!).to eql(subject)
    end

    it 'accepts a block' do
      expect(subject.transaction! { 5+5 }).to eql(subject)
    end

    it 'bubbles any raised exceptions' do
      expect do
        subject.transaction! do
          raise "Transaction Error"
        end
      end.to raise_exception(Transactor::TransactionFailed)
    end
  end

  describe '#transaction' do
    it 'returns self' do
      expect(subject.transaction).to eql(subject)
    end

    it 'accepts a block' do
      expect(subject.transaction { 5+5 }).to eql(subject)
    end

    it 'rescues any raised exceptions' do
      expect do
        subject.transaction do
          raise "Transaction Error"
        end
      end.to_not raise_exception
    end
  end

  describe '#result' do
    it 'returns the result of the block' do
      subject.transaction! { 5+5 }
      expect(subject.result).to eql(10)
    end
  end

  describe '#perform' do
    it 'adds a performance to the performances array' do
      subject.perform(TestActor)
      expect(subject.performances.length).to eql(1)
    end

    it 'casts the provided actor in the performance' do
      subject.perform(TestActor)
      expect(subject.performances.last.actor).to be_an_instance_of(TestActor)
    end

    it "triggers the actor's performance" do
      subject.perform(TestActor)
      expect(subject.performances.last.actor.performed).to be_true
    end

    it 'bubbles exceptions as PerformanceBombed errors' do
      expect { subject.perform(FailingActor) }.to raise_exception(Transactor::PerformanceBombed)
    end
  end

  describe '#improvise' do
    it 'returns an improv performance' do
      expect(subject.improvise).to be_an_instance_of(Transactor::Improv::Performance)
    end

    it 'adds a performance to the performances array' do
      subject.improvise
      expect(subject.performances.length).to eql(1)
    end

    it 'casts the default actor in the performance' do
      subject.improvise
      expect(subject.performances.last.actor).to be_an_instance_of(Transactor::Improv::Actor)
    end

    it 'executes the improv block' do
      subject.improvise { 5+5 }
      expect(subject.performances.last.result).to eql(10)
    end

    it 'bubbles exceptions as PerformanceBombed errors' do
      expect do
        subject.improvise do
          raise "Bombing"
        end
      end.to raise_exception(Transactor::PerformanceBombed)
    end
  end

  describe '#rollback' do
    context 'when there are no failed performances' do
      it 'rolls back all performances' do
        3.times { subject.perform(TestActor) }
        subject.performances.each do |performance|
          expect(performance.actor.performed).to be_true
        end
        subject.rollback
        subject.performances.each do |performance|
          expect(performance.actor.performed).to be_false
        end
      end
    end

    context 'when the last performance failed' do
      context 'and is configured to rollback on failure' do
        it 'rolls back all performances' do
          3.times { subject.perform(TestActor) }
          subject.performances.each do |performance|
            expect(performance.actor.performed).to be_true
          end
          
          TestActor.instance_variable_set :@rollback_on_failure, true
          subject.performances.last.instance_variable_set :@failed, true
          subject.rollback
          TestActor.instance_variable_set :@rollback_on_failure, false
          
          subject.performances.each do |performance|
            expect(performance.actor.performed).to be_false
          end
        end
      end

      context 'and is configured not to rollback on failure' do
        it 'rolls back all performances except the one that failed' do
          TestActor.instance_variable_set :@rollback_on_failure, false
          3.times { subject.perform(TestActor) }
          subject.performances.each do |performance|
            expect(performance.actor.performed).to be_true
          end
          subject.performances.last.instance_variable_set :@failed, true
          subject.rollback
          subject.performances.each do |performance|
            expect(performance.actor.performed).to be_false
          end
        end
      end
    end
  end

  describe '#method_missing' do
    it 'translates method calls to actor performances' do
      subject.transaction! do
        test_actor
      end
      expect(subject.performances.last.actor).to be_an_instance_of(TestActor)
    end
  end
end
