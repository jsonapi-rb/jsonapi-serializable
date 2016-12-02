require 'spec_helper'

describe JSONAPI::Serializable::Resource, '.attributes' do
  it 'defines multiple attributes' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
      attributes :name, :address
    end
    user = User.new(name: 'foo', address: 'bar')
    resource = klass.new(object: user)
    actual = resource.as_jsonapi[:attributes]
    expected = {
      name: 'foo',
      address: 'bar'
    }

    expect(actual).to eq(expected)
  end
end
