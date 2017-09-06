require 'spec_helper'

describe JSONAPI::Serializable::Resource do
  let(:posts) { [Post.new(id: 1), Post.new(id: 2)] }
  let(:user) { User.new(id: 'foo', posts: posts) }

  it 'exposes exposures in .id' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      id { @foo }
    end
    resource = klass.new(object: user, foo: 'bar')
    actual = resource.as_jsonapi[:id]
    expected = 'bar'

    expect(actual).to eq(expected)
  end

  it 'exposes exposures in .meta' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      meta do
        { foo: @foo }
      end
    end
    resource = klass.new(object: user, foo: 'bar')
    actual = resource.as_jsonapi[:meta]
    expected = { foo: 'bar' }

    expect(actual).to eq(expected)
  end

  it 'exposes exposures in .link' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      link(:self) { @foo }
    end
    resource = klass.new(object: user, foo: 'bar')
    actual = resource.as_jsonapi[:links][:self]
    expected = 'bar'

    expect(actual).to eq(expected)
  end

  it 'exposes exposures in .attribute' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      attribute :foo do
        @foo
      end
    end
    resource = klass.new(object: user, foo: 'bar')
    actual = resource.as_jsonapi[:attributes]
    expected = {
      foo: 'bar'
    }

    expect(actual).to eq(expected)
  end

  it 'exposes exposures in .relationship' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts do
        data do
          @posts
        end
        linkage do
          @posts.map do |p|
            { id: p.id.to_s, type: :posts, meta: { foo: @foo } }
          end
        end
        link(:self) { @foo }
        meta foo: @foo
      end
    end
    posts = [Post.new(id: 1), Post.new(id: 2)]
    resource = klass.new(object: user, foo: 'bar', posts: posts)
    actual = resource.as_jsonapi(include: [:posts])[:relationships][:posts]
    expected = {
      data: [
        { id: '1', type: :posts, meta: { foo: 'bar' } },
        { id: '2', type: :posts, meta: { foo: 'bar' } }
      ],
      links: {
        self: 'bar'
      },
      meta: { foo: 'bar' }
    }

    expect(actual).to eq(expected)
  end

  it 'forwards exposures to related resources' do
    post_klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'posts'
      id { @foo }
    end
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts, class: post_klass
    end
    inferrer = {
      Post: post_klass,
      User: klass
    }
    resource = klass.new(object: user, foo: 'bar', _class: inferrer)
    actual = resource.as_jsonapi(include: [:posts])[:relationships][:posts]
    expected = {
      data: [{ type: :posts, id: 'bar' }, { type: :posts, id: 'bar' }]
    }

    expect(actual).to eq(expected)
  end
end
