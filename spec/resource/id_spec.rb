require 'spec_helper'

describe JSONAPI::Serializable::Resource, '.id' do
  it 'accepts a block' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
      id { 'foo' }
    end
    resource = klass.new(object: User.new)

    expect(resource.jsonapi_id).to eq('foo')
  end

  it 'forwards to @object by default' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
    end
    user = User.new(id: 'foo')
    resource = klass.new(object: user)

    expect(resource.jsonapi_id).to eq('foo')
  end
end
