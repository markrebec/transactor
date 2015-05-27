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

  describe '#rollback' do
    context 'when there are no failed performances' do
      it 'rolls back all performances' do
        3.times { subject.stage.perform(TestActor) }
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
          3.times { subject.stage.perform(TestActor) }
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
          3.times { subject.stage.perform(TestActor) }
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

  describe '#performances' do
    it 'returns the stage performances' do
      3.times { subject.stage.perform(TestActor) }
      expect(subject.performances).to eql(subject.stage.performances)
    end
  end

  describe '#bombed' do
    it 'returns an array of bombed or rolled back performances' do
      5.times { subject.stage.perform(TestActor) }
      subject.performances[0].rollback!
      subject.performances[2].instance_variable_set :@state, :bombed
      expect(subject.bombed).to eql([subject.performances[0], subject.performances[2]])
    end
  end

  describe '#rolled_back' do
    it 'returns an array of rolled back performances' do
      5.times { subject.stage.perform(TestActor) }
      subject.performances[0].rollback!
      subject.performances[2].rollback!
      expect(subject.rolled_back).to eql([subject.performances[0], subject.performances[2]])
    end
  end

  describe '#bombed_rollbacks' do
    it 'returns an array of bombed rollbacks' do
      5.times { subject.stage.perform(BlockActor) }
      begin
      subject.performances[0].rollback! { raise 'fail' }
      rescue; end
      begin
      subject.performances[2].rollback! { raise 'fail' }
      rescue; end
      expect(subject.bombed_rollbacks).to eql([subject.performances[0], subject.performances[2]])
    end
  end

end
