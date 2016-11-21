require 'spec_helper'

describe JSONAPI::Serializable::Resource, '#as_jsonapi' do
  let(:posts) { [Post.new(id: 1), Post.new(id: 2)] }
  let(:user) do
    User.new(id: 'foo', name: 'Lucas', address: '22 Ruby drive', posts: posts)
  end

  it 'includes all fields by default' do
    resource = SerializableUser.new(object: user)
    actual = resource.as_jsonapi
    expected = {
      type: :users,
      id: 'foo',
      attributes: {
        name: 'Lucas',
        address: '22 Ruby drive'
      },
      relationships: {
        posts: {
          data: [{ id: '1', type: :posts }, { id: '2', type: :posts }]
        }
      }
    }

    expect(actual).to eq(expected)
  end

  it 'omits attributes member if none rendered' do
    resource = SerializableUser.new(object: user)
    actual = resource.as_jsonapi(fields: [:posts])
    expected = {
      type: :users,
      id: 'foo',
      relationships: {
        posts: {
          data: [{ id: '1', type: :posts }, { id: '2', type: :posts }]
        }
      }
    }

    expect(actual).to eq(expected)
  end

  it 'omits relationships member if none rendered' do
    resource = SerializableUser.new(object: user)
    actual = resource.as_jsonapi(fields: [:name, :address])
    expected = {
      type: :users,
      id: 'foo',
      attributes: {
        name: 'Lucas',
        address: '22 Ruby drive'
      }
    }

    expect(actual).to eq(expected)
  end

  it 'filters out fields' do
    resource = SerializableUser.new(object: user)
    actual = resource.as_jsonapi(fields: [:name])
    expected = {
      type: :users,
      id: 'foo',
      attributes: {
        name: 'Lucas'
      }
    }

    expect(actual).to eq(expected)
  end

  it 'omits linkage data for non-included relationships' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      attribute :name
      relationship :posts do
        link :self do
          "http://api.example.com/users/#{@object.id}/relationships/posts"
        end
      end
    end

    resource = klass.new(object: user)
    actual = resource.as_jsonapi
    expected = {
      type: :users,
      id: 'foo',
      attributes: { name: 'Lucas' },
      relationships: {
        posts: {
          links: {
            self: 'http://api.example.com/users/foo/relationships/posts'
          }
        }
      }
    }

    expect(actual).to eq(expected)
  end

  it 'sets linkage data for included relationships' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      attribute :name
      relationship :posts do
        link :self do
          "http://api.example.com/users/#{@object.id}/relationships/posts"
        end
      end
    end

    resource = klass.new(object: user)
    actual = resource.as_jsonapi(include: [:posts])
    expected = {
      type: :users,
      id: 'foo',
      attributes: { name: 'Lucas' },
      relationships: {
        posts: {
          links: {
            self: 'http://api.example.com/users/foo/relationships/posts'
          },
          data: [{ id: '1', type: :posts }, { id: '2', type: :posts }]
        }
      }
    }

    expect(actual).to eq(expected)
  end

  it 'handles empty to-one relationships' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts do
        data { nil }
      end
    end
    resource = klass.new(object: user)
    actual = resource.as_jsonapi(include: [:posts], fields: [:posts])
    expected = {
      type: :users,
      id: 'foo',
      relationships: {
        posts: {
          data: nil
        }
      }
    }

    expect(actual).to eq(expected)
  end
end
