require 'spec_helper'

RSpec.describe Transactor::Improv::Performance do
  subject { Transactor::Improv::Performance.new(Transactor::Improv::Actor, test_one: 'one', test_two: 2) }

  describe '#perform' do
    it 'returns self' do
      expect(subject.perform).to eql(subject)
    end

    context 'when passed a block' do
      it 'stores the block to be called later' do
        dummy_proc = Proc.new { nil }
        subject.perform &dummy_proc
        expect(subject.perform_block).to eql(dummy_proc)
      end
    end

    context 'when not passed a block' do
      context 'when a block was stored previously' do
        it 'executes the stored block' do
          subject.perform { @dummy_proc_executed = true }
          subject.perform
          expect(subject.actor.instance_variable_get(:@dummy_proc_executed)).to be_true
        end
      end

      context 'when no block was stored previously' do
        it 'executes a noop proc' do
          expect { subject.perform }.to_not raise_exception
        end
      end
    end
  end

  describe '#rollback' do
    it 'returns self' do
      expect(subject.rollback).to eql(subject)
    end

    context 'when passed a block' do
      it 'stores the block to be called later' do
        dummy_proc = Proc.new { nil }
        subject.rollback &dummy_proc
        expect(subject.rollback_block).to eql(dummy_proc)
      end
    end

    context 'when not passed a block' do
      context 'when a block was stored previously' do
        it 'executes the stored block' do
          subject.rollback { @dummy_proc_executed = true }
          subject.rollback
          expect(subject.actor.instance_variable_get(:@dummy_proc_executed)).to be_true
        end
      end

      context 'when no block was stored previously' do
        it 'executes a noop proc' do
          expect { subject.rollback }.to_not raise_exception
        end
      end
    end
  end
end
