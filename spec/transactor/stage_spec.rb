require 'spec_helper'

RSpec.describe Transactor::Stage do
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
      subject.improvise { 5+5 }.perform
      expect(subject.performances.last.result).to eql(10)
    end

    it 'bubbles exceptions as PerformanceBombed errors' do
      expect do
        subject.improvise do
          raise "Bombing"
        end.rollback do
          puts "Rolling Back"
        end.perform
      end.to raise_exception(Transactor::PerformanceBombed)
    end
  end

  describe '#method_missing' do
    it 'translates method calls to actor performances' do
      subject.instance_eval do
        test_actor
      end
      expect(subject.performances.last.actor).to be_an_instance_of(TestActor)
    end
  end
end
