require 'spec_helper'

describe JSONAPI::Serializable::Resource do
  klass = Class.new(JSONAPI::Serializable::Resource) do
    extend JSONAPI::Serializable::Resource::Caching

    type 'foo'
    id { 'bar' }
    attribute :name
    attribute :address do
      # NOTE(beauby): Dirty trick to ensure the block is eval'd only once.
      self.class.class_eval do
        raise if @called
        @called = true
      end
      @object.address + ", Ruby City"
    end
  end

  let(:object)   { User.new(id: 5, name: 'Lucas', address: '42 Ruby Lane') }
  let(:resource) { klass.new(object: object) }

  subject { resource.as_jsonapi }

  context 'attributes are cached' do
    let(:resource) do
      klass.new(object: object)
    end

    let(:expected) do
      {
        type: :foo,
        id: 'bar',
        attributes: { name: 'Lucas', address: '42 Ruby Lane, Ruby City' }
      }
    end

    # NOTE(beauby): Ran twice to ensure caching works.
    it { is_expected.to eq(expected) }
    it { is_expected.to eq(expected) }

    context 'when inheriting' do
      subclass = Class.new(klass) do
        attribute :address do
          self.class.class_eval do
            raise if @called
            @called = true
          end
          @object.address + ', Inheriting City'
        end
      end
      let(:resource) { subclass.new(object: object) }

      let(:expected) do
        {
          type: :foo,
          id: 'bar',
          attributes: {
            name: 'Lucas',
            address: '42 Ruby Lane, Inheriting City'
          }
        }
      end

      it { is_expected.to eq(expected) }
      it { is_expected.to eq(expected) }
    end
  end
end
