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
      klass.class_eval do
        extend JSONAPI::Serializable::Resource::KeyFormat
        key_format ->(k) { k.to_s.capitalize }
        attribute :name
        attribute :address
        relationship :posts
        belongs_to :author
        has_many :comments
        has_one :review
      end
    end

    expected = {
      type: :foo,
      id: 'bar',
      attributes: { Name: nil, Address: nil },
      relationships: {
        Posts: {
          meta: { included: false }
        },
        Author: {
          meta: { included: false }
        },
        Comments: {
          meta: { included: false }
        },
        Review: {
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

  context 'when KeyFormat is prepended' do
    it 'outputs a deprecation warning' do
      expect { klass.prepend JSONAPI::Serializable::Resource::KeyFormat }
        .to output(/DERPRECATION WARNING/).to_stderr
    end
  end
end
