require 'spec_helper'

RSpec.describe Transactor::Improv do
  describe '#initialize' do
    it 'uses the default actor' do
      expect(subject.actor).to be_an_instance_of(Transactor::Actor)
    end
  end
end
