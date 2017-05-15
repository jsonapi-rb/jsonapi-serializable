require 'spec_helper'

describe JSONAPI::Serializable::Renderer, '#render' do
  let(:posts) { [Post.new(id: 1), Post.new(id: 2)] }
  let(:user) do
    User.new(id: 'foo', name: 'Lucas', address: '22 Ruby drive', posts: posts)
  end

  it 'finds a namespaced serializer' do
    hash = JSONAPI::Serializable::Renderer.render(
      user, include: [:posts], namespace: 'API'
    )

    expect(hash[:data][:type]).to eq(:api_users)
    expect(hash[:included][0][:type]).to eq(:api_posts)
  end
end
