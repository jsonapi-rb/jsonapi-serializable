require 'spec_helper'

describe JSONAPI::Serializable::Resource, '.link' do
  it 'defines links' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      link :self do
        "http://api.example.com/users/#{@object.id}"
      end
      link :v2 do
        href "http://api.example.com/v2/users/#{@object.id}"
        meta available: false
      end
    end
    user = User.new(id: 'foo')
    resource = klass.new(object: user)
    actual = resource.as_jsonapi[:links]
    expected = {
      self: 'http://api.example.com/users/foo',
      v2: {
        href: 'http://api.example.com/v2/users/foo',
        meta: { available: false }
      }
    }

    expect(actual).to eq(expected)
  end
end
