require 'spec_helper'

describe JSONAPI::Serializable::Resource, '.attribute' do
  let(:klass) do
    Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
    end
  end

  let(:object)   { User.new }
  let(:resource) { klass.new(object: object) }

  subject { resource.as_jsonapi[:attributes] }

  context 'when supplied a block value' do
    before do
      klass.class_eval do
        attribute(:name) { 'foo' }
      end
    end

    it { is_expected.to eq(name: 'foo') }
  end

  context 'when defining multiple attributes' do
    before do
      klass.class_eval do
        attribute(:name)    { 'foo' }
        attribute(:address) { 'bar' }
      end
    end

    it { is_expected.to eq(name: 'foo', address: 'bar') }
  end

  context 'when no block supplied' do
    before do
      klass.class_eval do
        attribute :name
      end
      object.name = 'foo'
    end

    it 'forwards to @object' do
      expect(subject).to eq(name: 'foo')
    end
  end
end
