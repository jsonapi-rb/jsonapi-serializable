require 'spec_helper'

describe JSONAPI::Serializable::Resource, '.meta' do
  it 'accepts a hash' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
      meta foo: 'bar'
    end
    resource = klass.new(User.new)
    actual = resource.as_jsonapi[:meta]
    expected = {
      foo: 'bar'
    }

    expect(actual).to eq(expected)
  end

  it 'accepts a block' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
      meta do
        { foo: 'bar' }
      end
    end
    resource = klass.new(User.new)
    actual = resource.as_jsonapi[:meta]
    expected = {
      foo: 'bar'
    }

    expect(actual).to eq(expected)
  end
end
