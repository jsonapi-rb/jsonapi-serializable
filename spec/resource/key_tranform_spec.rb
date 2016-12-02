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

  context 'when keys are transformed' do
    let(:resource) do
      klass.new(object: object)
    end

    before do
      require 'jsonapi/serializable/resource/key_transform'

      klass.class_eval do
        prepend JSONAPI::Serializable::Resource::KeyTransform
        self.key_transform = proc { |k| k.to_s.capitalize }
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
  end
end
