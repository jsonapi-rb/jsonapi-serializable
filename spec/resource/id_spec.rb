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

  it 'accepts a boolean' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
      id false
    end

    resource = klass.new(object: User.new)

    expect(resource.as_jsonapi[:id]).to be_nil
  end

  it 'accepts new id name' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
      id name: 'uuid'
    end

    user = User.new(uuid: 'foo')
    resource = klass.new(object: user)

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
