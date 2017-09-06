require 'spec_helper'

describe JSONAPI::Serializable::Resource, '#jsonapi_related' do
  let(:posts) { [Post.new(id: 1), Post.new(id: 2)] }
  let(:user) do
    User.new(id: 'foo', name: 'Lucas', address: '22 Ruby drive', posts: posts)
  end
  let(:inferrer) do
    Hash.new { |h, k| h[k] = Object.const_get("Serializable#{k}") }
  end

  it 'returns included resources' do
    resource = SerializableUser.new(object: user,
                                    _class: inferrer)
    related = resource.jsonapi_related([:posts])

    expect(related[:posts].size).to eq(2)
    expect(related[:posts].first).to respond_to(:as_jsonapi)
  end

  it 'omits non-included relationships' do
    resource = SerializableUser.new(object: user,
                                    _class: inferrer)
    related = resource.jsonapi_related([])

    expect(related).to eq({})
  end

  it 'returns an array for to-one relationships' do
    user = User.new(posts: Post.new(id: 1))
    resource = SerializableUser.new(object: user,
                                    _class: inferrer)
    related = resource.jsonapi_related([:posts])

    expect(related[:posts].size).to eq(1)
  end

  it 'returns an empty array for nil relationships' do
    user = User.new(posts: nil)
    resource = SerializableUser.new(object: user,
                                    _class: inferrer)
    related = resource.jsonapi_related([:posts])

    expect(related[:posts]).to eq([])
  end
end
