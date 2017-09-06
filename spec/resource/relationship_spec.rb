require 'spec_helper'

describe JSONAPI::Serializable::Resource, '.relationship' do
  let(:posts) { [Post.new(id: 1), Post.new(id: 2)] }
  let(:user) { User.new(id: 'foo', posts: posts) }

  it 'forwards to @object by default' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts
    end

    resource = klass.new(object: user, _class: { Post: SerializablePost })
    actual = resource.as_jsonapi(include: [:posts])[:relationships][:posts]
    expected = {
      data: [{ type: :posts, id: '1' },
             { type: :posts, id: '2' }]
    }

    expect(actual).to eq(expected)
  end

  it 'supports overriding related resources with objects' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts do
        data { @object.posts.reverse }
      end
    end

    resource = klass.new(object: user, _class: { Post: SerializablePost })
    actual = resource.as_jsonapi(include: [:posts])[:relationships][:posts]
    expected = {
      data: [{ type: :posts, id: '2' },
             { type: :posts, id: '1' }]
    }

    expect(actual).to eq(expected)
  end

  it 'supports meta' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts do
        meta foo: 'bar'
      end
    end

    resource = klass.new(object: user, _class: { Post: SerializablePost })
    actual = resource.as_jsonapi(include: [:posts])[:relationships][:posts]
    expected = {
      data: [{ type: :posts, id: '1' },
             { type: :posts, id: '2' }],
      meta: { foo: 'bar' }
    }

    expect(actual).to eq(expected)
  end

  it 'supports links' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts do
        link :self do
          "http://api.example.com/users/#{@object.id}/relationships/posts"
        end
        link :related do
          href "http://api.example.com/users/#{@object.id}/posts"
          meta count: @object.posts.count
        end
      end
    end

    resource = klass.new(object: user, _class: { Post: SerializablePost })
    actual = resource.as_jsonapi(include: [:posts])[:relationships][:posts]
    expected = {
      data: [{ type: :posts, id: '1' },
             { type: :posts, id: '2' }],
      links: {
        self: 'http://api.example.com/users/foo/relationships/posts',
        related: {
          href: 'http://api.example.com/users/foo/posts',
          meta: { count: 2 }
        }
      }
    }

    expect(actual).to eq(expected)
  end

  it 'supports overriding linkage data' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts do
        linkage do
          @object.posts.map do |post|
            { id: (post.id + 1).to_s, type: 'blogs', meta: { foo: 'bar' } }
          end
        end
      end
    end

    resource = klass.new(object: user, _class: { Post: SerializablePost })
    actual = resource.as_jsonapi(include: [:posts])[:relationships][:posts]
    expected = {
      data: [{ type: 'blogs', id: '2', meta: { foo: 'bar' } },
             { type: 'blogs', id: '3', meta: { foo: 'bar' } }]
    }

    expect(actual).to eq(expected)
  end
end
