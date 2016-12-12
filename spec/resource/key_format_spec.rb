require 'spec_helper'

describe JSONAPI::Serializable::Resource do
  let(:klass) do
    Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
      id { 'bar' }
    end
  end

  let(:object)   { User.new }
  let(:resource) { klass.new(object: object) }

  subject { resource.as_jsonapi }

  context 'when keys are formatted' do
    let(:resource) do
      klass.new(object: object)
    end

    before do
      require 'jsonapi/serializable/resource/key_format'

      klass.class_eval do
        prepend JSONAPI::Serializable::Resource::KeyFormat
        self.key_format = proc { |k| k.to_s.capitalize }
        attribute :name
        attribute :address
        relationship :posts
      end
    end

    expected = {
      type: :foo,
      id: 'bar',
      attributes: { Name: nil, Address: nil },
      relationships: {
        Posts: {
          meta: { included: false }
        }
      }

    }
    it { is_expected.to eq(expected) }

    context 'when inheriting' do
      let(:subclass) { Class.new(klass) }
      let(:resource) { subclass.new(object: object) }

      it { is_expected.to eq(expected) }
    end
  end
end
