require 'spec_helper'

RSpec.describe Transactor::Performance do
  subject { Transactor::Performance.new(TestActor) }

  describe '#initialize' do
    it 'accepts a class constant as an actor' do
      expect(Transactor::Performance.new(TestActor).actor).to be_an_instance_of(TestActor)
    end

    it 'accepts a symbol as an actor' do
      expect(Transactor::Performance.new(:test_actor).actor).to be_an_instance_of(TestActor)
    end

    it 'accepts a string as an actor' do
      expect(Transactor::Performance.new('test_actor').actor).to be_an_instance_of(TestActor)
    end

    it 'accepts an array as an actor' do
      expect(Transactor::Performance.new([:transactor, :actor]).actor).to be_an_instance_of(Transactor::Actor)
    end
  end

  describe '#perform' do
    it "calls the actor's perform method" do
      subject.perform
      expect(subject.actor.performed).to be_true
    end
  end

  describe '#rollback' do
    it "calls the actor's rollback method" do
      subject.perform
      subject.rollback
      expect(subject.actor.performed).to be_false
    end
  end

  describe '#to_s' do
    it 'stringifies the actor and state' do
      expect(subject.to_s).to eql("#{subject.actor.to_s} #{subject.state.to_s}")
    end
  end
end
