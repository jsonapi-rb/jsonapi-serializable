require 'spec_helper'

describe JSONAPI::Serializable::ResourceDSL, '.attribute' do
  it 'defines an attribute' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
      attribute :name do
        'foo'
      end
    end
    resource = klass.new(object: User.new)
    actual = resource.as_jsonapi[:attributes]
    expected = {
      name: 'foo'
    }

    expect(actual).to eq(expected)
  end

  it 'defines multiple attributes' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
      attribute :name do
        'bar'
      end
      attribute :address do
        'foo'
      end
    end
    resource = klass.new(object: User.new)
    actual = resource.as_jsonapi[:attributes]
    expected = {
      name: 'bar',
      address: 'foo'
    }

    expect(actual).to eq(expected)
  end

  it 'forwards to @object by default' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
      attribute :name
    end
    user = User.new(name: 'foo')
    resource = klass.new(object: user)
    actual = resource.as_jsonapi[:attributes]
    expected = {
      name: 'foo'
    }

    expect(actual).to eq(expected)
  end

  it 'handles conditional attributes' do
    require 'jsonapi/serializable/conditional_fields'

    klass = Class.new(JSONAPI::Serializable::Resource) do
      prepend JSONAPI::Serializable::ConditionalFields
      type 'foo'
      attribute :name, if: -> { true } do
        'bar'
      end
      attribute :address, if: -> { false } do
        'foo'
      end
    end
    resource = klass.new(object: User.new)
    actual = resource.as_jsonapi[:attributes]
    expected = {
      name: 'bar'
    }

    expect(actual).to eq(expected)
  end
end
