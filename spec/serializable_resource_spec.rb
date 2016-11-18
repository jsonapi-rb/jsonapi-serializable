require 'jsonapi/serializable'
require 'jsonapi/renderer'

class Model
  def initialize(params)
    params.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end
end

class User < Model
  attr_accessor :id, :name, :address, :posts
end

class Post < Model
  attr_accessor :id, :title, :date, :author
end

describe JSONAPI::Serializable::Resource, '#as_jsonapi' do
  before(:all) do
    @users = [
      User.new(id: 1, name: 'User 1', address: '123 Example st.', posts: []),
      User.new(id: 2, name: 'User 2', address: '123 Example st.', posts: [])
    ]
    @posts = [
      Post.new(id: 1, title: 'Post 1', date: 'yesterday', author: @users[1]),
      Post.new(id: 2, title: 'Post 2', date: 'today', author: @users[0]),
      Post.new(id: 3, title: 'Post 3', date: 'tomorrow', author: @users[1]),
      Post.new(id: 4, title: 'Post 4', date: 'tomorrow')
    ]
    @users[1].posts = [@posts[0], @posts[2]]
    @users[0].posts = [@posts[1]]
  end

  it 'handles type and id' do
    user_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
    end
    resource = user_klass.new(object: @users[0])
    actual = resource.as_jsonapi
    expected = {
      type: 'users',
      id: '1'
    }

    expect(actual).to eq(expected)
  end

  it 'handles attributes' do
    user_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      attribute :name
      attribute :address
    end
    resource = user_klass.new(object: @users[0])
    actual = resource.as_jsonapi
    expected = {
      type: 'users',
      id: '1',
      attributes: {
        name: 'User 1',
        address: '123 Example st.'
      }
    }

    expect(actual).to eq(expected)
  end

  it 'handles included has_one relationships' do
    user_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
    end
    post_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'posts'
      has_one :author, user_klass
    end
    resource = post_klass.new(object: @posts[0])
    actual = resource.as_jsonapi(include: [:author])
    expected = {
      type: 'posts',
      id: '1',
      relationships: {
        author: {
          data: { type: 'users', id: '2' }
        }
      }
    }

    expect(actual).to eq(expected)
  end

  it 'handles non-included has_one relationships' do
    user_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
    end
    post_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'posts'
      has_one :author, user_klass do
        link(:self) do
          "http://api.example.com/posts/#{@object.id}/relationships/author"
        end
      end
    end
    resource = post_klass.new(object: @posts[0])
    actual = resource.as_jsonapi
    expected = {
      type: 'posts',
      id: '1',
      relationships: {
        author: {
          links: {
            self: 'http://api.example.com/posts/1/relationships/author'
          }
        }
      }
    }

    expect(actual).to eq(expected)
  end

  it 'handles nil has_one relationships' do
    user_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
    end
    post_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'posts'
      has_one :author, user_klass
    end
    resource = post_klass.new(object: @posts[3])
    actual = resource.as_jsonapi
    expected = {
      type: 'posts',
      id: '4',
      relationships: {
        author: {
          data: nil
        }
      }
    }

    expect(actual).to eq(expected)
  end

  it 'falls back to linkage data for non-included has_one relationships' do
    user_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
    end
    post_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'posts'
      has_one :author, user_klass
    end
    resource = post_klass.new(object: @posts[0])
    actual = resource.as_jsonapi
    expected = {
      type: 'posts',
      id: '1',
      relationships: {
        author: {
          data: { type: 'users', id: '2' }
        }
      }
    }

    expect(actual).to eq(expected)
  end

  it 'is rendered properly' do
    user_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'

      attribute :name
    end
    post_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'posts'

      has_one :author, user_klass
    end

    resources = @posts.map { |p| post_klass.new(object: p) }

    actual = JSONAPI.render(data: resources, include: 'author')
    expected = {
      data: [
        {
          id: '1',
          type: 'posts',
          relationships: {
            author: {
              data: { id: '2', type: 'users' }
            }
          }
        },
        {
          id: '2',
          type: 'posts',
          relationships: {
            author: {
              data: { id: '1', type: 'users' }
            }
          }
        },
        {
          id: '3',
          type: 'posts',
          relationships: {
            author: {
              data: { id: '2', type: 'users' }
            }
          }
        },
        {
          id: '4',
          type: 'posts',
          relationships: {
            author: {
              data: nil
            }
          }
        }
      ],
      included: [
        {
          id: '1',
          type: 'users',
          attributes: {
            name: 'User 1'
          }
        },
        {
          id: '2',
          type: 'users',
          attributes: {
            name: 'User 2'
          }
        }
      ]
    }

    expect(actual).to eq(expected)
  end
end
