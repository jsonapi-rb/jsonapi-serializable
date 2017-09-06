require 'spec_helper'

describe JSONAPI::Serializable::Renderer, '#render' do
  let(:posts) { [Post.new(id: 1), Post.new(id: 2)] }
  let(:user) do
    User.new(id: 'foo', name: 'Lucas', address: '22 Ruby drive', posts: posts)
  end

  it 'renders a success document' do
    hash = subject.render(user, class: { User: SerializableUser })

    expect(hash[:data][:type]).to eq(:users)
  end

  it 'renders a success document with included resources' do
    hash = subject.render(
      user, include: [:posts],
      class: { User: SerializableUser, Post: SerializablePost }
    )

    expect(hash[:data][:type]).to eq(:users)
    expect(hash[:included][0][:type]).to eq(:posts)
  end

  context 'when providing a custom explicit inferrer' do
    it 'uses the inferred serializable classes' do
      inferrer = {
        User: API::SerializableUser,
        Post: API::SerializablePost
      }
      hash = subject.render(user, include: [:posts], class: inferrer)

      expect(hash[:data][:type]).to eq(:api_users)
      expect(hash[:included][0][:type]).to eq(:api_posts)
    end
  end

  context 'when providing a custom implicit inferrer' do
    it 'uses the inferred serializable classes' do
      inferrer = Hash.new do |h, k|
        h[k] = Object.const_get("API::Serializable#{k}")
      end
      hash = subject.render(user, include: [:posts], class: inferrer)

      expect(hash[:data][:type]).to eq(:api_users)
      expect(hash[:included][0][:type]).to eq(:api_posts)
    end
  end
end
