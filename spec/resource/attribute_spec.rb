require 'spec_helper'

describe JSONAPI::Serializable::Resource, '.attribute' do
  let(:object)   { User.new(name: 'foo') }
  let(:resource) { klass.new(object) }

  subject { resource.as_jsonapi[:attributes] }

  context 'when supplied a block value' do
    let(:klass) do
      Class.new(JSONAPI::Serializable::Resource) do
        type 'foo'
        attribute(:name) { 'foo' }
      end
    end

    it { is_expected.to eq(name: 'foo') }
  end

  context 'when defining multiple attributes' do
    let(:klass) do
      Class.new(JSONAPI::Serializable::Resource) do
        type 'foo'
        attribute(:name)    { 'foo' }
        attribute(:address) { 'bar' }
      end
    end

    it { is_expected.to eq(name: 'foo', address: 'bar') }
  end

  context 'when redefining attributes' do
    let(:klass) do
      Class.new(JSONAPI::Serializable::Resource) do
        type 'foo'
        attribute(:name) { 'foo' }
        attribute(:name) { 'bar' }
      end
    end

    it { is_expected.to eq(name: 'bar') }
  end

  context 'when no block supplied' do
    let(:klass) do
      Class.new(JSONAPI::Serializable::Resource) do
        type 'foo'
        attribute :name
      end
    end

    it { is_expected.to eq(name: 'foo') }
  end

  context 'when inheriting' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
      attribute :name
    end

    subclass = Class.new(klass) do
      attribute(:name) { 'bar' }
    end

    it 'overrides superclass definition' do
      expect(subclass.new(object).as_jsonapi[:attributes])
        .to eq(name: 'bar')
    end

    it 'does not modify superclass definition' do
      expect(klass.new(object).as_jsonapi[:attributes])
        .to eq(name: 'foo')
    end
  end
end
