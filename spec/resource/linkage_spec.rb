require 'spec_helper'

describe JSONAPI::Serializable::Resource, '.linkage' do
  let(:posts) { [Post.new(id: 1), Post.new(id: 2)] }
  let(:user) { User.new(id: 'foo', posts: posts) }
  let(:inferrer) do
    Hash.new { |h, k| h[k] = Object.const_get("Serializable#{k}") }
  end

  it 'defaults to forcing standard linkage' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts, class: SerializablePost do
        linkage always: true
      end
    end

    resource = klass.new(object: user, _class: inferrer)
    actual = resource.as_jsonapi[:relationships][:posts]
    expected = {
      data: [{ type: :posts, id: '1' },
             { type: :posts, id: '2' }]
    }

    expect(actual).to eq(expected)
  end

  it 'overrides standard linkage' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts, class: SerializablePost do
        linkage do
          [{ type: :posts, id: '5' }]
        end
      end
    end

    resource = klass.new(object: user, _class: inferrer)
    actual = resource.as_jsonapi(include: [:posts])[:relationships][:posts]
    expected = {
      data: [{ type: :posts, id: '5' }]
    }

    expect(actual).to eq(expected)
  end

  it 'does not include overriden linkage unless included' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts, class: SerializablePost do
        linkage do
          [{ type: :posts, id: '5' }]
        end
      end
    end

    resource = klass.new(object: user, _class: inferrer)
    actual = resource.as_jsonapi[:relationships][:posts]
    expected = { meta: { included: false } }

    expect(actual).to eq(expected)
  end
end
