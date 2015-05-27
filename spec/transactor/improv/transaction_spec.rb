require 'spec_helper'

RSpec.describe Transactor::Improv::Transaction do
  describe '#initialize' do
    it 'sets up a transaction' do
      expect(subject.instance_variable_get(:@transaction)).to be_an_instance_of(Transactor::Transaction)
    end

    it 'sets up an improv performance' do
      expect(subject.performance).to be_an_instance_of(Transactor::Improv::Performance)
    end
  end

  describe '#actor' do
    it 'is an improv actor' do
      expect(subject.actor).to be_an_instance_of(Transactor::Improv::Actor)
    end

    it 'references the performance actor' do
      expect(subject.actor).to eql(subject.performance.actor)
    end
  end

  describe '#result' do
    it 'references the performance result' do
      expect(subject.result).to eql(subject.performance.result)
    end
  end

  describe '#perform' do
    subject { Transactor::Improv::Transaction.new { @performed_improv = true } }

    it 'executes the performance' do
      subject.perform
      expect(subject.actor.instance_variable_get(:@performed_improv)).to be_true
    end

    it 'returns the transaction object' do
      expect(subject.perform).to eql(subject.instance_variable_get(:@transaction))
    end
  end

  describe '#rollback' do
    subject { Transactor::Improv::Transaction.new { @performed_improv = true }.rollback { @performed_improv = false } }

    it 'returns self' do
      expect(subject.rollback).to eql(subject)
    end

    it 'rolls back the performance' do
      subject.rollback
      expect(subject.actor.instance_variable_get(:@performed_improv)).to be_false
    end
  end
end
